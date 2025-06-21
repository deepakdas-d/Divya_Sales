import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:sales/Auth/Signin.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> logout(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Signin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.yellowAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: IconButton(
              onPressed: () {
                logout(context);
              },
              icon: Icon(Icons.logout_outlined, size: 30),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
