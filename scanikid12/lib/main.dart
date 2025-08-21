import 'package:flutter/material.dart';
import 'package:scanikid12/pages/login.dart';
import 'package:scanikid12/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      routes: {
       '/login': (context) => const Loginpage(),
       '/home': (context) => const Home(),
      },
    );
  }
}
