import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import '../../inicioUsuarios/cambiarContraseña.dart';
import '../../inicioUsuarios/login_screen.dart';

class Ajustes extends StatefulWidget {
  @override
  _AjustesState createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  bool _notificacionesActivas = true;
  String _photoUrl = "";
  String _userName = "";
  String _userPhone = "";
  String _userAddress = "";
  final _picker = ImagePicker();

  ////////////////parte de estados y municipios////////////////
  bool _isExpanded = false;
  String _userState = "";
  String _userMunicipality = "";
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
    _getCurrentUserData();
  }

  ////////////////////////////////////////////////////////////////
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

  void _getCurrentUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(userId)
        .get();
    final userPhone = userData.get('telefono') ?? 'N/A';
    final userAddress = userData.get('domicilio') ?? 'S/D';
    final userState = userData.get('estado') ?? 'S/S';
    final userMunicipality = userData.get('municipio') ?? 'S/M';
    setState(() {
      _photoUrl = userData.get('photoUrl') ?? '';
      final name = userData.get('nombre');
      final apellido1 = userData.get('primerApellido');
      final apellido2 = userData.get('segundoApellido');
      _userName = '$name $apellido1 $apellido2';
      _userPhone = userPhone;
      _userAddress = userAddress;
      _userState = userState;
      _userMunicipality = userMunicipality;
    });
  }

  Future<void> _uploadAndSetPhoto() async {
    final pickedFile = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.all(16.0), // Padding uniforme
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context,
                          _picker.getImage(source: ImageSource.gallery));
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.photo, color: Color(0xFF1FBAAF)),
                        Text(
                          'Galería',
                          style: TextStyle(color: Color(0xFF1FBAAF)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 32), // Espacio entre las opciones
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context,
                          _picker.getImage(source: ImageSource.camera));
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.camera, color: Color(0xFF1FBAAF)),
                        Text(
                          'Cámara',
                          style: TextStyle(color: Color(0xFF1FBAAF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0), // Espacio inferior
            ],
          ),
        );
      },
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final destination =
          'usuarios/pacientes/${FirebaseAuth.instance.currentUser!.uid}/photoUrl';

      final compressedFile =
          await FlutterNativeImage.compressImage(file.path, quality: 20);

      final uploadTask =
          FirebaseStorage.instance.ref(destination).putFile(compressedFile);
      await uploadTask.whenComplete(() => null);
      final photoUrl =
          await FirebaseStorage.instance.ref(destination).getDownloadURL();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('usuariopaciente')
          .doc(userId)
          .update({'photoUrl': photoUrl});

      setState(() {
        _photoUrl = photoUrl;
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pop(); // Cierra el diálogo cuando se toca fuera de la imagen.
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Image.network(
                        _photoUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top:
                          10, // Ajusta la posición vertical según tu preferencia
                      right:
                          10, // Ajusta la posición horizontal según tu preferencia
                      child: IconButton(
                        icon: Icon(Icons.close), // Icono "X"
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Cierra el diálogo cuando se presiona el icono "X".
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text('Modificar teléfono'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(hintText: 'Ingresa el nuevo teléfono'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Ingresa un número de teléfono';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateUserPhone(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text('Guardar', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showDialogAddress() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text('Modificar Domicilio'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(hintText: 'Ingresa nueva dirección'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Ingresa nueva dirección';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateUserAddress(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text('Guardar', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserPhone(String newPhone) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(userId)
        .update({'telefono': newPhone});

    setState(() {
      _userPhone = newPhone;
    });
  }

  Future<void> _updateUserAddress(String newAddress) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(userId)
        .update({'domicilio': newAddress});

    setState(() {
      _userAddress = newAddress;
    });
  }

  Future<void> _updateUserStateAndMunicipality(
      String newState, String newMunicipality) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userRef =
          FirebaseFirestore.instance.collection('usuariopaciente').doc(userId);

      await userRef.update({
        'estado': newState,
        'municipio': newMunicipality,
      });

      setState(() {
        _userState = newState;
        _userMunicipality = newMunicipality;
      });

      // Puedes agregar aquí una notificación o mensaje de éxito si lo deseas.
    } catch (error) {
      // Manejar errores, por ejemplo, mostrar una notificación de error.
      print("Error al actualizar estado y municipio: $error");
    }
  }

  void _navigateToChangePassword() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CambiarContrasena()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0),
            GestureDetector(
              onTap: () => _showImageDialog(),
              child: Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: _photoUrl.isNotEmpty
                          ? Image.network(
                              _photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Icon(Icons.person,
                                    size: 80, color: Colors.white);
                              },
                            )
                          : Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () => _uploadAndSetPhoto(),
              child: Center(
                child: Text(
                  "Cambiar foto",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF245366),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // Cambiar el color de la línea divisoria
              thickness: 1, // Ajustar el grosor de la línea divisoria
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teléfono: $_userPhone',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF245366),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Actualiza tu número de teléfono',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xFF1FBAAF), // Cambiar el color del ícono
                    ),
                    onPressed: () {
                      _showDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.grey, // Cambiar el color de la línea divisoria
              thickness: 1, // Ajustar el grosor de la línea divisoria
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Domicilio: $_userAddress',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF245366),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Actualiza tu dirección de domicilio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color:
                              Color(0xFF1FBAAF), // Cambiar el color del ícono
                        ),
                        onPressed: () {
                          _showDialogAddress();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.grey, // Cambiar el color de la línea divisoria
              thickness: 1, // Ajustar el grosor de la línea divisoria
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado: $_userState',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF245366),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Municipio: $_userMunicipality',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF245366),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Actualiza tu estado y municipio donde te encuentras actualmente para recibir servicios cercanos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actualizar estado y municipio',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1FBAAF),
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xFF1FBAAF),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  if (_isExpanded) // Mostrar el contenedor si _isExpanded es true
                    Container(
                      // Aquí puedes personalizar el contenido del contenedor
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFF4FCFB),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              color: const Color(0xFF90b1af),
                                              width: 2.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              color: const Color(0xFF90b1af),
                                              width: 2.0,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.search,
                                                color: const Color(0xFF90b1af)),
                                            onPressed: () {
                                              searchEstados(
                                                  estadoSearchController.text);
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
                                            color: Color(0xFF245366),
                                            fontSize: 14.0),
                                      ),
                                      subtitle: Text(
                                        selectedEstado,
                                        style: const TextStyle(
                                            color: Color(0xFF245366),
                                            fontSize: 18.0),
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
                                const SizedBox(height: 5.0),
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              color: const Color(0xFF90b1af),
                                              width: 2.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
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
                                                  municipioSearchController
                                                      .text);
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
                                            color: Color(0xFF245366),
                                            fontSize: 14.0),
                                      ),
                                      subtitle: Text(
                                        selectedMunicipio,
                                        style: const TextStyle(
                                            color: Color(0xFF245366),
                                            fontSize: 18.0),
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
                          SizedBox(height: 0), // Espacio adicional
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedEstado.isNotEmpty &&
                                    selectedMunicipio.isNotEmpty) {
                                  // Crea un retardo para ejecutar la actualización en un hilo de fondo
                                  Future.delayed(Duration.zero, () {
                                    _updateUserStateAndMunicipality(
                                      selectedEstado,
                                      selectedMunicipio,
                                    );

                                    // Cierra la expansión después de la actualización
                                    setState(() {
                                      _isExpanded = false;
                                    });
                                  });
                                } else {
                                  // Puedes mostrar un mensaje al usuario si no ha seleccionado un estado y municipio.
                                  // Por ejemplo: mostrar un AlertDialog con el mensaje "Por favor, seleccione un estado y un municipio".
                                }
                              },
                              child: Text(
                                'Actualizar',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF1FBAAF), // Color turquesa
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10.0), // Redondeo
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 5),           
            Divider(
              color: Colors.grey, // Cambiar el color de la línea divisoria
              thickness: 1, // Ajustar el grosor de la línea divisoria
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cambiar contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF245366),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Modifica tu contraseña de acceso',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xFF1FBAAF), // Cambiar el color del ícono
                    ),
                    onPressed: _navigateToChangePassword,
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.grey, // Cambiar el color de la línea divisoria
              thickness: 1, // Ajustar el grosor de la línea divisoria
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF245366),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Activa o desactiva las notificaciones',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _notificacionesActivas,
                    onChanged: (bool value) {
                      setState(() {
                        _notificacionesActivas = value;
                      });
                    },
                    activeColor:
                        Color(0xFF1FBAAF), // Cambia el color del interruptor
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.grey, // Cambiar el color de la línea divisoria
              thickness: 1,
            ),
            SizedBox(height: 15), // Aumenta el espacio vertical
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 241, 69, 69),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Redondeo de 10
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15, // Aumenta el tamaño vertical
                      horizontal: 138.3, // Aumenta el tamaño horizontal
                    ),
                  ),
                  child: Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _showLogoutDialog();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text('Cerrar sesión'),
        content: Text('¿Está seguro de que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.red)),
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
            child: Text('Sí', style: TextStyle(color: Color(0xFF1FBAAF))),
          ),
        ],
      ),
    );
  }
}
