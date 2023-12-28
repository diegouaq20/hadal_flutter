import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hadal/pacientes/home/principalPaciente.dart';
import 'package:hadal/stripe/payment/client_stripe_payment.dart';

class CitaAgendada extends StatefulWidget {
  final String userId;
  final String dayOfWeek;
  final int dayOfMonth;
  final String month;
  final String serviceName;
  final String schedule;
  final String estado;
  final String nombre;
  final double total;
  final String icono;
  final String domicilio;
  final String photoUrl;
  final String tipoServicio;
  final String tipoCategoria;
  final GeoPoint ubicacion;

  CitaAgendada({
    required this.userId,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.month,
    required this.serviceName,
    required this.schedule,
    required this.estado,
    required this.nombre,
    required this.total,
    required this.icono,
    required this.domicilio,
    required this.photoUrl,
    required this.tipoServicio,
    required this.tipoCategoria,
    required this.ubicacion,
  });

  @override
  _CitaAgendadaState createState() => _CitaAgendadaState();

  void showWaitingProgressDialog() {}
}

ClientStripePayment stripePayment =
    ClientStripePayment(onPaymentSuccess: (bool) {});

class _CitaAgendadaState extends State<CitaAgendada> {
  ClientStripePayment stripePayment =
      ClientStripePayment(onPaymentSuccess: (bool) {});

  bool showWaitingDialog = true;
  late final GlobalKey<NavigatorState> navigatorKey;

  void showWaitingProgressDialog(BuildContext context, String citaId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _enviarDatosFirebase(); // Llamar a la función para enviar datos a Firebase

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFF1FBAAF)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1FBAAF)),
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(height: 16.0),
              Text(
                'Esperando Aceptación - DESDE CITA AGENDADA REGISTRADO',
                style: TextStyle(
                  color: Color.fromARGB(255, 20, 107, 101),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8.0), // Espaciado adicional
              Text(
                '(No salga de esta pantalla)',
                style: TextStyle(
                  color: Colors.red, // Color de advertencia
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Eliminar el documento de Firestore
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      final citasRef =
                          FirebaseFirestore.instance.collection('citas');

                      await citasRef.doc(citaId).delete();

                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                        msg: 'El servicio ha sido cancelado.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  } catch (error) {
                    Fluttertoast.showToast(
                      msg: 'Hubo un error al cancelar el servicio.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                    print(error);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancelar Servicio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _waitForCitaAceptada(String citaId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final citasRef = FirebaseFirestore.instance.collection('citas');
      final citaRef = citasRef.doc(citaId);

      citaRef.snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot['estado'] == 'aceptado') {
          setState(() {
            showWaitingDialog = false;
          });
          Navigator.of(context, rootNavigator: true).pop();
          Fluttertoast.showToast(
            msg: 'La cita ha sido confirmada.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );

// Navegar a la pantalla principal y eliminar todas las rutas anteriores
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  Principal(), // Reemplaza 'PantallaPrincipal' con el nombre de tu pantalla principal
            ),
            (Route<dynamic> route) =>
                false, // Esta función elimina todas las rutas anteriores
          );
        }
      });
    }
  }

  void _realizarPagoYConfirmarCita() async {
    try {
      // Lógica de pago con Stripe aquí
      await stripePayment.makePayment(context, widget.total, widget.nombre,
          widget.userId, widget.serviceName);
      print("Se inició la ventana de pago correctamente");
    } catch (error) {
      setState(() {
        showWaitingDialog = false;
      });
      Fluttertoast.showToast(
        msg: 'Hubo un error al confirmar la cita.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      print(error);
    }
  }

  void _enviarDatosFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final citasRef = FirebaseFirestore.instance.collection('citas');

        final newCitaRef = await citasRef.add({
          'nombre': widget.nombre,
          'dia': widget.dayOfWeek,
          'diaDelMes': widget.dayOfMonth,
          'mes': widget.month,
          'hora': widget.schedule,
          'servicio': widget.serviceName,
          'total': widget.total,
          'estado': 'disponible',
          'domicilio': widget.domicilio,
          'icono': widget.icono,
          'photoUrl': widget.photoUrl,
          'tipoServicio': widget.tipoServicio,
          'tipoCategoria': widget.tipoCategoria,
          'pacienteId': widget.userId,
          'enfermeraId': "",
          'ubicacionPaciente': widget.ubicacion,
        });
      }
    } catch (error) {
      setState(() {
        showWaitingDialog = true;
      });
      Fluttertoast.showToast(
        msg: 'Hubo un error al enviar los datos a Firebase.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      print(error);
    }
  }

  void _confirmarCita() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFF1FBAAF)),
          ),
          title: Text(
            'Confirmar Cita',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1FBAAF),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                child: SvgPicture.network(
                  widget.icono,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Servicio: ${widget.serviceName}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Nombre: ${widget.nombre}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Domicilio: ${widget.domicilio}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Día: ${widget.dayOfWeek}, ${widget.dayOfMonth} de ${widget.month}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Hora: ${widget.schedule}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Total: \$${widget.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Categoría: Servicio ${widget.tipoCategoria}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                    Text(
                      'Ubicacion: Servicio ${widget.ubicacion}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF235365),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    // _realizarPagoConStripe();
                  });

                  await Future.delayed(Duration(seconds: 10));
                  // Puedes ajustar la duración según tus necesidades
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1FBAAF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Proceder al pago',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4FCFB),
        title: Text(
          'Detalles de la cita',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        toolbarHeight: kToolbarHeight - 15,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF235365),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        elevation: 2.0,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Detalles de la Cita',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF235365),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              width: 80,
              height: 80,
              child: SvgPicture.network(
                widget.icono,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servicio: ${widget.serviceName}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Nombre: ${widget.nombre}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Domicilio: ${widget.domicilio}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Día: ${widget.dayOfWeek}, ${widget.dayOfMonth} de ${widget.month}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Hora: ${widget.schedule}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Total: \$${widget.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Categoría: Servicio ${widget.tipoCategoria}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                  Text(
                    'Ubicacion: Servicio ${widget.ubicacion}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF235365),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _confirmarCita,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF1FBAAF),
                minimumSize: Size(double.infinity, 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Confirmar Cita',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
