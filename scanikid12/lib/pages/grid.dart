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
      
        body: GridView.builder(
          itemCount: 64,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
           itemBuilder: (context,index)=> Container(
            
            color: Color.fromARGB(255, 184, 20, 20),
            margin: EdgeInsets.all(10),
            ),
          ),
          ),
      );
   
  }
}