import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ClientStripePayment extends GetConnect {
  Map<String, dynamic>? paymentIntentData;

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
      await Stripe.instance.presentPaymentSheet().then((value) {
        Get.snackbar('Pago exitoso', 'Tu pago fue procesado correctamente');

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Error con la tarjeta: ${error} ${stackTrace} ');
      });
    } on StripeException catch (err) {
      print('Error Stripe: ${err}');
      showDialog(
          context: context,
          builder: (value) => AlertDialog(
                content: Text('Operación Cancelada'),
              ));
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
}
