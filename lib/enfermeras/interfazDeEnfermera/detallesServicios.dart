import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetallesServiciosPage extends StatelessWidget {
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

  DetallesServiciosPage({
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
  });

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

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
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
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
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
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Categoría: $tipoCategoria',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Fecha: $fecha',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Horario: $hora',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Domicilio: $domicilio',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Tipo de Servicio: $tipoServicio',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Tipo de Servicio: $ubicacionPaciente',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('citas').doc(idCita).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el estado.
          }

          Map<String, dynamic> citaData = snapshot.data!.data() as Map<String, dynamic>;

          // Verifica si el estado es "aceptado" y deshabilita los botones si es así.
          bool estadoAceptado = citaData['estado'] == 'aceptado';

          return BottomButtons(
            idCita: idCita,
            estadoAceptado: estadoAceptado,
          );
        },
      ),
    );
  }
}

class BottomButtons extends StatelessWidget {
  final String idCita;
  final bool estadoAceptado;

  BottomButtons({
    required this.idCita,
    required this.estadoAceptado,
  });

  Future<void> _aceptarCita(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance.collection('citas').doc(idCita).update({
        'estado': 'aceptado',
        'enfermeraId': user.uid,
      });

      Fluttertoast.showToast(
        msg: 'Cita aceptada con éxito.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error al aceptar la cita: $error',
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
    color: Color(0xFFF4FCFB),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: estadoAceptado
                ? null // Deshabilita el botón si el estado es "aceptado".
                : () {
                    _aceptarCita(context);
                    Navigator.pop(context); // Cierra la pantalla actual
                  },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF1FBAAF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(300, 40),
            ),
            child: Text('Aceptar'),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

}
