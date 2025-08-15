import 'package:flutter/material.dart';


class List extends StatelessWidget {
  const List({super.key});

  @override
  Widget build(BuildContext context) {

      return Scaffold(
       body: ListView(
       
        children: [
          
          Expanded(
          child:   Container(
                  height: 350,
            color: Color.fromARGB(255, 0, 76, 255),
          ),
           ),
          Expanded(
           
          child:   Container(
                  height: 350,
            color: Color.fromARGB(255, 51, 255, 0),
          ),
          ),
          Expanded(
          child: Container(
              height: 350,
            color: Color.fromARGB(255, 217, 255, 0),
          ),
          ),
        ],
       ), 
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index){
            if(index==0){
            Navigator.pushNamed(context, '/first');
            }
            else if(index==1){
            Navigator.pushNamed(context, '/settings');}
          }
      ),
       );
  }
}