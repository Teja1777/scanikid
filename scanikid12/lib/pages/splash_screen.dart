import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:scanikid12/pages/auth_wrapper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/logo.png',
            width: MediaQuery.of(context).size.width * 0.4,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 120, // Adjust size as needed
            child: Lottie.asset('assets/anim/loading.json'),
          ),
        ],
      ),
      nextScreen: const AuthWrapper(),
      splashIconSize: 400, // Adjust this to fit your splash content
      duration: 3000, // A more standard duration.
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.fadeTransition,
      // For a smoother page transition, you can add the `page_transition` package
      // and uncomment the line below.
      // pageTransitionType: PageTransitionType.fade,
    );
  }
}