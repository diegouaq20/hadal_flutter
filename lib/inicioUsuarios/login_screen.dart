import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hadal/enfermeras/perfilDatos/documentoaFaltantes/cedulaProfecionalFaltante.dart';
import 'package:hadal/enfermeras/perfilDatos/documentoaFaltantes/referenciaDosFaltante.dart';
import 'package:hadal/enfermeras/perfilDatos/documentoaFaltantes/referenciaUnoFaltante.dart';
import 'package:hadal/enfermeras/perfilDatos/documentoaFaltantes/tituloProfecionalFaltante.dart';
import 'package:hadal/enfermeras/perfilDatos/perfilEnfermera.dart';
import 'package:hadal/enfermeras/interfazDeEnfermera/principalEnfermera.dart';
import 'package:hadal/inicioUsuarios/administracion.dart';
import 'package:hadal/inicioUsuarios/restablecerContrase%C3%B1a.dart';
import 'package:hadal/pacientes/ajustes/ajustes.dart';
import 'package:hadal/pacientes/home/principalPaciente.dart';
import 'package:hadal/pacientes/perfilDatos/documentosFaltantes/comprobanteDomicilioPacienteFaltante.dart';
import 'package:hadal/pacientes/perfilDatos/documentosFaltantes/curpPacienteFaltante.dart';
import 'package:hadal/pacientes/perfilDatos/documentosFaltantes/inePacienteFaltante.dart';
import 'package:hadal/pacientes/perfilDatos/documentosFaltantes/perfilPacienteFaltante.dart';
import 'package:hadal/pacientes/perfilDatos/documentosFaltantes/recetaPacienteFaltante.dart';

