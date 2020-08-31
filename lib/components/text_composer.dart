import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  final Function({String text, File file}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  // controllers
  final TextEditingController _messageFieldController = TextEditingController();

  // vars
  bool _isComposing = false;

  // functions
  void _clearMessageField() {
    _messageFieldController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[900],
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final PickedFile photo =
                  await ImagePicker().getImage(source: ImageSource.camera);

              if (photo == null) return;
              widget.sendMessage(file: File(photo.path));
            },
          ),
          Expanded(
              child: TextField(
            controller: _messageFieldController,
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration.collapsed(
                hintText: "Digite a sua mensagem",
                hintStyle: TextStyle(color: Colors.white)),
            onChanged: (text) {
              setState(() {
                _isComposing = text.trim().isNotEmpty;
              });
            },
            onSubmitted: (text) {
              widget.sendMessage(text: text);
              _clearMessageField();
            },
          )),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _messageFieldController.text);
                    _clearMessageField();
                  }
                : null,
          )
        ],
      ),
    );
  }
}
