import 'package:flutter/material.dart';
// import 'package:adminapp/lib/sign_in_page2.dart'; // Import the SignInPage2 class
import 'package:adminapp/SignInPage2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage2(), // Set SignInPage2 as the home screen
    );
  }
}
