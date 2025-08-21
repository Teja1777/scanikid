import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'welcome to scanikid',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4ADE80),
                  ),
                ),
                const SizedBox(height: 48), 
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBjl-Fka4h6ZyGQBDHmKZVyMMIv-40wGvi_fKGxsCzbZa0z2dA22tBE2iW_1i_m9VoMcLDMaafg1vCNvM7zbxm6GCOvtMnWTyjWejwA3hL2umiwBF-wXF_QUPsm9WcI66kaxrNcrGceXj4aSmgEG_tQy-Gf1usfSdtJeADrlvqFTSmd7s_tBklji3KkcHjlzbk5FKT49zbSv6ueT36x7FloaTfeWWPhQucGb2vcfl8wunxufLpOkuiptbY2JAzTYoJXJD34oMtTbSM',
                  width: 192,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 64), 
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                           
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6), 
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), 
                            ),
                            elevation: 5, 
                          ),
                          child: const Text(
                            'Parent',
                            style: TextStyle(
                              fontWeight: FontWeight.w600, 
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                          
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), 
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Vendor',
                            style: TextStyle(
                              fontWeight: FontWeight.w600, 
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}