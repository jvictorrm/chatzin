import 'dart:io';

import 'package:chatzin/components/chat_message.dart';
import 'package:chatzin/components/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File file}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        "Não possível fazer o login. Tente novamente.",
        style: TextStyle(color: Colors.red),
      )));
      return;
    }

    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoUrl,
      'time': Timestamp.now()
    };

    if (file != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String urlFile = await taskSnapshot.ref.getDownloadURL();
      data['file'] = urlFile;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) data['text'] = text;

    Firestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: Text(_currentUser != null
              ? "Chat com ${_currentUser.displayName}"
              : "Chat App"),
          centerTitle: true,
          elevation: 0,
          actions: [
            _currentUser != null
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      googleSignIn.signOut();
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text(
                        "Logout realizado com sucesso.",
                        style: TextStyle(color: Colors.blue),
                      )));
                    })
                : Container()
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ChatMessage(
                              documents[index].data,
                              documents[index].data['uid'] ==
                                  _currentUser?.uid);
                        });
                }
              },
            )),
            _isLoading ? LinearProgressIndicator() : Container(),
            TextComposer(_sendMessage)
          ],
        ));
  }
}
