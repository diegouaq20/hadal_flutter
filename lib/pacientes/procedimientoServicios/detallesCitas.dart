import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioRealtime/citaAgendada.dart';
import 'package:hadal/stripe/payment/client_stripe_payment.dart';

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
  // _CitaAgendadaState? _citaAgendadaState;
  String get citaId => widget.citaId;

  String? photoUrlEnfermera;
  String? nombreEnfermera;
  DetallesCitaState? detallesCitaState; // Instancia del estado

  CitaAgendadaState citaAgendada = CitaAgendadaState();

  ClientStripePayment stripePayment =
      ClientStripePayment(onPaymentSuccess: (bool) {});
  // Función para cancelar la cita
  // void cancelarCita(BuildContext context, String citaId) async {
  //   try {
  //     // Elimina la cita de la colección 'citas'
  //     await FirebaseFirestore.instance.collection('citas').doc(citaId).delete();

  //     Navigator.of(context).pop();

  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Servicio cancelado y reembolso realizado con éxito.'),
  //     ));
  //   } catch (e) {
  //     // Maneja cualquier error que pueda ocurrir al cancelar la cita o realizar el reembolso.
  //     print('Error al cancelar la cita y realizar el reembolso: $e');
  //   }
  // }

  // void refundPayment(context, String citaId) async {
  //   // Obtener el paymentIntentId y refundAmount desde ClientStripePayment
  //   String paymentIntentId = stripePayment.getPaymentIntentId() ?? '';
  //   double refundAmount = stripePayment.getRefundAmount();

  //   // Llama a la función refundPayment pasando el contexto, el ID del Payment Intent y el monto del reembolso.
  //   await stripePayment.refundPayment(
  //     context,
  //     paymentIntentId,
  //     refundAmount,
  //   );
  // }

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener la información de la enfermera
    obtenerInfoEnfermera();

    // Crear una instancia de ClientStripePayment y asignar la referencia de DetallesCitaState
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
    detallesCitaState = this;

    String servicioDisplay = widget.servicio.length > 30
        ? widget.servicio.substring(0, 30) + '...'
        : widget.servicio;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de mi servicio'),
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
                          color: Color(0xFF245366),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
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
                          widget.icono,
                          width: 45,
                          height: 45,
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

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nivel de servicio:',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.tipoCategoria}',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fecha:',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.fecha}',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hora:',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.hora}',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Domicilio:',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.domicilio}',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tipo de servicio:',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.tipoServicio}',
                          style: TextStyle(
                            color: Color(0xFF000328),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /*
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
              ),*/

                  SizedBox(height: 150),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
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
                          '\$ ${widget.total}', // Mostramos el total
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF000328),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Agrega un botón para cancelar el servicio
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Llama a la función para cancelar la cita cuando se presiona el botón
                    //detallesCitaState?.cancelarCita(context, widget.citaId);
                    citaAgendada.cancelarServicio(context, citaId);
                    //citaAgendada.showWaitingProgressDialog(citaId, context);
                    //clientStripePayment.getRefundAmount();
                    //refundPayment(context, citaId);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text(
                    'Cancelar Servicio',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
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
