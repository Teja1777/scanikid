import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('second Page'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
         child: Padding(
          padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('go to the background page'),
          onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
           ],
        ),
      ),
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
            Navigator.pushNamed(context, '/base');}
          }
      ),
    );
  }
}
