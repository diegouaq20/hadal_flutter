import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Center(
        child: Image.asset(
          'assets/logoInicio.png',
          width: 130,
          height: 130,
        ),
      ),
    );
  }
}
