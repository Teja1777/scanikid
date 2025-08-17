import 'package:flutter/material.dart';

import 'package:scanikid12/pages/background.dart';
import 'package:scanikid12/pages/base.dart';
import 'package:scanikid12/pages/field.dart';
import 'package:scanikid12/pages/first_page.dart';
import 'package:scanikid12/pages/kid.dart';
import 'package:scanikid12/pages/login.dart';
import 'package:scanikid12/pages/second_page.dart';
import 'package:scanikid12/pages/settings.dart';
import 'package:scanikid12/pages/list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loginpage(),
      routes: {
        '/first': (context) => FirstPage(),
        '/second': (context) => SecondPage(),
        '/settings': (context) => Settings(),
        '/background': (context) => Background(),
        '/field': (context) => const MyWidget(),
        '/base': (context) => const Base(),
        '/list': (context) => const ListPage(),
        '/kid': (context) => const Kid(),
       '/login': (context) => const Loginpage(),
      },
    );
  }
}
