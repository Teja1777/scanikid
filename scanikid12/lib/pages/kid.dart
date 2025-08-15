import 'package:flutter/material.dart';
class Kid extends StatelessWidget{
  const Kid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kid Page'),
        backgroundColor: const Color.fromRGBO(207, 220, 19, 1),
      ),
      drawer:Drawer(
        child:ListView(
        padding : EdgeInsets.zero,
        children: [
          DrawerHeader(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(207, 220, 19, 1),
          ),
          child: const Text('Kid Drawer'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('settings'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title:const Text('home'),),
        ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'login',
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
        Form(
          child:Column(
            children:[
             TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),

              ),
              onChanged: (String value) {
                // Handle email input
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
             ),
             TextFormField(
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                labelText: 'password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),

              ),
              onChanged: (String value) {
                // Handle email input
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email password';
                }
                return null;
              },
             )
            ],
          ),
        ),
        ],
      )
    );
  }
}