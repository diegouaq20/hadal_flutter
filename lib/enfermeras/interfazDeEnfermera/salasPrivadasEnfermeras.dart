import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/enfermeras/interfazDeEnfermera/mensajesEnfermeras.dart';

class SalasPrivadasEnfermeras extends StatefulWidget {
  @override
  _SalasPrivadasEnfermerasState createState() =>
      _SalasPrivadasEnfermerasState();
}

class _SalasPrivadasEnfermerasState extends State<SalasPrivadasEnfermeras> {
  String nombre = "";
  String primerApellido = "";
  String segundoApellido = "";
  String tipoUsuario = "";
  String categoria = "";

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _getUserData();
  }

  @override
  void dispose() {
    super.dispose();
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
    });
  }

  Stream<QuerySnapshot> _getMisCitasStream() {
    final citasRef = FirebaseFirestore.instance.collection('citas');

    return citasRef
        .where('enfermeraId', isEqualTo: _currentUser.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Lista de Chats',
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
                  return Center(
                    child: CircularProgressIndicator(),
                  );
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

                    return GestureDetector(
                      onTap: () {
                        if (estado == 'disponible' || estado == 'aceptado') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MensajesEnfermeras(
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25, // Tamaño del círculo
                            backgroundColor:
                                Color(0xFF235365), // Color de fondo
                            backgroundImage: photoUrl != null
                                ? NetworkImage(
                                    photoUrl) // Usar NetworkImage para cargar la imagen desde Internet
                                : null, // Dejar en blanco si photoUrl es nulo
                            child: photoUrl == null
                                ? Icon(Icons.info_outline,
                                    size: 20,
                                    color: Colors
                                        .white) // Icono predeterminado con color de fondo
                                : null, // Icono predeterminado
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
