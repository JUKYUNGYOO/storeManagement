import 'package:flutter/material.dart';
import 'package:adminapp/SignInPage2.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {

  sqfliteFfiInit();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 앱의 루트 위젯
    return MaterialApp(
      title: 'Your App', //앱 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, //기본 테마 색상
      ),
      home: SignInPage2(), //로그인 페이지를 앱의 첫 화면으로 설졍
    );
  }
}
