import 'package:flutter/material.dart';
class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage > createState() => _Loginpagestate(); 
}

class _Loginpagestate extends State<Loginpage > {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/kid2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        
      body:Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 200, left: 50, right: 50),
            child: Text(
              'welcome to scanikid',
              style: TextStyle(
                fontSize: 30,
                color: const Color.fromARGB(255, 121, 187, 116),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding:  EdgeInsets.only(top:MediaQuery.of(context).size.height*0.5, left: 50, right: 50),
              child: Column(
                children:[
                  TextField(
                    decoration:InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Email',
                      fillColor: Colors.grey[100],
                      filled: true,
                      
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    obscureText: true,
                    decoration:InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'password',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 70,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Text(
                        'sign in',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 1, 6, 10),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color.fromARGB(255, 1, 6, 10),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(context, '/first');
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      TextButton(
                        onPressed: () {
                      
                        },
                        child: const Text(
                          'sign up?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 12, 19),
                            fontSize: 20, fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/background');
                        },
                        child: const Text(
                          'forgot password?',
                          style: TextStyle(
                            color: Color.fromRGBO(2, 1, 1, 0.965),
                            fontSize: 20, fontWeight:FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                  ),
                  
                ], 
              ),
                
            ),
          ),
        ],// Stack children
       ),
        
      ),
    );
  }
}