import '../enfermeras/perfilDatos/documentoaFaltantes/comprobanteDomicilioEnfermeraFaltante.dart';
import '../enfermeras/perfilDatos/documentoaFaltantes/curpEnfermeraFaltante.dart';
import '../enfermeras/perfilDatos/documentoaFaltantes/ineEnfermeraFaltante.dart';
import '../enfermeras/perfilDatos/documentoaFaltantes/perfilEnfermeraFaltante.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4FCFB),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Image.asset(
                            'assets/LOGO.png',
                            width: 150.0,
                            height: 150.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 45.0),
                  child: Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey.withOpacity(0.5),
                    color: Color(0xFFF6FFFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'INICIO DE SESIÓNaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF245366),
                            ),
                          ),
                          SizedBox(height: 50.0),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      labelText: 'Correo Electrónico',
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Por favor ingresa tu correo';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureText
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                      ),
                                      maxLines: 1,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Por favor ingresa tu contraseña';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            width: MediaQuery.of(context).size.width - 20,
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                final user =
                                    await _auth.signInWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                                if (user != null) {
                                  final userUid = user.user?.uid;

                                  // Consultar la colección 'usuarioadministrador'
                                  final userDocAdministrador =
                                      await FirebaseFirestore.instance
                                          .collection('usuarioadministrador')
                                          .doc(userUid)
                                          .get();

                                  // Consultar la colección 'usuariopaciente'
                                  final userDocPaciente =
                                      await FirebaseFirestore.instance
                                          .collection('usuariopaciente')
                                          .doc(userUid)
                                          .get();

                                  // Consultar la colección 'usuarioenfermera'
                                  final userDocEnfermera =
                                      await FirebaseFirestore.instance
                                          .collection('usuarioenfermera')
                                          .doc(userUid)
                                          .get();

                                  //datos para el admin
                                  final tipoUsuario = userDocAdministrador
                                      .data()?['tipoUsuario'];
                                  // Datos generales compartidos por ambos tipos de usuario
                                  final tipoUsuarioPaciente =
                                      userDocPaciente.data()?['tipoUsuario'];
                                  final tipoUsuarioEnfermera =
                                      userDocEnfermera.data()?['tipoUsuario'];

                                  final inePaciente =
                                      userDocPaciente.data()?['ine'];
                                  final ineEnfermera =
                                      userDocEnfermera.data()?['ine'];

                                  final curpPaciente =
                                      userDocPaciente.data()?['curp'];
                                  final curpEnfermera =
                                      userDocEnfermera.data()?['curp'];

                                  final comprobanteDomicilioPaciente =
                                      userDocPaciente
                                          .data()?['comprobanteDomicilio'];
                                  final comprobanteDomicilioEnfermera =
                                      userDocEnfermera
                                          .data()?['comprobanteDomicilio'];

                                  final photoUrlPaciente =
                                      userDocPaciente.data()?['photoUrl'];
                                  final photoUrlEnfermera =
                                      userDocEnfermera.data()?['photoUrl'];

                                  final accesoPaciente =
                                      userDocPaciente.data()?['acceso'];
                                  final accesoEnfermera =
                                      userDocEnfermera.data()?['acceso'];

                                  // Datos específicos de paciente
                                  final receta =
                                      userDocPaciente.data()?['receta'];

                                  // Datos específicos de enfermera
                                  final tituloProfecional = userDocEnfermera
                                      .data()?['tituloProfecional'];
                                  final cedulaProfecional = userDocEnfermera
                                      .data()?['cedulaProfecional'];
                                  final referenciaUno =
                                      userDocEnfermera.data()?['referenciaUno'];
                                  final referenciaDos =
                                      userDocEnfermera.data()?['referenciaDos'];

                                  if (tipoUsuarioPaciente == 'Paciente') {
                                    if (photoUrlPaciente == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio una foto de perfil, es importante que suba una, ya que validaremos su identidad.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PerfilPacienteFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (inePaciente == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su INE, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            InePacienteFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (curpPaciente == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su CURP, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CurpPacienteFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (comprobanteDomicilioPaciente ==
                                        null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su comprobante de domicilio, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ComprobanteDomicilioPacienteFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (receta == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su receta, este documento es importante para evaluar su estado.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RecetaPacienteFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (accesoPaciente == "bloqueado") {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('En Revisión'),
                                            content: Text(
                                                'Su perfil esta siendo revisado, resivirá un correo despues de 48 horas despues de haber subido todos sus documentos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Aceptar',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (inePaciente != null &&
                                        curpPaciente != null &&
                                        comprobanteDomicilioPaciente != null &&
                                        receta != null &&
                                        photoUrlPaciente != null &&
                                        accesoPaciente == 'desbloqueado') {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Principal()));
                                    } else if (inePaciente != null &&
                                        curpPaciente != null &&
                                        comprobanteDomicilioPaciente != null &&
                                        receta != null &&
                                        accesoPaciente == 'desbloqueado' &&
                                        photoUrlPaciente == null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Principal()));
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Es necesario que agregues una foto de perfil'),
                                            actions: [
                                              TextButton(
                                                child: Text('Subir'),
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Ajustes()),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                  //condiciones para acceder a una cuenta de enfermera
                                  else if (tipoUsuarioEnfermera ==
                                      'Enfermera') {
                                    if (photoUrlEnfermera == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio una foto de perfil, es importante que suba una, ya que validaremos su identidad.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PerfilEnfermeraFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (ineEnfermera == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su INE, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            IneEnfermeraFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (curpEnfermera == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su CURP, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CurpEnfermeraFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (comprobanteDomicilioEnfermera ==
                                        null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su comprobante de domicilio, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ComprobanteDomicilioEnfermeraFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (tituloProfecional == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su titulo profesional, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TituloProfecionalFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (cedulaProfecional == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su cedula profesional, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CedulaProfecionalFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (referenciaUno == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su primer referencia, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReferenciaUnoFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (referenciaDos == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'No subio su segunda referencia, no podremos validar sus datos completos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReferenciaDosFaltante()),
                                                  );
                                                },
                                                child: Text('Subir',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (accesoEnfermera == "bloqueado") {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('En Revisión'),
                                            content: Text(
                                                'Su perfil esta siendo revisado, resivirá un correo despues de 48 horas despues de haber subido todos sus documentos.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Aceptar',
                                                    style: TextStyle(
                                                        color: Colors.teal)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.teal),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (ineEnfermera != null &&
                                        curpEnfermera != null &&
                                        comprobanteDomicilioEnfermera != null &&
                                        tituloProfecional != null &&
                                        cedulaProfecional != null &&
                                        referenciaUno != null &&
                                        referenciaDos != null &&
                                        photoUrlEnfermera != null &&
                                        accesoEnfermera == 'desbloqueado') {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrincipalEnfermeras()));
                                    } else if (ineEnfermera != null &&
                                        curpEnfermera != null &&
                                        comprobanteDomicilioEnfermera != null &&
                                        tituloProfecional != null &&
                                        cedulaProfecional != null &&
                                        referenciaUno != null &&
                                        referenciaDos != null &&
                                        accesoEnfermera == 'desbloqueado' &&
                                        photoUrlEnfermera == null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrincipalEnfermeras()));
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Es necesario que agregues una foto de perfil'),
                                            actions: [
                                              TextButton(
                                                child: Text('Subir'),
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Ajustes()),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }

                                  //cuenta de administrador
                                  else if (tipoUsuario == 'administrador') {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Administracion()));
                                  }
                                }
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  _errorMessage = e.message!;
                                });
                              }
                            },
                            child: Text('Iniciar Sesión'),
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFF1FBAAF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                          SizedBox(height: 10.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CambiarContrasena()),
                              );
                            },
                            child: FittedBox(
                              child: Text(
                                'Olvide mi contraseña.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: FittedBox(
                    child: Text(
                      '¿No tienes una cuenta? Registrate.',
                      style: TextStyle(
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
