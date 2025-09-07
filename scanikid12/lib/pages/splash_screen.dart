import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:scanikid12/pages/auth_wrapper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.25, // 25% of screen width
            child: Image.asset('assets/anim/kid.gif'),
          ),
        ],
      ),
      splashIconSize: screenWidth * 0.4, // 40% of screen width
      nextScreen: const AuthWrapper(),
      duration: 1500, // A more standard duration.
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.fadeTransition,
      // For a smoother page transition, you can add the `page_transition` package
      // and uncomment the line below.
      // pageTransitionType: PageTransitionType.fade,
    );
  }
}