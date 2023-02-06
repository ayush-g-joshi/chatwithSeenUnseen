import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../homepage.dart';
import '../auth/loginpage.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Authenticate({super.key});

  @override
  Widget build(BuildContext context) {

    if (_auth.currentUser == null) {
      return LoginPage();
    } else {
      return  HomeScreen();
    }
  }
}