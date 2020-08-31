import 'package:chatzin/screens/chat.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MainScreen(),
    theme: ThemeData(iconTheme: IconThemeData(color: Colors.white)),
    debugShowCheckedModeBanner: false,
  ));
}

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return ChatScreen();
  }
}
