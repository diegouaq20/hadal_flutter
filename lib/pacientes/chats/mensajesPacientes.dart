import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MensajesPacientes extends StatefulWidget {
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
  final String enfermeraId;
  final String pacienteId;

  MensajesPacientes({
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
    required this.enfermeraId,
    required this.pacienteId,
  });

  @override
  _MensajesPacientesState createState() => _MensajesPacientesState();
}

class _MensajesPacientesState extends State<MensajesPacientes> {
  late List<Map<String, dynamic>> _salasChatData = [];
  late TextEditingController _mensajeController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate().toLocal();
    int hour = dateTime.hour;
    String period = 'AM';

    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    }

    final minute = dateTime.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadSalasChatData();
    _initializeLocalNotifications();

    Future.delayed(Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initializeLocalNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );
  }

  Future<void> _onSelectNotification(String? payload) async {}

  Future<void> _loadSalasChatData() async {
  final citasRef = FirebaseFirestore.instance.collection('citas');
  final citaDoc = await citasRef.doc(widget.idCita).get();

  if (citaDoc.exists) {
    final salasChatCollection = citaDoc.reference.collection('salasChat');

    // Observador de Firebase Firestore
    salasChatCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      final salasChatData =
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        _salasChatData = salasChatData;
      });

      // Agregar notificación local aquí cuando llegue un nuevo mensaje
      if (querySnapshot.docChanges.isNotEmpty &&
          querySnapshot.docChanges.first.type == DocumentChangeType.added) {
        final nuevoMensaje = querySnapshot.docChanges.first.doc.data();
        final idDelRemitente = (nuevoMensaje as Map<String, dynamic>)['id'] as String?;

        // Añadir condición para mostrar la notificación solo si el mensaje es de la enfermera
        if (idDelRemitente != widget.pacienteId) {
          _showNotification("Nuevo mensaje", "Se ha recibido un nuevo mensaje.");
        }
      }
    });
  }
}


  void _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Channel',
      'Notificaciones de chat',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    /*await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'new_message',
    );*/
  }

  Future<void> _enviarMensaje() async {
    String mensajeTexto = _mensajeController.text.trim();
    if (mensajeTexto.isNotEmpty) {
      await _firestore
          .collection('citas')
          .doc(widget.idCita)
          .collection('salasChat')
          .add({
        'id': widget.pacienteId,
        'texto': mensajeTexto,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _mensajeController.clear();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sala de chat'),
        backgroundColor: Color(0xFF1FBAAF),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF4FCFB),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('citas')
                  .doc(widget.idCita)
                  .collection('salasChat')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final mensajes = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final mensajeData =
                        mensajes[index].data() as Map<String, dynamic>;
                    final texto = mensajeData['texto'] as String;
                    final id = mensajeData['id'] as String;
                    final timestamp = mensajeData.containsKey('timestamp')
                        ? mensajeData['timestamp']
                        : null;

                    final esUsuario = id == widget.enfermeraId;

                    return Align(
                      alignment:
                          esUsuario ? Alignment.topLeft : Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          10.0,
                          index == 0 ? 10.0 : 0.0,
                          10.0,
                          0.0,
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: esUsuario
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    )
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                    ),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                color: esUsuario
                                    ? Color.fromARGB(255, 122, 120, 120)
                                    : Color.fromARGB(255, 0, 128, 115),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      texto,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    if (timestamp != null &&
                                        timestamp is Timestamp)
                                      Text(
                                        _formatTimestamp(timestamp),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _mensajeController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Mensaje',
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: 0,
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _enviarMensaje,
                    color: Colors.teal,
                    iconSize: 32.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}