import 'package:flutter/material.dart';

// Note: You no longer need to import 'second_page.dart' here when using named routes.
// To handle the state of the TextField, this widget was converted from a
// StatelessWidget to a StatefulWidget.
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  final _myController = TextEditingController();



  void _greet() {

    debugPrint(_myController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Page'),
        backgroundColor: Colors.blue,
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
            if (index == 0) {
              // Avoid pushing the same route if we are already on it.
              if (ModalRoute.of(context)?.settings.name != '/first') {
                Navigator.pushNamed(context, '/first');
              }
            } else if (index == 1) {
              Navigator.pushNamed(context, '/settings');
            }
          },
        ),
      body: Center(
        // A Center widget can only have one child.
        // To display multiple widgets, use a layout widget like Column.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("goto second page"),
                onPressed: () {
                  // Use the named route defined in main.dart
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 60),
              // The 'const' keyword was removed because _myController is not a constant.
              TextField(
                controller: _myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter text',
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: _greet,
                child: const Text("ok"),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/img/k4.jpg',
                height:300,
                width: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}