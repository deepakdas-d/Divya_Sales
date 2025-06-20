import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales/Auth/Signup.dart';
import 'package:sales/Auth/otp-verification.dart';
import 'package:sales/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool isEmailEmpty = true;
  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      final email = _emailController.text.trim();

      setState(() {
        isEmailEmpty = email.isEmpty;
        isEmailValid = _isValidEmail(email); // <- validate format
      });
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      print("Attempting to sign in with email: $email");

      // Step 1: Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user == null) {
        return 'User not found after authentication.';
      }

      String uid = user.uid;
      print("Sign in successful. UID: $uid");

      // Step 2: Check user in 'Sales' collection
      DocumentSnapshot<Map<String, dynamic>> salesDoc = await FirebaseFirestore
          .instance
          .collection('Sales')
          .doc(uid)
          .get();

      if (!salesDoc.exists) {
        await FirebaseAuth.instance.signOut();
        return 'No Sales record found for this user.';
      }

      final data = salesDoc.data();
      if (data == null || data['role'] != 'Sales') {
        await FirebaseAuth.instance.signOut();
        return 'Access denied. You are not authorized as Sales.';
      }

      print("Sales login verified.");
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  void handleSignIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill in both fields")));
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      String? result = await signIn(email, password);

      // Remove the loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Signed in successfully"),
            backgroundColor: Color(0xFFFFCC3E),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()), // Fix class name
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $result")));
      }
    } catch (e) {
      // Remove loading dialog if still showing
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          //top circles
          Positioned(
            top: MediaQuery.of(context).size.height * -0.15,
            left: 0,
            right: 0,
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.52, // Adjust as needed
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/top_up.png',
                fit: BoxFit.cover, // Makes image fill box completely
              ),
            ),
          ),

          //logo
          Positioned(
            top: MediaQuery.of(context).size.height * .08,
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

          //Welcome text
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            left: MediaQuery.of(context).size.height * 0.04,
            right: MediaQuery.of(context).size.height * 0.04,
            child: Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.035,
                fontWeight: FontWeight.bold,
                color: Color(0xFF030047),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Sign in text
          Positioned(
            top: MediaQuery.of(context).size.height * 0.43,
            left: MediaQuery.of(context).size.height * 0.04,
            right: MediaQuery.of(context).size.height * 0.04,
            child: Text(
              'SIGN IN',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.025,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 63, 97, 209),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          //text fields of email
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: MediaQuery.of(context).size.height * 0.04,
            right: MediaQuery.of(context).size.height * 0.04,
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.email_outlined,
                  color: Color(0xFF030047),
                ),
                labelText: 'Email or Username',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 193, 204, 240),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF030047), width: 2),
                ),
                filled: true,
                fillColor: Color(0xFFE1E5F2),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * .02,
                  vertical: MediaQuery.of(context).size.height * .015,
                ),
              ),
              style: TextStyle(fontSize: 18),
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            left: MediaQuery.of(context).size.height * 0.04,
            right: MediaQuery.of(context).size.height * 0.04,
            child: TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Color(0xFF030047),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 193, 204, 240),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF030047), width: 2),
                ),
                filled: true,
                fillColor: Color(0xFFE1E5F2),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * .02,
                  vertical: MediaQuery.of(context).size.height * .015,
                ),
              ),
              style: TextStyle(fontSize: 18),
            ),
          ),

          //forgot password text
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            right: MediaQuery.of(context).size.height * 0.04,
            child: TextButton(
              onPressed: (!isEmailEmpty && isEmailValid)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OTPVerification(
                            email: _emailController.text.trim(),
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: (!isEmailEmpty && isEmailValid)
                      ? Colors.blue
                      : Colors.grey,
                  fontSize: MediaQuery.of(context).size.height * 0.016,
                ),
              ),
            ),
          ),

          //  Button above the image
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.22,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    handleSignIn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFCC3E),
                  ),
                  child: Text(
                    "SIGN IN",
                    style: TextStyle(color: Color(0xFF030047), fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          // Sign Up text
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                height: MediaQuery.of(context).size.height * 0.06,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "don't have an account? ",
                      style: TextStyle(color: Color(0xFF030047), fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      child: Text(
                        "create one now",
                        style: TextStyle(
                          color: Color(0xFFFFCC3E),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
