// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hadal/pacientes/perfilDatos/perfilPaciente.dart';
import 'package:geolocator/geolocator.dart';

class RegistroPaciente extends StatefulWidget {
  const RegistroPaciente({Key? key});

  @override
  _RegistroPacienteState createState() => _RegistroPacienteState();
}

class _RegistroPacienteState extends State<RegistroPaciente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherLastNameController =
      TextEditingController();
  final TextEditingController _motherLastNameController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ////////////////parte de estados y municipios////////////////
  final databaseReference = FirebaseDatabase.instance.reference();

  List<String> estados = [];
  Map<String, Map<String, dynamic>> nodosPorEstado = {};

  String selectedEstado = "";
  String selectedMunicipio = "";

  TextEditingController estadoSearchController = TextEditingController();
  TextEditingController municipioSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEstados();
  }
  ////////////fin de declaracion variables estado y municipio////////////////

  double? _latitude; // Para almacenar la latitud de la ubicación
  double? _longitude; // Para almacenar la longitud de la ubicación

  void _register() async {
    // Solicitar permisos de ubicación
    LocationPermission permission = await Geolocator.requestPermission();

    if (selectedEstado.isEmpty || selectedMunicipio.isEmpty) {
    // Verificar si selectedEstado o selectedMunicipio están vacíos
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Por favor, seleccione un estado y un municipio.'),
    ));
    return; // No permite el registro si falta la selección
  }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Obtener la ubicación actual y almacenarla en las variables _latitude y _longitude
      await _getCurrentLocation(); // Esperar a que se obtenga la ubicación antes de continuar

      try {
        // Mostrar un indicador de progreso mientras se espera createUserWithEmailAndPassword()
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String uid = userCredential.user?.uid ?? "";

        // Mostrar un indicador de progreso mientras se espera set() en Firestore
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        await _firestore.collection('usuariopaciente').doc(uid).set({
          'nombre': _nameController.text.trim(),
          'primerApellido': _fatherLastNameController.text.trim(),
          'segundoApellido': _motherLastNameController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'domicilio': _addressController.text.trim(),
          'email': _emailController.text.trim(),
          'tipoUsuario': "Paciente",
          'ine': null,
          'curp': null,
          'comprobanteDomicilio': null,
          'receta': null,
          'photoUrl': null,
          'contraseña': _passwordController.text,
          'acceso': "bloqueado",
          'calificacion': 0.0,
          'ubicacion': _latitude != null && _longitude != null
              ? GeoPoint(_latitude!, _longitude!)
              : null, // Almacenar la ubicación en Firestore si está disponible
          'estado': selectedEstado,
          'municipio': selectedMunicipio,
        });

        print('Usuario registrado con UID: $uid');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            alignment: Alignment.center,
            height: 20,
            child: const Text(
              'Usuario Registrado con Éxito!!',
              textAlign: TextAlign.center,
            ),
          ),
        ));

        // Ocultar el indicador de progreso y navegar de nuevo a la pantalla anterior
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PerfilPaciente()),
        );
      } on FirebaseException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('La cuenta ya existe para este correo electrónico.'),
          ));
        } else {
          print('Error registrando al usuario: $e');
        }
      } catch (e) {
        print('Error registrando al usuario: $e');
      }
    } else if (permission == LocationPermission.deniedForever) {
      // Si el usuario deniega permanentemente el acceso a la ubicación
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Se requiere acceso a la ubicación para registrar su cuenta. Por favor, habilite los permisos de ubicación en la configuración de su dispositivo.'),
      ));
    } else {
      // Si el usuario deniega temporalmente el acceso a la ubicación
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Se requiere acceso a la ubicación para registrar su cuenta. Por favor, conceda permisos de ubicación cuando se le solicite.'),
      ));
    }
  }

  // Variable para alternar entre mostrar y ocultar la contraseña
  bool _obscureText = true;

  // Método para obtener la ubicación actual del dispositivo
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
    }
  }

