import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadal/inicioUsuarios/login_screen.dart';

class EnEspera extends StatefulWidget {
  @override
  _EnEsperaState createState() => _EnEsperaState();
}

class _EnEsperaState extends State<EnEspera> {
  void _getCurrentUserPhotoUrl() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      body: Center(
        child: Padding(
          padding:
              EdgeInsets.only(left: 35.0, top: 80.0, bottom: 35.0, right: 35),
          child: Card(
            color: Color(0xFFF4FCFB),
            elevation: 5,
            shadowColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 35.0, right: 35),
                  child: Icon(
                    Icons.check_circle_sharp,
                    color: Color(0xFF1FBAAF),
                    size: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 35.0, bottom: 20.0, right: 35),
                  child: Text(
                    "¡LISTO!",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF235365),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 35.0, bottom: 35.0, right: 35),
                  color: Color(0xFFF4FCFB),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Se validarán tus documentos. Por favor, intenta ingresar de nuevo en 24hrs.",
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Aceptar', style: TextStyle(fontSize: 20.0)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.only(left: 35.0, right: 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      primary: Color(0xFF1FBAAF),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
