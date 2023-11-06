import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geolocator/geolocator.dart'; // Importa Geolocator
import 'package:http/http.dart' as http; // Importa http
import 'dart:convert';

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
  }): latitude = ubicacionPaciente.latitude.toString(),
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
    url: 'https://www.google.com/maps/search/?api=1&query=$encodedLocationName',
  );
}


  @override
  Widget build(BuildContext context) {
    String servicioDisplay =
        servicio.length > 30 ? servicio.substring(0, 30) + '...' : servicio;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Servicio'),
        backgroundColor: Color(0xFF1FBAAF),
      ),
      backgroundColor: Color(0xFFF4FCFB),
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
                      color: Color(0xFF000328),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  SvgPicture.network(
                    icono,
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$servicioDisplay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000328),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Text(
                'Categoría: $tipoCategoria',
                style: TextStyle(
                  fontSize: 16, // Tamaño de fuente 13
                  color: Color(0xFF000328),
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Fecha: $fecha',
                style: TextStyle(
                  fontSize: 16, // Tamaño de fuente 13
                  color: Color(0xFF000328),
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Horario: $hora',
                style: TextStyle(
                  fontSize: 16, // Tamaño de fuente 13
                  color: Color(0xFF000328),
                ),
              ),

              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación del paciente:',
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

              Text(
                'Tipo de Servicio: $tipoServicio',
                style: TextStyle(
                  fontSize: 16, // Tamaño de fuente 13
                  color: Color(0xFF000328),
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Total: \$', // Agregamos el signo de pesos
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000328),
                    ),
                  ),
                  Text(
                    '$total', // Mostramos el total
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF000328),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomButtons(idCita: idCita),
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

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Servicio cancelado con éxito.'),
        ));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cancelar el servicio: $error'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF4FCFB),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _cancelarServicio(
                    context); // Llama a la función para cancelar el servicio
                Navigator.pop(context); // Cierra la pantalla actual
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFF19162),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(300, 40),
              ),
              child: Text('Cancelar Servicio'),
            ),
          ],
        ),
      ),
    );
  }
}
