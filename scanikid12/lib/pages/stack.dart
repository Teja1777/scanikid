import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stack Example'),
          backgroundColor: Color.fromARGB(255, 0, 76, 255),
        ),
       body: Stack(
       
        children: [
          
          Container(
                  height: 300,
                  width: 300,
            color: Color.fromARGB(255, 0, 76, 255),
          ),

           
    Container(
                 height: 200,
                  width: 200,
            color: Color.fromARGB(255, 51, 255, 0),
          ),
    Container(
               height: 100,
                  width: 100,
            color: Color.fromARGB(255, 217, 255, 0),
          ),
         
        ],
       ), 
       ),
    );
  }
}