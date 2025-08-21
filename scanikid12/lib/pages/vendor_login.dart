import 'package:flutter/material.dart';

class VendorLoginPage extends StatefulWidget {
  const VendorLoginPage({super.key});

  @override
  State<VendorLoginPage> createState() => _ParentLoginPageState();
}

class _ParentLoginPageState extends State<VendorLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBoldTextStyle = TextStyle(
        color: Color(0xFF040C13), fontSize: 20, fontWeight: FontWeight.bold);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/vendor1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 200, left: 50, right: 50),
              child: const Text(
                'welcome to scanikid',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF79BB74),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: 50,
                    right: 50),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Email',
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Password',
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF01060A),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF01060A),
                          child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white),
                              onPressed: () {
                              
                                Navigator.pushReplacementNamed(context, '/home');
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/parent_signup');
                          },
                          child: const Text('Sign Up?', style: darkBoldTextStyle),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement Forgot Password navigation
                          },
                          child: const Text('Forgot Password?',
                              style: darkBoldTextStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ], // Stack children
        ),
      ),
    );
  }
}