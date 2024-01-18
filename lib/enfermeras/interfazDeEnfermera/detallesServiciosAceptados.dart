import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart'; // Importa Geolocator
import 'package:http/http.dart' as http; // Importa http
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DetallesServiciosAceptados extends StatelessWidget {
  final String servicio;
  final String fecha;
  final String categoria;
  final String tipoServicio;
  final String total;
  final String dia;
  final int diaDelMes;
  final String domicilio;
  final String estado;
  final String hora;
  final String icono;
  final String mes;
  final String nombre;
  final String photoUrl;
  final String tipoCategoria;
  final String idCita;
  final String pacienteId;
  final String enfermeraId;
  final GeoPoint ubicacionPaciente;

  String latitude = "";
  String longitude = "";

  DetallesServiciosAceptados({
    required this.servicio,
    required this.fecha,
    required this.categoria,
    required this.tipoServicio,
    required this.total,
    required this.dia,
    required this.diaDelMes,
    required this.domicilio,
    required this.estado,
    required this.hora,
    required this.icono,
    required this.mes,
    required this.nombre,
    required this.photoUrl,
    required this.tipoCategoria,
    required this.idCita,
    required this.pacienteId,
    required this.enfermeraId,
    required this.ubicacionPaciente,
  })  : latitude = ubicacionPaciente.latitude.toString(),
        longitude = ubicacionPaciente.longitude.toString();

  String locationName = "Obteniendo nombre del lugar...";

  Future<void> _getLocationName() async {
    try {
      final latitudesearch = latitude;
      final longitudeSearch = longitude;
      print("Latitud: $latitudesearch, Longitud: $longitudeSearch");

      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitudesearch&lon=$longitudeSearch'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Respuesta de la API: $data");
        String displayName = data['display_name'];
        locationName = displayName;
      } else {
        locationName = "Error al obtener el nombre del lugar.";
      }
    } catch (e) {
      locationName = "Error: $e";
    }
  }

  Future<void> _openInGoogleMaps() async {
    await FlutterWebBrowser.openWebPage(
      url: 'https://www.google.com/maps/search/?api=1&query=$domicilio',
    );
  }

  Future<void> _openInGoogleMapsRealtime() async {
    String encodedLocationName = Uri.encodeComponent(locationName);
    await FlutterWebBrowser.openWebPage(
      url:
          'https://www.google.com/maps/search/?api=1&query=$encodedLocationName',
    );
  }

  @override
  Widget build(BuildContext context) {
    String servicioDisplay =
        servicio.length > 30 ? servicio.substring(0, 30) + '...' : servicio;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del servicio',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF1FBAAF),
        toolbarHeight: kToolbarHeight - 10,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        elevation: 2.0,
      ),

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10), // Separación de 10

              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '$nombre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF245366),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 20.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 32, 204, 193)
                        .withOpacity(0.1), // Cambia a tu color específico
                    borderRadius: BorderRadius.circular(
                        10.0), // Ajusta el radio según tus necesidades
                  ),
                  // Cambia a tu color específico
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.network(
                          icono,
                          width: 24,
                          height: 24,
                          color: Color(0xFF245366),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$servicioDisplay',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF245366),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nivel de servicio: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                    ),
                  ),
                  Text(
                    '$tipoCategoria',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                    ),
                  ),
                  Text(
                    '$fecha',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hora: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                    ),
                  ),
                  Text(
                    '$hora',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Domicilio:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$domicilio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000328),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Color(0xFF1FBAAF),
                        ),
                        onPressed: () {
                          _openInGoogleMaps();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación actual:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<void>(
                          future:
                              _getLocationName(), // Llama a _getLocationName
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Text(
                                '$latitude, $longitude\n\n$locationName', // Utiliza el resultado en lugar de la función
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000328),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red, // Color rojo para errores
                                ),
                              );
                            } else {
                              return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el nombre del lugar
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Color(0xFF1FBAAF),
                        ),
                        onPressed: () {
                          _openInGoogleMapsRealtime();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\nTipo de servicio: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                    ),
                  ),
                  Text(
                    '$tipoServicio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000328),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ', // Agregamos el signo de pesos
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000328),
                    ),
                  ),
                  Text(
                    '\$$total', // Mostramos el total
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000328),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              BottomButtons(idCita: idCita), // botones fluidos
            ],
          ),
        ),
      ),

      //BottomButtons(idCita: idCita), // botones estaticos
    );
  }
}

class BottomButtons extends StatelessWidget {
  final String idCita;

  BottomButtons({
    required this.idCita,
  });

  Future<void> _cancelarServicio(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Eliminar la subcolección "salasChat"
        await FirebaseFirestore.instance
            .collection('citas')
            .doc(idCita)
            .collection('salasChat')
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((document) {
            document.reference.delete();
          });
        });

        // Actualizar el documento de "citas"
        await FirebaseFirestore.instance
            .collection('citas')
            .doc(idCita)
            .update({
          'estado': 'disponible',
          'enfermeraId': "",
        });

        Fluttertoast.showToast(
          msg: 'Servicio cancelado con éxito.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (error) {
        Fluttertoast.showToast(
          msg: 'Error al cancelar el servicio: $error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<void> _servicioAtendido(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Obtener el documento de "citas"
        DocumentSnapshot<Map<String, dynamic>> citaSnapshot =
            await FirebaseFirestore.instance
                .collection('citas')
                .doc(idCita)
                .get();

        // Transferir el documento a la colección "historial"
        await FirebaseFirestore.instance
            .collection('historial')
            .doc(idCita)
            .set(citaSnapshot.data() ?? {});

        // Eliminar el documento de la colección "citas"
        await FirebaseFirestore.instance
            .collection('citas')
            .doc(idCita)
            .delete();

        Fluttertoast.showToast(
          msg: 'Servicio atendido con éxito.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (error) {
        Fluttertoast.showToast(
          msg: 'Error al marcar el servicio como atendido: $error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () async {
                await launch("tel:911");
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      200), // Ajusta el valor para hacer el botón más redondo
                ),
                minimumSize: Size(150, 150),
              ),
              child: Text(
                'BOTÓN DE \nPÁNICO',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _servicioAtendido(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF1FBAAF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(300, 50),
              ),
              child: Text(
                'Servicio terminado',
                style: TextStyle(
                    fontSize:
                        20, // Ajusta el tamaño de la fuente según tus preferencias
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white // Puedes agregar negrita u otras propiedades según tus necesidades
                    ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _cancelarServicio(
                    context); // Llama a la función para cancelar el servicio
                Navigator.pop(context); // Cierra la pantalla actual
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(300, 50),
              ),
              child: Text(
                'Cancelar servicio',
                style: TextStyle(
                    fontSize:
                        20, // Ajusta el tamaño de la fuente según tus preferencias
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white // Puedes agregar negrita u otras propiedades según tus necesidades
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
