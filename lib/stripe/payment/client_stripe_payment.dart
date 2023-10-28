import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

void showWaitingProgressDialog() {}

class ClientStripePayment extends GetConnect {
  bool showWaitingDialog = false;

  Map<String, dynamic>? paymentIntentData;

  Function(bool) onPaymentSuccess;

  ClientStripePayment({required this.onPaymentSuccess});

  Future<void> makePayment(BuildContext context, double _total) async {
    print(
        '_________________Valor de total: $_total'); // Imprimir el valor de total en la consola

    var gpay = PaymentSheetGooglePay(
      merchantCountryCode: "MX",
      currencyCode: "MXN",
      testEnv: true,
    );
    try {
      paymentIntentData = await createPaymentIntent(
        double.parse(_total.toStringAsFixed(2)),
        'MXN',
      );
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  merchantDisplayName: 'Hadal',
                  googlePay: gpay))
          .then((value) {});

      showPaymentSheet(context);
    } catch (err) {
      print('Error: ${err}');
    }
  }

  showPaymentSheet(BuildContext context) async {
    try {
      if (paymentIntentData != null) {
        await Stripe.instance.presentPaymentSheet().then((value) {
          // Muestra el SnackBar utilizando ScaffoldMessenger
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Pago exitoso: Tu pago fue procesado correctamente'),
            ),
          );

          // Agregar un retraso antes de mostrar el diálogo de espera
          Future.delayed(Duration(seconds: 2), () {
            // Llamar a la función de callback con true para mostrar el diálogo
            showWaitingDialog = true;

            // Llamar a la función para mostrar el diálogo de espera
            if (showWaitingDialog) {
              showWaitingProgressDialog(context,
                  'citaId'); // Reemplaza 'citaId' con el valor correcto
            }
          });
        }).onError((error, stackTrace) {
          print('Error con la tarjeta: $error $stackTrace');
        });
      } else {
        print('PaymentIntent data is null');
        // Handle the case when paymentIntentData is null, e.g., show an error message.
      }
    } on StripeException catch (err) {
      print('Error Stripe: $err');
      showDialog(
        context: context,
        builder: (value) => SnackBar(
          content: Text('Operación Cancelada'),
        ),
      );
    }
  }

  createPaymentIntent(double amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51NyQXLARylbXLgfzvs3lZaHSVbf8gZe4UBUB0VvFRSyBz5Nzg5aDYqLtcb89cwqrwtJtVywScqKChUytCrdsR6Pz00nuym33QP',
            'Content-Type': 'application/x-www-form-urlencoded',
          });

      return jsonDecode(response.body);
    } catch (err) {
      print('Error: ${err}');
    }
  }

  String calculateAmount(double amount) {
    final a = (amount * 100).toInt();
    return a.toString();
  }

  void showWaitingProgressDialog(BuildContext context, String citaId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                'Esperando Aceptación desde la clase pago',
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
                      final citasRef = FirebaseFirestore.instance.collection(
                          'citas'); // Cambiar la referencia a la colección "citas"

                      await citasRef
                          .doc(citaId)
                          .delete(); // Cambiar la referencia al documento

                      Navigator.of(context).pop(); // Cerrar el diálogo
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
                  primary: Colors.red, // Color rojo para indicar cancelación
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
}
