import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  CitaAgendadaState createState() => CitaAgendadaState();

  // void showWaitingProgressDialog() {}
}

ClientStripePayment stripePayment =
    ClientStripePayment(onPaymentSuccess: (bool) {});

class CitaAgendadaState extends State<CitaAgendada> {
  ClientStripePayment stripePayment =
      ClientStripePayment(onPaymentSuccess: (bool) {});

  bool showWaitingDialog = false;
  late final GlobalKey<NavigatorState> navigatorKey;

  CitaAgendadaState() {
    stripePayment = ClientStripePayment(
      onPaymentSuccess: (bool paymentSuccessful) {
        if (paymentSuccessful) {
          pagoConfirmadoCrearCita();
        }
      },
    );
  }

  void showWaitingProgressDialog(String citaId, context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        //pagoConfirmadoCrearCita();
        _waitForCitaAceptada(citaId);
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
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
                'Esperando Aceptación - DESDE CITA AGENDADA TIEMPO REAL',
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
                  cancelarServicio(context, citaId);
                  refundPayment(context, citaId);
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

  cancelarServicio(BuildContext context, String citaId) async {
    try {
      // Eliminar el documento de Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final citasRef = FirebaseFirestore.instance.collection('citas');

        await citasRef.doc(citaId).delete();

        // String paymentIntentId = stripePayment.getPaymentIntentId() ?? '';
        // double refundAmount = stripePayment.getRefundAmount();
        // // Llama a la función refundPayment pasando el contexto, el ID del Payment Intent y el monto del reembolso.
        // await stripePayment.refundPayment(
        //   context,
        //   paymentIntentId,
        //   refundAmount,
        // );
        // // Llamada al método refundPayment
        // print(
        //     "___________VALOR DE PAYMENT INTENT ID: $paymentIntentId, $refundAmount");
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => Principal(),
          ),
          (Route<dynamic> route) => false,
        );

        //Navigator.of(context, rootNavigator: true).pop();
        //refundPayment(citaId);
        Fluttertoast.showToast(
          msg: 'El servicio ha sido cancelado y el pago reembolsado.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg:
            'Hubo un error al cancelar el servicio. - Desde Cita Agendada Registrado $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      print(error);
    }
  }

  void refundPayment(context, String citaId) async {
    // Obtener el paymentIntentId y refundAmount desde ClientStripePayment
    String paymentIntentId = stripePayment.getPaymentIntentId() ?? '';
    double refundAmount = stripePayment.getRefundAmount();

    // Llama a la función refundPayment pasando el contexto, el ID del Payment Intent y el monto del reembolso.
    await stripePayment.refundPayment(
      context,
      paymentIntentId,
      refundAmount,
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

  pagoConfirmadoCrearCita() async {
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
        'paymentIntent': stripePayment.paymentIntentData,
      });

      String servicioId = newCitaRef.id;
      print(
          "________EL ID DEL SERVICIO ES: $servicioId DESDE CITA AGENADA DOMICILIO REGISTRADO");

      setState(() {
        //showWaitingDialog = true;
        showWaitingProgressDialog(newCitaRef.id, context);
      });

      // Muestra el SnackBar de pago exitoso
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Pago exitoso: Tu pago fue procesado correctamente'),
      //   ),
      // );

      // Espera un momento antes de mostrar el WaitingProgressDialog
      // await Future.delayed(Duration(
      //     seconds: 10)); // Puedes ajustar la duración según tus necesidades

      // Muestra el WaitingProgressDialog
      // showWaitingDialog = true;
    }
  }

  void _confirmarCita() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFF1FBAAF)),
          ),
          title: Text(
            'CONFIRMAR CITA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1FBAAF),
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  child: SvgPicture.network(
                    widget.icono,
                    color: Color(0xFF235365),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Servicio: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.serviceName}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Nivel de servicio: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.tipoCategoria}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Nombre: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.nombre}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Domicilio: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.domicilio}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Día: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${widget.dayOfWeek}, ${widget.dayOfMonth} de ${widget.month}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Hora: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.schedule}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF235365),
                          ),
                          children: [
                            TextSpan(
                              text: 'Total: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '\$${widget.total.toStringAsFixed(2)}',
                            ),
                          ],
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
                      showWaitingDialog = true;
                      _realizarPagoYConfirmarCita();
                    });

                    await Future.delayed(Duration(seconds: 10));

                    // Puedes ajustar la duración según tus necesidades
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1FBAAF),
                    minimumSize: Size(double.infinity, 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Proceder al pago',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _agregarAlCarrito() {
  //   try {
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       final userRef = FirebaseFirestore.instance
  //           .collection('usuariopaciente')
  //           .doc(currentUser.uid);
  //       final carritoRef = userRef.collection('carrito');

  //       // Agregar el servicio al carrito
  //       carritoRef.add({
  //         'nombre': widget.serviceName,
  //         'precio': widget.total,
  //         'dia': widget.dayOfWeek,
  //         'diaDelMes': widget.dayOfMonth,
  //         'mes': widget.month,
  //         'hora': widget.schedule,
  //         'nombreUsuario': widget.nombre,
  //         'domicilio': widget.domicilio,
  //         'photoUrl': widget.photoUrl,
  //         'icono': widget.icono,
  //         'tipoCategoria': widget.tipoCategoria,
  //         'estado': "sin pedir"
  //         // Otros campos si es necesario
  //       });

  //       Fluttertoast.showToast(
  //         msg: 'El servicio se ha añadido al carrito correctamente.',
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //       );
  //     }
  //   } catch (error) {
  //     Fluttertoast.showToast(
  //       msg: 'Hubo un error al añadir el servicio al carrito.',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //     );
  //     print(error);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFF4FCFB),
        title: Text(
          'Detalles',
          style: TextStyle(
              color: Color(0xFF235365),
              fontSize: 20,
              fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'DETALLES DE LA CITA',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF235365),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 40), // Espacio para separar

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
                              '${widget.serviceName}',
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nivel de servicio',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF245366),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                            text: '${widget.tipoCategoria}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Nombre

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nombre',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF245366),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                            text: '${widget.nombre}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Ubicación actual',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF245366),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                            text: '${widget.domicilio}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Fecha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Fecha',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF245366),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                            text:
                                '${widget.dayOfWeek}, ${widget.dayOfMonth} de ${widget.month}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Hora
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hora',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF245366),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                            text: '${widget.schedule}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // TOTAL
                SizedBox(height: 60),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Color(0xFF245366),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                            text: '\$${widget.total.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    'Confirmar cita',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                // ElevatedButton(
                //   onPressed: _agregarAlCarrito,
                //   style: ElevatedButton.styleFrom(
                //     primary: Color(0xFFF4FCFB),
                //     onPrimary: Color(0xFF1FBAAF),
                //     minimumSize: Size(double.infinity, 50.0),
                //     shape: RoundedRectangleBorder(
                //       side: BorderSide(color: Color(0xFF1FBAAF)),
                //       borderRadius: BorderRadius.circular(10.0),
                //     ),
                //   ),
                //   child: Text(
                //     'Añadir al carrito',
                //     style: TextStyle(
                //       fontSize: 18.0,
                //       color: Color(0xFF1FBAAF),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
