import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MensajesEnfermeras extends StatefulWidget {
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

  MensajesEnfermeras({
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
  _MensajesEnfermerasState createState() => _MensajesEnfermerasState();
}

class _MensajesEnfermerasState extends State<MensajesEnfermeras> {
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

  @override
  void initState() {
    super.initState();
    _loadSalasChatData();

    // Retrasar la animación hasta que la vista de desplazamiento esté construida
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

  Future<void> _loadSalasChatData() async {
    final citasRef = FirebaseFirestore.instance.collection('citas');
    final citaDoc = await citasRef.doc(widget.idCita).get();

    if (citaDoc.exists) {
      final salasChatCollection = citaDoc.reference.collection('salasChat');
      final salasChatDocs = await salasChatCollection
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final salasChatData =
          salasChatDocs.docs.map((doc) => doc.data()).toList();

      setState(() {
        _salasChatData = salasChatData;
      });
    }
  }

  Future<void> _enviarMensaje() async {
    String mensajeTexto = _mensajeController.text
        .trim(); // Elimina espacios en blanco al inicio y al final del texto
    if (mensajeTexto.isNotEmpty) {
      await _firestore
          .collection('citas')
          .doc(widget.idCita)
          .collection('salasChat')
          .add({
        'id': widget.enfermeraId,
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
        backgroundColor:
            Color(0xFF1FBAAF), // Cambia el color de fondo de la AppBar
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF4FCFB), // Cambia el color de fondo del cuerpo
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

                    final esUsuario = id == widget.pacienteId;

                    return Align(
                      alignment:
                          esUsuario ? Alignment.topLeft : Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          10.0, // Padding izquierdo
                          index == 0
                              ? 10.0
                              : 0.0, // Padding superior para el primer mensaje
                          10.0, // Padding derecho
                          0.0, // Padding inferior
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
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ), // Espacio de 10 píxeles entre los mensajes
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
                      maxLines: null, // Esto permite múltiples líneas
                      decoration: InputDecoration(
                        hintText: 'Mensaje',
                        filled: true,
                        fillColor:
                            Colors.white, // Cambia el fondo del campo de texto
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .blue, // Cambia el color del contorno al enfocar
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal, // Cambia el color del contorno
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        hintStyle: TextStyle(
                          color: Colors
                              .teal, // Cambia el color del texto de sugerencia
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
                    color: Colors.teal, // Cambia el color del icono
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
