import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_button/flutter_social_button.dart';

class VendorLoginPage extends StatefulWidget {
  const VendorLoginPage({super.key});

  @override
  State<VendorLoginPage> createState() => _VendorLoginPageState();
}

class _VendorLoginPageState extends State<VendorLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void googleSignIn() async {
    
    
    // Implement Google Sign-In logic here
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) {
        throw Exception('Authentication successful, but user object is null.');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['role'] != 'vendor') {
        await FirebaseAuth.instance.signOut();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('No vendor account found with this email.')),
        );
        return;
      }

      navigator.pushReplacementNamed('/vendor_dashboard');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credentials, please check your email and password.';
      } else {
        if (kDebugMode) {
          print('Firebase Auth Error: ${e.code} - ${e.message}');
        }
        message = 'An error occurred. Please try again.';
      }
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred during sign-in: $e');
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Image.asset(
                      'assets/img/logo.png',
                      width: MediaQuery.of(context).size.width * 0.3,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Vendor Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Business Email',
                        hintText: 'you@business.com',
                        fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Password',
                        fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF01060A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: const Size(345, 55),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/vendor_signup',
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    FlutterSocialButton(
                onTap: () {},
                buttonType: ButtonType.google, // Button type for different type buttons
              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
