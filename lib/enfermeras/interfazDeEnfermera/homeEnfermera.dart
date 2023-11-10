import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:hadal/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadal/enfermeras/interfazDeEnfermera/detallesServicios.dart';
import 'package:hadal/enfermeras/interfazDeEnfermera/detallesServiciosAceptados.dart';

class HomeEnfermera extends StatefulWidget {
  @override
  _HomeEnfermeraState createState() => _HomeEnfermeraState();
}

class _HomeEnfermeraState extends State<HomeEnfermera> {
  String nombre = "";
  String primerApellido = "";
  String segundoApellido = "";
  String tipoUsuario = "";
  String categoria = "";
  bool showContent = false;
  bool recepcionActivada = true;
  GeoPoint? ubicacion;
  double? distanciaCita;
  double? distanciaBarra;
  String locationName = "Obteniendo nombre del lugar...";

  late User _currentUser;

  Timer? locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _getUserData();
    _loadSavedState();
    startLocationUpdateTimer();
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  void startLocationUpdateTimer() {
    const Duration updateInterval = const Duration(seconds: 10);
    locationUpdateTimer = Timer.periodic(updateInterval, (Timer t) {
      updateLocation();
    });
  }

  Future<void> _loadSavedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedState = prefs.getBool('recepcionActivada') ?? true;
    setState(() {
      recepcionActivada = savedState;
    });
  }

  Future<void> _saveState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recepcionActivada', value);
  }

  void _getUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('usuarioenfermera')
        .doc(_currentUser.uid)
        .get();

    setState(() {
      nombre = docSnapshot.get('nombre') ?? "";
      primerApellido = docSnapshot.get('primerApellido') ?? "";
      segundoApellido = docSnapshot.get('segundoApellido') ?? "";
      tipoUsuario = docSnapshot.get('tipoUsuario') ?? "";
      categoria = docSnapshot.get('categoria') ?? "";
      ubicacion = docSnapshot.get('ubicacion'); 
      distanciaBarra = docSnapshot.get('distancia');
      showContent = true;
    });
  }

  Future<void> _getLocationName() async {
    try {
      final latitudesearch = ubicacion!.latitude.toString();
      final longitudeSearch = ubicacion!.longitude.toString();

      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitudesearch&lon=$longitudeSearch'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String displayName = data['display_name'];
        locationName = displayName;
      } else {
        locationName = "Error al obtener el nombre del lugar.";
      }
    } catch (e) {
      locationName = "Error: $e";
    }
  }

  Stream<List<QueryDocumentSnapshot<Object?>>> _getCitasStream(String estado) {
    final citasRef = FirebaseFirestore.instance.collection('citas');

    return citasRef
        .where('estado', isEqualTo: estado)
        .where('tipoCategoria', whereIn: [
          categoria,
          if (categoria == 'Intermedio') 'Basico',
          if (categoria == 'Avanzado') 'Basico',
          if (categoria == 'Avanzado') 'Intermedio',
        ])
        .snapshots()
        .asyncMap((querySnapshot) async {
          final userLocation = await _getUserLocation();

          final filteredCitas = querySnapshot.docs.where((citaDoc) {
            final ubicacionPaciente =
                citaDoc.get('ubicacionPaciente') as GeoPoint?;
            if (ubicacionPaciente != null) {
              final distance =
                  _calculateDistance(userLocation, ubicacionPaciente);
              distanciaCita = distance;
              return distance <= distanciaBarra!;
            }
            return false;
          }).toList();

          return filteredCitas;
        });
  }

  Future<GeoPoint?> _getUserLocation() async {
    try {
      final userEnfermeraSnapshot = await FirebaseFirestore.instance
          .collection('usuarioenfermera')
          .doc(_currentUser.uid)
          .get();

      if (userEnfermeraSnapshot.exists) {
        return userEnfermeraSnapshot.get('ubicacion') as GeoPoint?;
      }
    } catch (error) {
      print('Error al obtener la ubicación del usuarioenfermera: $error');
    }

    return null;
  }

  double _calculateDistance(GeoPoint? point1, GeoPoint? point2) {
    if (point1 == null || point2 == null) {
      return double.infinity;
    }

    const radius = 6371;

    final lat1 = point1.latitude * pi / 180;
    final lon1 = point1.longitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final lon2 = point2.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = radius * c;

    return distance;
  }

  Stream<QuerySnapshot> _getMisCitasStream() {
    final citasRef = FirebaseFirestore.instance.collection('citas');

    return citasRef
        .where('enfermeraId', isEqualTo: _currentUser.uid)
        .snapshots();
  }

  Future<void> _showLocationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ubicación Actual'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarioenfermera')
                    .doc(_currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    final document = snapshot.data;
                    if (document != null && document.exists) {
                      final ubicacion = document['ubicacion'] as GeoPoint?;
                      if (ubicacion != null) {
                        final latitude = ubicacion.latitude;
                        final longitude = ubicacion.longitude;
                        return Text(
                          'Ubicación: Latitud $latitude, Longitud $longitude',
                          style: TextStyle(
                              fontSize: 18, color: Color(0xFF245366)),
                        );
                      }
                    }
                  }
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<void>(
                future: _getLocationName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      '$locationName',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF000328),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        LocationPermission permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          double latitude = position.latitude;
          double longitude = position.longitude;

          final enfermeraDoc = await FirebaseFirestore.instance
              .collection('usuarioenfermera')
              .doc(user.uid)
              .get();

          if (enfermeraDoc.exists) {
            await enfermeraDoc.reference.update({
              'ubicacion': GeoPoint(latitude, longitude),
            });
          }
        } else {
          showDialog(
            context: navigatorKey.currentState!.overlay!.context,
            barrierDismissible: false,
            builder: (context) {
              return CustomAlertDialog(
                title: 'Permisos de Ubicación',
                content:
                    'Se requiere acceso a la ubicación para utilizar esta aplicación. Por favor, conceda los permisos de ubicación en la configuración de su dispositivo y vuelva a iniciar la aplicación.',
                borderColor: Colors.teal,
                borderRadius: 20,
                titleTextColor: Colors.teal,
                contentTextColor: Colors.black,
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error actualizando la ubicación: $e');

      showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        barrierDismissible: false,
        builder: (context) {
          return CustomAlertDialog(
            title: 'Encender GPS',
            content:
                'Para utilizar esta aplicación, debe encender el GPS de su dispositivo. Por favor, encienda el GPS y vuelva a iniciar la aplicación.',
            borderColor: Colors.teal,
            borderRadius: 20,
            titleTextColor: Colors.teal,
            contentTextColor: Colors.black,
          );
        },
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      body: AnimatedOpacity(
        opacity: showContent ? 1.0 : 0.0,
        duration: Duration(milliseconds: 700),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(0.0), // Agrega padding
          child: Column(
            children: [
              if (nombre.isNotEmpty &&
                  primerApellido.isNotEmpty &&
                  segundoApellido.isNotEmpty &&
                  tipoUsuario.isNotEmpty)
                Container(
                  color: Color(0xFFCFE3E1),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 3; i++)
                            Expanded(
                              flex: i == 1 ? 2 : 1,
                              child: i == 1
                                  ? Image.asset(
                                      'assets/logoInicio.png',
                                      width: 130,
                                      height: 130,
                                    )
                                  : Container(),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          for (String field in [
                            'BIENVENIDO',
                            '$nombre $primerApellido $segundoApellido',
                            '$tipoUsuario'
                          ])
                            FittedBox(
                              child: Text(
                                field,
                                style: TextStyle(
                                    fontSize:
                                        field.contains('BIENVENIDO') ? 18 : 28,
                                    color: Color(0xFF245366)),
                              ),
                            ),
                          if (ubicacion !=
                              null) // Verifica si la ubicación no es nula
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('usuarioenfermera')
                                  .doc(_currentUser.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.active) {
                                  final document = snapshot.data;
                                  if (document != null && document.exists) {
                                    final ubicacion = document['ubicacion'] as GeoPoint?;
                                    if (ubicacion != null) {
                                      final latitude = ubicacion.latitude;
                                      final longitude = ubicacion.longitude;
                                      return Text(
                                        'Ubicación: Latitud $latitude, Longitud $longitude',
                                        style: TextStyle(fontSize: 18, color: Color(0xFF245366)),
                                      );
                                    }
                                  }
                                }
                                return CircularProgressIndicator();
                              },
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
  padding: EdgeInsets.only(left: 15, right: 25), // Ajusta el padding según sea necesario
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Coloca los elementos al principio y al final del Row
    children: [
      Row(
        children: [
          Switch(
            activeColor: Color(0xFF1FBAAF),
            inactiveThumbColor: Colors.grey,
            value: recepcionActivada,
            onChanged: (value) {
              setState(() {
                recepcionActivada = value;
                _saveState(value);
              });
            },
          ),
          Text(
            recepcionActivada ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: 18,
              color: recepcionActivada
                  ? Color(0xFF245366)
                  : Colors.grey,
            ),
          ),
        ],
      ),
      InkWell(
        onTap: () {
          _showLocationDialog(); // Función para mostrar el diálogo
        },
        child: Text(
          'Ubicación actual',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF245366),
          ),
        ),
      ),
    ],
  ),
),


              if (recepcionActivada)
                Container(
                  padding: EdgeInsets.only(left: 25, bottom: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Servicios Disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF245366),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (recepcionActivada)
                StreamBuilder<List<QueryDocumentSnapshot<Object?>>>(
                  stream: _getCitasStream('disponible'),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error al cargar las citas'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Text(
                            'No hay servicios disponibles',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final citasDisponibles = snapshot.data!;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: citasDisponibles.map((citaDoc) {
                          final servicio = citaDoc.get('servicio');
                          final servicioRecortado = servicio.length > 15
                              ? servicio.substring(0, 15) + '...'
                              : servicio;
                          final iconoUrl = citaDoc.get('icono');
                          final tipoServicio = citaDoc.get('tipoServicio');
                          final dia = citaDoc.get('dia');
                          final diaDelMes = citaDoc.get('diaDelMes');
                          final domicilio = citaDoc.get('domicilio');
                          final estado = citaDoc.get('estado');
                          final hora = citaDoc.get('hora');
                          final mes = citaDoc.get('mes');
                          final nombre = citaDoc.get('nombre');
                          final photoUrl = citaDoc.get('photoUrl');
                          final tipoCategoria = citaDoc.get('tipoCategoria');
                          final total = citaDoc.get('total').toString();
                          final enfermeraId = citaDoc.get('enfermeraId');
                          final pacienteId = citaDoc.get('pacienteId');
                          //final ubicacionEnfermera = citaDoc.get('ubicacionEnfermera');
                          final ubicacionPaciente =
                              citaDoc.get('ubicacionPaciente');

                          return GestureDetector(
                            onTap: () {
                              if (estado == 'disponible') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetallesServiciosPage(
                                      dia: dia,
                                      diaDelMes: diaDelMes,
                                      domicilio: domicilio,
                                      estado: estado,
                                      hora: hora,
                                      icono: iconoUrl,
                                      mes: mes,
                                      nombre: nombre,
                                      photoUrl: photoUrl,
                                      servicio: servicio,
                                      tipoCategoria: tipoCategoria,
                                      tipoServicio: tipoServicio,
                                      total: total,
                                      fecha: '$dia, $diaDelMes de $mes',
                                      categoria: 'Servicio $tipoCategoria',
                                      idCita: citaDoc.id,
                                      enfermeraId: enfermeraId,
                                      pacienteId: pacienteId,
                                      //ubicacionEnfermera: ubicacionEnfermera,
                                      ubicacionPaciente: ubicacionPaciente,
                                    ),
                                  ),
                                );
                              } else if (estado == 'aceptado') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetallesServiciosAceptados(
                                      dia: dia,
                                      diaDelMes: diaDelMes,
                                      domicilio: domicilio,
                                      estado: estado,
                                      hora: hora,
                                      icono: iconoUrl,
                                      mes: mes,
                                      nombre: nombre,
                                      photoUrl: photoUrl,
                                      servicio: servicio,
                                      tipoCategoria: tipoCategoria,
                                      tipoServicio: tipoServicio,
                                      total: total,
                                      fecha: '$dia, $diaDelMes de $mes',
                                      categoria: 'Servicio $tipoCategoria',
                                      idCita: citaDoc.id,
                                      enfermeraId: enfermeraId,
                                      pacienteId: pacienteId,
                                      ubicacionPaciente: ubicacionPaciente,
                                      //ubicacionEnfermera: ubicacionEnfermera,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  margin: EdgeInsets.symmetric(
    horizontal: 10, vertical: 10),
  child: Container(
    width: 170,
    height: 160,
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          child: iconoUrl != null
              ? SvgPicture.network(
            iconoUrl,
            width: 48,
            height: 48,
          )
              : Icon(Icons.info_outline, size: 48),
        ),
        SizedBox(height: 10),
        Text(
          servicioRecortado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF235365),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          '${distanciaCita?.toStringAsFixed(2)} km', // Aquí muestra la distancia
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 30, vertical: 4),
            color: tipoServicio == "Urgente"
                ? Colors.red
                : Color(0xFF1FBAAF),
            child: Center(
              child: Text(
                tipoServicio,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              Container(
                padding: EdgeInsets.only(left: 25, top: 10, bottom: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mis Citas Aceptadas',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF245366),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _getMisCitasStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar las citas aceptadas'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                50), // Ajusta el valor del padding vertical
                        child: Text(
                          'No hay servicios aceptados.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final misCitas = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: misCitas.map((citaDoc) {
                        final servicio = citaDoc.get('servicio');
                        final servicioRecortado = servicio.length > 15
                            ? servicio.substring(0, 15) + '...'
                            : servicio;
                        final iconoUrl = citaDoc.get('icono');
                        final tipoServicio = citaDoc.get('tipoServicio');
                        final dia = citaDoc.get('dia');
                        final diaDelMes = citaDoc.get('diaDelMes');
                        final domicilio = citaDoc.get('domicilio');
                        final estado = citaDoc.get('estado');
                        final hora = citaDoc.get('hora');
                        final mes = citaDoc.get('mes');
                        final nombre = citaDoc.get('nombre');
                        final photoUrl = citaDoc.get('photoUrl');
                        final tipoCategoria = citaDoc.get('tipoCategoria');
                        final total = citaDoc.get('total').toString();
                        final enfermeraId = citaDoc.get('enfermeraId');
                        final pacienteId = citaDoc.get('pacienteId');
                        //final ubicacionEnfermera = citaDoc.get('ubicacionEnfermera');
                        final ubicacionPaciente =
                            citaDoc.get('ubicacionPaciente');

                        return GestureDetector(
                          onTap: () {
                            if (estado == 'disponible') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetallesServiciosPage(
                                    dia: dia,
                                    diaDelMes: diaDelMes,
                                    domicilio: domicilio,
                                    estado: estado,
                                    hora: hora,
                                    icono: iconoUrl,
                                    mes: mes,
                                    nombre: nombre,
                                    photoUrl: photoUrl,
                                    servicio: servicio,
                                    tipoCategoria: tipoCategoria,
                                    tipoServicio: tipoServicio,
                                    total: total,
                                    fecha: '$dia, $diaDelMes de $mes',
                                    categoria: 'Servicio $tipoCategoria',
                                    idCita: citaDoc.id,
                                    enfermeraId: enfermeraId,
                                    pacienteId: pacienteId,
                                    //ubicacionEnfermera: ubicacionEnfermera,
                                    ubicacionPaciente: ubicacionPaciente,
                                  ),
                                ),
                              );
                            } else if (estado == 'aceptado') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetallesServiciosAceptados(
                                    dia: dia,
                                    diaDelMes: diaDelMes,
                                    domicilio: domicilio,
                                    estado: estado,
                                    hora: hora,
                                    icono: iconoUrl,
                                    mes: mes,
                                    nombre: nombre,
                                    photoUrl: photoUrl,
                                    servicio: servicio,
                                    tipoCategoria: tipoCategoria,
                                    tipoServicio: tipoServicio,
                                    total: total,
                                    fecha: '$dia, $diaDelMes de $mes',
                                    categoria: 'Servicio $tipoCategoria',
                                    idCita: citaDoc.id,
                                    enfermeraId: enfermeraId,
                                    pacienteId: pacienteId,
                                    ubicacionPaciente: ubicacionPaciente,
                                    //ubicacionEnfermera: ubicacionEnfermera,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  margin: EdgeInsets.symmetric(
    horizontal: 10, vertical: 10),
  child: Container(
    width: 170,
    height: 160,
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          child: iconoUrl != null
              ? SvgPicture.network(
            iconoUrl,
            width: 48,
            height: 48,
          )
              : Icon(Icons.info_outline, size: 48),
        ),
        SizedBox(height: 10),
        Text(
          servicioRecortado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF235365),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          '${distanciaCita?.toStringAsFixed(2)} km', // Aquí muestra la distancia
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 30, vertical: 4),
            color: tipoServicio == "Urgente"
                ? Colors.red
                : Color(0xFF1FBAAF),
            child: Center(
              child: Text(
                tipoServicio,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}