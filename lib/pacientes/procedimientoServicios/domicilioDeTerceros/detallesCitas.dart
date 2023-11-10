import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

class DetallesCita extends StatefulWidget {
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
  final String tipoCategoria;
  final String enfermeraId;
  final String pacienteId;
  final String citaId;

  DetallesCita({
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
    required this.tipoCategoria,
    required this.enfermeraId,
    required this.pacienteId,
    required this.citaId,
  });

  @override
  DetallesCitaState createState() => DetallesCitaState();
}

class DetallesCitaState extends State<DetallesCita> {
  String? photoUrlEnfermera;
  String? nombreEnfermera;
  DetallesCitaState? _detallesCitaState; // Instancia del estado

  // Función para cancelar la cita
  void cancelarCita(BuildContext context, String citaId) async {
    try {
      // Elimina la cita de la colección 'citas'
      await FirebaseFirestore.instance
          .collection('citas')
          .doc(citaId) // No es necesario utilizar widget.citaId
          .delete();

      // Luego de eliminar la cita con éxito, navegamos atrás.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Servicio cancelado con éxito.'),
      ));
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir al cancelar la cita.
      print('Error al cancelar la cita: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener la información de la enfermera
    obtenerInfoEnfermera();
    _detallesCitaState = this; // Asignar la instancia actual
  }

  Future<void> obtenerInfoEnfermera() async {
    try {
      final enfermeraDoc = await FirebaseFirestore.instance
          .collection('usuarioenfermera')
          .doc(widget.enfermeraId) // Utiliza el ID de la enfermera
          .get();

      if (enfermeraDoc.exists) {
        final data = enfermeraDoc.data() as Map<String, dynamic>;
        setState(() {
          photoUrlEnfermera =
              data['photoUrl'] ?? ''; // Obtenemos la URL de la imagen
          nombreEnfermera = data['nombre'] ?? '';
        });
      } else {
        // El documento de la enfermera no existe, maneja el error aquí.
      }
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir durante la consulta.
      print('Error al obtener información de la enfermera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _detallesCitaState = this;

    String servicioDisplay = widget.servicio.length > 30
        ? widget.servicio.substring(0, 30) + '...'
        : widget.servicio;

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
                      backgroundImage: photoUrlEnfermera != null &&
                              photoUrlEnfermera!.isNotEmpty
                          ? NetworkImage(photoUrlEnfermera!)
                          : null, // Usamos null para mostrar el círculo sin imagen
                      child: photoUrlEnfermera == null ||
                              photoUrlEnfermera!.isEmpty
                          ? Icon(Icons.person, size: 20, color: Colors.white)
                          : null, // Usamos null para mostrar la imagen si está presente
                      backgroundColor: Color(0xFF235365),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '${nombreEnfermera ?? 'En espera...'}',
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
                      widget.icono,
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
                  'Categoría: ${widget.tipoCategoria}',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Fecha: ${widget.fecha}',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Horario: ${widget.hora}',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Domicilio: ${widget.domicilio}',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Tipo de Servicio: ${widget.tipoServicio}',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ID Enfermera: ${widget.enfermeraId.isNotEmpty ? widget.enfermeraId : 'En espera...'}',
                  style: TextStyle(
                    color: Color(0xFF000328),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ID Paciente: ${widget.pacienteId}',
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
                      '${widget.total}', // Mostramos el total
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF000328),
                      ),
                    ),
                  ],
                ),
              ),

              // Agrega un botón para cancelar el servicio
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Llama a la función para cancelar la cita cuando se presiona el botón
                    _detallesCitaState?.cancelarCita(context, widget.citaId);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text(
                    'Cancelar Servicio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
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
