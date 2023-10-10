import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/pacientes/chats/mensajesPacientes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SalasPrivadasPacientes extends StatefulWidget {
  @override
  _SalasPrivadasPacientesState createState() =>
      _SalasPrivadasPacientesState();
}

class _SalasPrivadasPacientesState extends State<SalasPrivadasPacientes> {
  String nombre = "";
  String primerApellido = "";
  String segundoApellido = "";
  String tipoUsuario = "";

  late User _currentUser;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _getUserData();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Configura un canal de notificación
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_channel_id', // Debe coincidir con el canal definido en AndroidManifest.xml
      'Canal de notificaciones de chat',
      'Canal de notificaciones para los chats de la aplicación',
      importance: Importance.high,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(),
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        // Maneja la acción cuando se toca una notificación
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(_currentUser.uid)
        .get();

    setState(() {
      nombre = docSnapshot.get('nombre') ?? "";
      primerApellido = docSnapshot.get('primerApellido') ?? "";
      segundoApellido = docSnapshot.get('segundoApellido') ?? "";
      tipoUsuario = docSnapshot.get('tipoUsuario') ?? "";
    });
  }

  Stream<QuerySnapshot> _getMisCitasStream() {
    final citasRef = FirebaseFirestore.instance.collection('citas');

    return citasRef
        .where('pacienteId', isEqualTo: _currentUser.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nombre.isNotEmpty &&
              primerApellido.isNotEmpty &&
              segundoApellido.isNotEmpty &&
              tipoUsuario.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Lista de chats',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF245366),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMisCitasStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar las citas aceptadas'),
                  );
                }

                if (!snapshot.hasData) {
                  return Center();
                }

                final misCitas = snapshot.data!.docs;
                if (misCitas.isEmpty) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No tienes chats para mostrar.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: misCitas.length,
                  itemBuilder: (context, index) {
                    final citaDoc = misCitas[index];
                    final servicio = citaDoc.get('servicio');
                    final servicioRecortado = servicio.length > 15
                        ? servicio.substring(0, 15) + '...'
                        : servicio;
                    final iconoUrl = citaDoc.get('icono');
                    final tipoServicio = citaDoc.get('tipoServicio');
                    final dia = citaDoc.get('dia');
                    final diaDelMes = citaDoc.get('diaDelMes');
                    final domicilio = citaDoc.get('domicilio');
                    final enfermeraId = citaDoc.get('enfermeraId');
                    final estado = citaDoc.get('estado');
                    final hora = citaDoc.get('hora');
                    final mes = citaDoc.get('mes');
                    final nombre = citaDoc.get('nombre');
                    final pacienteId = citaDoc.get('pacienteId');
                    final photoUrl = citaDoc.get('photoUrl');
                    final tipoCategoria = citaDoc.get('tipoCategoria');
                    final total = citaDoc.get('total').toString();

                    return FutureBuilder<DocumentSnapshot?>(
                      future: enfermeraId != null && enfermeraId.isNotEmpty
                          ? FirebaseFirestore.instance
                              .collection('usuarioenfermera')
                              .doc(enfermeraId)
                              .get()
                          : Future.value(null),
                      builder: (context, enfermeraSnapshot) {
                        if (enfermeraSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Muestra un indicador de carga mientras se espera la consulta.
                          
                        }

                        final enfermeraPhotoUrl =
                            enfermeraSnapshot.data?.get('photoUrl');

                        // Verificar si enfermeraId no está vacío o nulo.
                        if (enfermeraId != null && enfermeraId.isNotEmpty && enfermeraId != "") {
                          return GestureDetector(
                            onTap: () {
                              if (estado == 'disponible' ||
                                  estado == 'aceptado') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MensajesPacientes(
                                      dia: dia,
                                      diaDelMes: diaDelMes,
                                      domicilio: domicilio,
                                      enfermeraId: enfermeraId,
                                      estado: estado,
                                      hora: hora,
                                      icono: iconoUrl,
                                      mes: mes,
                                      nombre: nombre,
                                      pacienteId: pacienteId,
                                      photoUrl: photoUrl,
                                      servicio: servicio,
                                      tipoCategoria: tipoCategoria,
                                      tipoServicio: tipoServicio,
                                      total: total,
                                      fecha: '$dia, $diaDelMes de $mes',
                                      categoria: 'Servicio $tipoCategoria',
                                      idCita: citaDoc.id,
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
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor:
                                      Color(0xFF235365), // Color de fondo
                                  backgroundImage: enfermeraPhotoUrl != null
                                      ? NetworkImage(enfermeraPhotoUrl)
                                      : null,
                                  child: enfermeraPhotoUrl == null
                                      ? Icon(Icons.person,
                                          size: 20,
                                          color: Colors
                                              .white) // Icono de perfil predeterminado
                                      : null,
                                ),
                                title: Text(
                                  servicioRecortado,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF235365),
                                  ),
                                ),
                                subtitle: Text(
                                  tipoServicio,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Si enfermeraId está vacío o nulo, no construir la tarjeta.
                          return SizedBox.shrink();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
