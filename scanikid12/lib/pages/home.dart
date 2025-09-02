import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate a dynamic size for the buttons.
    // We'll aim for each button to take up roughly 35% of the screen width,
    // but we'll clamp the value to ensure it's not too small or too large.
    final buttonSize = (screenWidth * 0.35).clamp(120.0, 160.0);

    // Make the icon and font size responsive to the button size.
    final iconSize = buttonSize * 0.4;
    final fontSize = buttonSize * 0.12;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding( 
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/logo.png',
                  width: screenWidth * 0.3,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 48),
               
                const SizedBox(height: 64),
                // Use a Wrap widget to allow buttons to stack vertically on smaller screens.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24.0, // Horizontal space between buttons
                  runSpacing: 24.0, // Vertical space if they wrap
                  children: [
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/parent_login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.man, size: iconSize),
                            const SizedBox(height: 8),
                            Text(
                              'Parent',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: fontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/vendor_login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront, size: iconSize),
                            const SizedBox(height: 8),
                            Text(
                              'Vendor',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: fontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}