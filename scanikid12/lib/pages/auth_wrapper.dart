import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait a frame to ensure the widget is built before navigating.
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user logged in, go to the main role selection screen.
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // User is logged in, check their role from Firestore.
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted && userDoc.exists) {
        final role = userDoc.data()?['role'];
        if (role == 'parent') {
          Navigator.of(context).pushReplacementNamed('/parent_dashboard');
        } else if (role == 'vendor') {
          Navigator.of(context).pushReplacementNamed('/vendor_dashboard');
        } else {
          // Role not found or invalid, default to home.
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // User document doesn't exist, default to home.
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Handle potential errors (e.g., network issues) by going home.
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while we determine the correct route.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}