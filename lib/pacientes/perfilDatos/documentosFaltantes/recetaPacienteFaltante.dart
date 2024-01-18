import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hadal/pacientes/perfilDatos/enEspera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:file_picker/file_picker.dart';

class RecetaPacienteFaltante extends StatefulWidget {
  @override
  _RecetaPacienteFaltanteState createState() => _RecetaPacienteFaltanteState();
}

class _RecetaPacienteFaltanteState extends State<RecetaPacienteFaltante> {
  void _getCurrentUserPhotoUrl() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(userId)
        .get();
    setState(() {});
  }

  File? _selectedFile;
  String _selectedFileType = '';

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
                    "Subir archivo desde:",
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
                                _selectedFile = compressedFile;
                                _selectedFileType = 'Imagen';
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
                                _selectedFile = compressedFile;
                                _selectedFileType = 'Imagen';
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.camera_alt, color: Colors.teal),
                        ),
                        Text("Cámara", style: TextStyle(color: Colors.teal)),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );

                            if (result != null) {
                              setState(() {
                                _selectedFile = File(result.files.single.path!);
                                _selectedFileType = 'PDF';
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.picture_as_pdf, color: Colors.teal),
                        ),
                        Text("Subir PDF", style: TextStyle(color: Colors.teal)),
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

  void _uploadFile(dynamic file) async {
    try {
      if (file != null) {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        Reference storageReference = FirebaseStorage.instance
            .ref("usuarios/pacientes")
            .child(userId)
            .child("receta");

        final extension = file is File ? file.path.split('.').last : 'pdf';

        UploadTask uploadTask = storageReference.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;

        final url = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('usuariopaciente')
            .doc(userId)
            .update({'receta': url});

        Navigator.of(context).pop();

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FFFE),
      appBar: AppBar(
        backgroundColor: Color(0xFF1FBAAF),
        title: Text(
          'Documentos',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: kToolbarHeight - 15,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
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
          surfaceTintColor: Colors.white,
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
                          "Receta",
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
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.black12,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _selectedFile != null
                                  ? Icon(
                                      Icons.check_circle_outline,
                                      size: 70.0,
                                      color: Color(0xFF1FBAAF),
                                    )
                                  : Icon(
                                      Icons.folder,
                                      size: 70.0,
                                      color: Color(0xFF1FBAAF),
                                    ),
                              SizedBox(height: 8),
                              Text(
                                _selectedFileType,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1FBAAF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 10.0, bottom: 20.0, right: 30),
                        child: ElevatedButton(
                          onPressed: _selectImage,
                          child: Text('Subir',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white)),
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
                        color: Colors.white,
                        child: Text(
                          "Se solicita este documento de documentación oficial para corroborar su identidad así como corroborar la autenticidad de los demás documentos proporcionados.\n\nFormato JPG, PNG o PDF requerido.\n\nFAVOR DE TOMAR UNA FOTO LEGIBLE.",
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 10.0, bottom: 20.0, right: 30),
                        child: ElevatedButton(
                          onPressed: () => _uploadFile(_selectedFile),
                          child: Text('Aceptar',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white)),
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
