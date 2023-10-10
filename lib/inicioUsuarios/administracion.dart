import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadal/inicioUsuarios/login_screen.dart';
import 'documentosUsuarios.dart';

class Administracion extends StatefulWidget {
  @override
  _AdministracionState createState() => _AdministracionState();
}

class _AdministracionState extends State<Administracion> {
  String nombre = "";
  String tipoUsuario = "";

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Está seguro de que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 29, 209, 194))),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Sí', style: TextStyle(color: Color.fromARGB(255, 29, 209, 194))),
          ),
        ],
      ),
    );
  }

  void _goToDocuments(String nombre, String tipoUsuario, String acceso, String userID, String photoUrl,
  String ine, String curp, String comprobanteDomicilio, String receta, String tituloProfecional, String cedulaProfecional,
  String referenciaUno, String referenciaDos){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentosUsuarios(nombre, tipoUsuario, acceso, userID, photoUrl, 
        ine, curp, comprobanteDomicilio, receta, tituloProfecional, cedulaProfecional, referenciaUno, referenciaDos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Administración de usuarios', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Padding(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var userData = snapshot.data?.docs[index].data();
                  var userID = snapshot.data?.docs[index].id;

                  bool hasNullValue = false;

                  userData?.forEach((key, value) {
                    if (value == null && key != "tipoUsuario" && userData["tipoUsuario"] != "administrador") {
                      hasNullValue = true;
                    }
                  });

                  return Padding(
                    padding: EdgeInsets.only(left: 35, right: 35, top: 20, bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: (userData!['acceso'] != null) ? ((userData['acceso'] == "desbloqueado") ? Color.fromARGB(255, 12, 126, 16) : ((userData['acceso'] == "bloqueado") ? Color.fromARGB(255, 182, 12, 0) : Color.fromARGB(255, 70, 64, 64))) : Colors.grey,
                          borderRadius: BorderRadius.circular(7.0),
                          border: Border.all(color: Colors.black)
                      ),
                      child: ListTile(
                        title: userData['nombre'] != null ? Text(userData['nombre'], style: TextStyle(color:Colors.white)) : Text(''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userData['tipoUsuario'] != null ? Text(userData['tipoUsuario'], style: TextStyle(color:Colors.white)) : Text(''),
                            userData['acceso'] != null ? Text(userData['acceso'], style: TextStyle(color:Colors.white)) : Text(''),
                            hasNullValue
                              ? Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 5), Text('Falta por subir documentos', style: TextStyle(color:Colors.white))])
                              : userData['acceso'] != null
                                  ? TextButton(
                                      onPressed: () => _goToDocuments(userData['nombre'], userData['tipoUsuario'], userData['acceso'], userID!,
                                          userData['photoUrl'], userData['ine'], userData['curp'], userData['comprobanteDomicilio'], userData['receta'],
                                          userData['tituloProfecional'], userData['cedulaProfecional'], userData['referenciaUno'], userData['referenciaDos']),
                                      child: Text('Ver documentos', style: TextStyle(color:Colors.white)),
                                      style: ButtonStyle( // estilo para el botón
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // cambiamos el color de la fuente a blanco
                                      ),
                                    )
                                  : Text(''),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}