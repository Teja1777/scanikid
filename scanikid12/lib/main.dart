import 'package:flutter/material.dart';
import 'package:scanikid12/pages/parent/parent_login.dart';
import 'package:scanikid12/pages/home.dart';
import 'package:scanikid12/pages/parent/parent_signup.dart';
import 'package:scanikid12/pages/vendor/vendor_login.dart';
import 'package:scanikid12/pages/vendor/vendor_signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
      '/parent_login': (context) => const ParentLoginPage(),
      '/parent_signup': (context) => const ParentSignUpPage(),
      '/vendor_login': (context) => const VendorLoginPage(),
      '/vendor_signup': (context) => const VendorSignUpPage(),
      },
    );
  }
}