/////////////////estados y municipios/////////////////
  void fetchEstados() {
    databaseReference.once().then((DatabaseEvent databaseEvent) {
      final DataSnapshot dataSnapshot = databaseEvent.snapshot;
      if (dataSnapshot.value is Map<dynamic, dynamic>) {
        final Map<dynamic, dynamic> data =
            dataSnapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          estados.add(key.toString());
          if (value is Map<dynamic, dynamic>) {
            final Map<String, dynamic> nodos = Map<String, dynamic>.from(value);
            nodosPorEstado[key.toString()] = nodos;
          }
        });
        setState(() {});
      }
    });
  }

  void showEstadoList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                  child: Text(
                    "Seleccionar Estado",
                    style: TextStyle(
                      color: Color(0xFF245366),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                Container(
                  height: 300,
                  child: ListView.separated(
                    itemCount: estados.length,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemBuilder: (context, index) {
                      final estado = estados[index];
                      return ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            estado,
                            style: const TextStyle(
                                color: Color(0xFF245366), fontSize: 18.0),
                          ),
                        ),
                        onTap: () {
                          final produccion =
                              nodosPorEstado[estado]?['produccion'];
                          if (produccion is bool && !produccion) {
                            showNotAvailableDialog();
                          } else {
                            setState(() {
                              selectedEstado = estado;
                              selectedMunicipio = "";
                            });
                            estadoSearchController.clear();
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMunicipioList() {
    if (selectedEstado.isNotEmpty &&
        nodosPorEstado.containsKey(selectedEstado)) {
      final municipios =
          nodosPorEstado[selectedEstado]?.values.where((municipio) {
        return municipio is String;
      }).toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                    child: Text(
                      "Seleccionar Municipio",
                      style: TextStyle(
                        color: Color(0xFF245366),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Container(
                    height: 300,
                    child: ListView.separated(
                      itemCount: municipios!.length,
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (context, index) {
                        final municipio = municipios[index];
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              municipio.toString(),
                              style: const TextStyle(
                                  color: Color(0xFF245366), fontSize: 16.0),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedMunicipio = municipio.toString();
                            });
                            municipioSearchController.clear();
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showNotAvailableDialog();
    }
  }

  void showNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Estado no disponible",
            style: TextStyle(color: Color(0xFF245366)),
          ),
          content: const Text(
            "En este momento, lamentamos informarle que la aplicación no se encuentra disponible en este estado.",
            style: TextStyle(color: Color(0xFF245366)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar",
                  style: TextStyle(color: Color(0xFF245366))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void searchEstados(String text) {
    final filteredEstados = estados.where((estado) {
      return estado.toLowerCase().contains(text.toLowerCase());
    }).toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: double.maxFinite,
            child: ListView.separated(
              itemCount: filteredEstados.length,
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (context, index) {
                final estado = filteredEstados[index];
                return ListTile(
                  title: Text(
                    estado,
                    style: const TextStyle(
                        color: Color(0xFF245366), fontSize: 18.0),
                  ),
                  onTap: () {
                    final produccion = nodosPorEstado[estado]?['produccion'];
                    if (produccion is bool && !produccion) {
                      showNotAvailableDialog();
                    } else {
                      setState(() {
                        selectedEstado = estado;
                        selectedMunicipio = "";
                      });
                      estadoSearchController.clear();
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void searchMunicipios(String text) {
    if (selectedEstado.isNotEmpty &&
        nodosPorEstado.containsKey(selectedEstado)) {
      final municipios =
          nodosPorEstado[selectedEstado]?.values.where((municipio) {
        return municipio is String &&
            municipio.toLowerCase().contains(text.toLowerCase());
      }).toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: double.maxFinite,
              child: ListView.separated(
                itemCount: municipios!.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final municipio = municipios[index];
                  return ListTile(
                    title: Text(
                      municipio.toString(),
                      style: const TextStyle(
                          color: Color(0xFF245366), fontSize: 16.0),
                    ),
                    onTap: () {
                      setState(() {
                        selectedMunicipio = municipio.toString();
                      });
                      municipioSearchController.clear();
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } else {
      showNotAvailableDialog();
    }
  }
  ///////////////fin de estados y municipios////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller: estadoSearchController,
                              decoration: InputDecoration(
                                labelText: 'Buscar Estado',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF245366),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: const Color(0xFF90b1af),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: const Color(0xFF90b1af),
                                    width: 2.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search,
                                      color: const Color(0xFF90b1af)),
                                  onPressed: () {
                                    searchEstados(estadoSearchController.text);
                                  },
                                ),
                              ),
                              onChanged: (text) {
                                // No hacer nada aquí
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              "Estado Seleccionado: ",
                              style: TextStyle(
                                  color: Color(0xFF245366), fontSize: 14.0),
                            ),
                            subtitle: Text(
                              selectedEstado,
                              style: const TextStyle(
                                  color: Color(0xFF245366), fontSize: 18.0),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: const Color(0xFF90b1af)),
                              onPressed: () {
                                showEstadoList();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller: municipioSearchController,
                              decoration: InputDecoration(
                                labelText: 'Buscar Municipio',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF245366),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: const Color(0xFF90b1af),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: const Color(0xFF90b1af),
                                    width: 2.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search,
                                      color: const Color(0xFF90b1af)),
                                  onPressed: () {
                                    searchMunicipios(
                                        municipioSearchController.text);
                                  },
                                ),
                              ),
                              onChanged: (text) {
                                // No hacer nada aquí
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              "Municipio Seleccionado: ",
                              style: TextStyle(
                                  color: Color(0xFF245366), fontSize: 14.0),
                            ),
                            subtitle: Text(
                              selectedMunicipio,
                              style: const TextStyle(
                                  color: Color(0xFF245366), fontSize: 18.0),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: const Color(0xFF90b1af)),
                              onPressed: () {
                                showMunicipioList();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre(s)',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese su(s) nombre(s)';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _fatherLastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido Paterno',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _motherLastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido Materno',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese su número de teléfono';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        // Verificar si el campo contiene solo números
                        return 'Ingrese un número de teléfono válido';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Domicilio',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese su domicilio';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un correo electrónico';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Ingrese un correo electrónico válido";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      labelStyle: const TextStyle(color: Color(0xFF373c40)),
                      hintStyle: const TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF373c40),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una contraseña';
                      } else if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      } else if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'La contraseña debe contener al menos una letra mayúscula';
                      } else if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'La contraseña debe contener al menos una letra minúscula';
                      } else if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'La contraseña debe contener al menos un número';
                      } else if (!value
                          .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'La contraseña debe contener al menos un caracter especial';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF90b1af), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirme su contraseña',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      labelStyle: TextStyle(color: Color(0xFF373c40)),
                      hintStyle: TextStyle(color: Color(0xFF373c40)),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme su contraseña';
                      } else if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Color(0xFF373c40)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _register();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF1FBAAF), Color(0xFF1FBAAF)],
                      ),
                    ),
                    height: 50,
                    width: double.infinity,
                    child: const Center(
                      child: Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
