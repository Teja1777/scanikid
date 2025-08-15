import 'package:flutter/material.dart';
import 'package:scan/pages/background.dart';
import 'package:scan/pages/first_page.dart';
import 'package:scan/pages/second_page.dart';
import 'package:scan/pages/settings.dart';
import 'package:scan/pages/field.dart';
import 'package:scan/pages/base.dart';
import 'package:scan/pages/list.dart';
import 'package:scan/pages/Kid.dart';
import 'package:scan/pages/login.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
      routes: {
        '/first': (context) => FirstPage(),
        '/second': (context) => SecondPage(),
        '/settings': (context) =>  Settings(), 
        '/background': (context) => Background(),
        '/field': (context) => const MyWidget(),
        '/base': (context) => const Base(),
        '/list': (context) => const List(),
        '/kid': (context) => const Kid(),
        '/login':(context)=>const Loginpage(),
      },
    );
  }
}