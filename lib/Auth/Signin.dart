import 'package:flutter/material.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.45, // Adjust as needed
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/top_up.png',
                fit: BoxFit.cover, // Makes image fill box completely
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.45, // Adjust as needed
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover, // Makes image fill box completely
              ),
            ),
          ),
        ],
      ),
    );
  }
}
