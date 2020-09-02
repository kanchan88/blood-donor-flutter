import 'package:blood_app_nepal/screens/splash_screen.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(BloodApp());
}

class BloodApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Chaiyo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.pink,
      ),
      home:SplashScreen(),
    );
  }
}