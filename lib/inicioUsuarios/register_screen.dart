import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:hadal/pacientes/PerfilDatos/PerfilPaciente.dart';
import 'package:hadal/enfermeras/PerfilDatos/PerfilEnfermera.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastSurnameController = TextEditingController();
  final TextEditingController _secondSurnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isObscure = true;

  void _toggleObscure() {
  setState(() {
    _isObscure = !_isObscure;
  });
}
  
  String _tipoUsuario = 'Paciente';
  //datos para pacientes
  String receta = "";
  
  //para enfermeras
  String tituloProfecional = "";
  String cedulaProfecional = "";
  String referenciaUno = "";
  String referenciaDos = "";
  //datos generales
  String ine = "";
  String curp = "";
  String comprobanteDomicilio = "";
  String photoUrl = "";
  String bloqueado = 'bloqueado';
  String? _errorMessage;

  void _register() async {
  if (_passwordController.text != _passwordConfirmationController.text) {
    setState(() {
      _errorMessage = 'Las contraseñas no coinciden';
    });
    return;
  }
  if (_nameController.text.isEmpty ||
      _lastSurnameController.text.isEmpty ||
      _secondSurnameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _passwordConfirmationController.text.isEmpty ||
      _phoneController.text.isEmpty ||
      _addressController.text.isEmpty) {
    setState(() {
      _errorMessage = 'Todos los campos deben llenarse';
    });
    return;
  }

  try {
    final UserCredential newUser = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    Map<String, dynamic> userData = {
      'nombre': _nameController.text,
      'tipoUsuario': _tipoUsuario,
      'primerApellido': _lastSurnameController.text,
      'segundoApellido': _secondSurnameController.text,
      'telefono': _phoneController.text,
      'domicilio': _addressController.text,
      'ine': null,
      'curp': null,
      'comprobanteDomicilio': null,
      'receta': null,
      'photoUrl': null,
      'tituloProfecional': null,
      'cedulaProfecional': null,
      'referenciaUno': null,
      'referenciaDos': null,
      'contraseña': _passwordController.text,
      'acceso': "bloqueado",
    };

    if (_tipoUsuario == 'Paciente') {
      userData.addAll({
        'tituloProfecional': tituloProfecional,
        'cedulaProfecional': cedulaProfecional,
        'referenciaUno': referenciaUno,
        'referenciaDos': referenciaDos,
      });
    } else {
      userData.addAll({
        'receta': receta,
      });
    }

    await _firestore.collection('users').doc(newUser.user!.uid).set(userData);

    if (_tipoUsuario == 'Paciente') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PerfilPaciente()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PerfilEnfermera()),
      );
    }
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
    });
  } 
}

  

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF4FCFB),
    appBar: AppBar(
        backgroundColor: Color(0xFFF4FCFB),
        title: Text(
          'Registrar Usuario',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF235365),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        elevation: 2.0,
      ),
    body: Padding(
      padding: EdgeInsets.only(left: 30.0, top: 20.0,right: 30.0),
      child: ListView(
        children: [
          Card(
            elevation: 10,
            color: Color(0xFFF4FCFB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'CREAR PERFIL',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF235365),
                    ),
                  ),
                  SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Nombre(s)', border: InputBorder.none),
                          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textCapitalization: TextCapitalization.words, // Capitaliza la primera letra de cada palabra ingresada
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]{2,}'))], // Rechaza cualquier entrada con más de un espacio
                          onEditingComplete: () {
                            String text = _nameController.text;
                            List<String> words = text.trim().split(' '); // Elimina los espacios antes de la primera palabra y después de la última palabra
                            String formattedName = '';
                            for (int i = 0; i < words.length; i++) {
                              String word = words[i];
                              if (word.isNotEmpty) {
                                formattedName += word[0].toUpperCase() + word.substring(1).toLowerCase();
                                if (i < words.length - 1) {
                                  formattedName += ' ';
                                }
                              }
                            }
                            _nameController.text = formattedName;
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: TextField(
                        controller: _lastSurnameController,
                        decoration: InputDecoration(labelText: 'Apellido Paterno', border: InputBorder.none),
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        textCapitalization: TextCapitalization.words, // Capitaliza la primera letra de cada palabra ingresada
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]{2,}'))], // Rechaza cualquier entrada con más de un espacio
                        onEditingComplete: () {
                          String text = _lastSurnameController.text;
                          List<String> words = text.trim().split(' '); // Elimina los espacios antes de la primera palabra y después de la última palabra
                          String formattedName = '';
                          for (int i = 0; i < words.length; i++) {
                            String word = words[i];
                            if (word.isNotEmpty) {
                              formattedName += word[0].toUpperCase() + word.substring(1).toLowerCase();
                              if (i < words.length - 1) {
                                formattedName += ' ';
                              }
                            }
                          }
                          _lastSurnameController.text = formattedName;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: TextField(
                        controller: _secondSurnameController,
                        decoration: InputDecoration(labelText: 'Apellido Materno', border: InputBorder.none),
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        textCapitalization: TextCapitalization.words, // Capitaliza la primera letra de cada palabra ingresada
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]{2,}'))], // Rechaza cualquier entrada con más de un espacio
                        onEditingComplete: () {
                          String text = _secondSurnameController.text;
                          List<String> words = text.trim().split(' '); // Elimina los espacios antes de la primera palabra y después de la última palabra
                          String formattedName = '';
                          for (int i = 0; i < words.length; i++) {
                            String word = words[i];
                            if (word.isNotEmpty) {
                              formattedName += word[0].toUpperCase() + word.substring(1).toLowerCase();
                              if (i < words.length - 1) {
                                formattedName += ' ';
                              }
                            }
                          }
                          _secondSurnameController.text = formattedName;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: _phoneController.text.trim().isEmpty || !RegExp(r'^\d+$').hasMatch(_phoneController.text.trim()) ? Colors.grey : Colors.grey),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: 'Teléfono', border: InputBorder.none),
                      onSubmitted: (_) {
                        _phoneController.text = _phoneController.text.trim();
                        FocusScope.of(context).nextFocus();
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                  SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Domicilio', border: InputBorder.none),
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Correo Electrónico', border: InputBorder.none),
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: _toggleObscure,
                          ),
                        ),
                        obscureText: _isObscure,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: _passwordConfirmationController.text == _passwordController.text ? Colors.grey : Colors.red,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: TextField(
                        controller: _passwordConfirmationController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          border: InputBorder.none,
                          
                        ),
                        obscureText: true,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                    
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0, right: 30.0),
                    child: Text(
                      'Tipo de usuario:',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Radio(
                            activeColor: Colors.teal,
                            value: 'Paciente',
                            groupValue: _tipoUsuario,
                            onChanged: (value) {
                              setState(() {
                                _tipoUsuario = value.toString();
                              });
                            },
                          ),
                          Text('Paciente'),
                          Radio(
                            activeColor: Colors.teal,
                            value: 'Enfermera',
                            groupValue: _tipoUsuario,
                            onChanged: (value) {
                              setState(() {
                                _tipoUsuario = value.toString();
                              });
                            },
                          ),
                          Text('Enfermera'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0, right: 30.0),
                    child: ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrar Usuario'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF1BC0B2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null && _errorMessage!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0, right: 30.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}