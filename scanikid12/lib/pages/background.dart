import 'package:flutter/material.dart';


class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Page'),
        backgroundColor: Colors.blue,
      ),
      body : ListView(
       children: [
         Image(
        image: AssetImage('assets/img/k4.jpg'),
        fit: BoxFit.cover,
        height: 1000,
      ),
    
       ],
      ),
       
    
    
    );
  }
}