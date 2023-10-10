import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:hadal/pacientes/perfilDatos/inePaciente.dart';

class PerfilPaciente extends StatefulWidget {
  @override
  _PerfilPacienteState createState() => _PerfilPacienteState();
}

class _PerfilPacienteState extends State<PerfilPaciente> {
  void _getCurrentUserPhotoUrl() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(userId)
        .get();
    setState(() {});
  }

  File? _image;

  @override
  void initState() {
    super.initState();
    _getCurrentUserPhotoUrl();
  }

  Future<void> _selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.teal,
                width: 2.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Subir imagen desde:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedFile != null) {
                              final File file = File(pickedFile.path);
                              final File compressedFile =
                                  await FlutterNativeImage.compressImage(
                                file.path,
                                quality: 20,
                              );
                              setState(() {
                                _image = compressedFile;
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.photo, color: Colors.teal),
                        ),
                        Text("Galería", style: TextStyle(color: Colors.teal)),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.camera);
                            if (pickedFile != null) {
                              final File file = File(pickedFile.path);
                              final File compressedFile =
                                  await FlutterNativeImage.compressImage(
                                file.path,
                                quality: 20,
                              );
                              setState(() {
                                _image = compressedFile;
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.camera_alt, color: Colors.teal),
                        ),
                        Text("Cámara", style: TextStyle(color: Colors.teal)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _uploadImage() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance
          .ref("usuarios/pacientes")
          .child(userId)
          .child("photoUrl");
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() => null);
      final String downloadUrl = await storageReference.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('usuariopaciente')
          .doc(userId)
          .update({'photoUrl': downloadUrl});
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => InePaciente()));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4FCFB),
        title: Text(
          'Perfil',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        toolbarHeight: kToolbarHeight - 15,
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
        padding: EdgeInsets.all(16.0),
        child: Card(
          color: Color(0xFFF4FCFB),
          margin: EdgeInsets.all(35),
          elevation: 5,
          shadowColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: 20.0, top: 20.0, bottom: 20.0, right: 20),
                        child: Text(
                          "Perfil",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF235365),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 10.0, bottom: 20.0, right: 30),
                        child: CircleAvatar(
                          radius: 70.0,
                          backgroundColor: Colors.grey,
                          child: _image == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40.0,
                                  color: Colors.white,
                                )
                              : null,
                          backgroundImage:
                              _image == null ? null : FileImage(_image!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 10.0, bottom: 20.0, right: 30),
                        child: ElevatedButton(
                          onPressed: _selectImage,
                          child:
                              Text('Subir', style: TextStyle(fontSize: 18.0)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 30),
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            primary: Color(0xFF1FBAAF),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 10.0, bottom: 20.0, right: 30),
                        color: Color(0xFFF4FCFB),
                        child: Text(
                          "Esta fotografía aparecerá en tu perfil y será con la que te conozcan los enfermeros.\n\nEncuentra un lugar con buena iluminación y toma en cuenta los siguientes requisitos:\n\n- Fondo liso de color claro\n- Cara descubierta\n- Sin accesorios (anillos, collares, aretes, pasadores)",
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 10.0, bottom: 20.0, right: 30),
                        child: ElevatedButton(
                          onPressed: _uploadImage,
                          child: Text('Siguiente',
                              style: TextStyle(fontSize: 18.0)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 30),
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            primary: Color(0xFF1FBAAF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
