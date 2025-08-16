import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selectedIndex = 0;

  // Define the different pages to be displayed.
  static const List<Widget> _widgetOptions = <Widget>[
    // Placeholder for the "Home" view
    _HomeView(),
    // Placeholder for the "Settings" view
    Text(
      'Settings Page',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

// The original ListView is now the content for the "Home" tab.
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 350,
          color: const Color.fromARGB(255, 0, 76, 255),
        ),
        Container(
          height: 350,
          color: const Color.fromARGB(255, 51, 255, 0),
        ),
        Container(
          height: 350,
          color: const Color.fromARGB(255, 217, 255, 0),
        ),
      ],
    );
  }
}
