import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hadal/enfermeras/interfazDeEnfermera/principalEnfermera.dart';
import 'package:hadal/inicioUsuarios/login_screen.dart';
import 'package:hadal/pacientes/home/principalPaciente.dart';
import 'package:hadal/registroUsuario/registerHome.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hadal/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();

  Stripe.publishableKey =
      'pk_test_51NyQXLARylbXLgfzeXUGVsSrTaD6hGUxAjpYxjZlpzVpPdds2WH2chs0tpVK7OjFZTE3jq8vA41ziu7vK2nC9LCk00MNKQOFZY';

  await Stripe.instance.applySettings();

  // // Solicitar permisos de notificación
  // final status = await Permission.notification.request();

  // if (status.isGranted) {
  //   // Los permisos de notificación están concedidos, procede con la inicialización de Firebase y notificaciones locales
  await Firebase.initializeApp();
  initializeDateFormatting('es');

  //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //       FlutterLocalNotificationsPlugin();

  //   final AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('app_icon');

  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );

  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // } else {
  //   // Los permisos de notificación no están concedidos, puedes mostrar un mensaje al usuario o realizar alguna otra acción
  //   print('Permisos de notificación no concedidos');
  // }

  runApp(MyApp());
}

Future<void> updateLocation() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double latitude = position.latitude;
        double longitude = position.longitude;

        final pacienteDoc = await FirebaseFirestore.instance
            .collection('usuariopaciente')
            .doc(user.uid)
            .get();

        final enfermeraDoc = await FirebaseFirestore.instance
            .collection('usuarioenfermera')
            .doc(user.uid)
            .get();

        if (pacienteDoc.exists) {
          // Si es paciente, actualiza la ubicación en la colección "usuariopaciente"
          await pacienteDoc.reference.update({
            'ubicacion': GeoPoint(latitude, longitude),
          });
        } else if (enfermeraDoc.exists) {
          // Si es enfermera, actualiza la ubicación en la colección "usuarioenfermera"
          await enfermeraDoc.reference.update({
            'ubicacion': GeoPoint(latitude, longitude),
          });
        }
      } else {
        // El usuario denegó los permisos de ubicación, muestra un diálogo personalizado
        showDialog(
          context: navigatorKey.currentState!.overlay!.context,
          barrierDismissible: false, // Evita que el usuario cierre el diálogo
          builder: (context) {
            return CustomAlertDialog(
              title: 'Permisos de Ubicación',
              content:
                  'Se requiere acceso a la ubicación para utilizar esta aplicación. Por favor, conceda los permisos de ubicación en la configuración de su dispositivo y vuelva a iniciar la aplicación.',
              borderColor: Colors.teal, // Color del contorno
              borderRadius: 20, // Radio de borde
              titleTextColor: Colors.teal, // Color del texto del título
              contentTextColor: Colors.black, // Color del texto del contenido
            );
          },
        );
      }
    }
  } catch (e) {
    // Error al obtener la ubicación
    print('Error actualizando la ubicación: $e');

    // Muestra un diálogo personalizado para encender el GPS
    showDialog(
      context: navigatorKey.currentState!.overlay!.context,
      barrierDismissible: false, // Evita que el usuario cierre el diálogo
      builder: (context) {
        return CustomAlertDialog(
          title: 'Encender GPS',
          content:
              'Para utilizar esta aplicación, debe encender el GPS de su dispositivo. Por favor, encienda el GPS y vuelva a iniciar la aplicación.',
          borderColor: Colors.teal, // Color del contorno
          borderRadius: 20, // Radio de borde
          titleTextColor: Colors.teal, // Color del texto del título
          contentTextColor: Colors.black, // Color del texto del contenido
        );
      },
    );
  }
}

Future<String?> checkUserType() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final pacienteDoc = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(user.uid)
        .get();

    final enfermeraDoc = await FirebaseFirestore.instance
        .collection('usuarioenfermera')
        .doc(user.uid)
        .get();

    if (pacienteDoc.exists) {
      // Actualizar la ubicación cuando un paciente inicia sesión
      updateLocation();
      return 'Paciente';
    } else if (enfermeraDoc.exists) {
      // Actualizar la ubicación cuando una enfermera inicia sesión
      updateLocation();
      return 'Enfermera';
    }
  }

  return null;
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logoInicio.png',
          width: 130,
          height: 130,
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final Color borderColor;
  final double borderRadius;
  final Color titleTextColor;
  final Color contentTextColor;

  CustomAlertDialog({
    required this.title,
    required this.content,
    this.borderColor = Colors.teal,
    this.borderRadius = 20,
    this.titleTextColor = Colors.teal,
    this.contentTextColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleTextColor,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          color: contentTextColor,
        ),
      ),
    );
  }
}

Color c1 = Color.fromARGB(255, 197, 0, 135);
Color c2 = Color.fromARGB(255, 23, 197, 0);
Color c3 = Color(0xffF4FCFB);
Color c4 = Color(0xffECFFFE);
Color c6 = Color(0xFFF4FCFB);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'HADAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1FBAAF),
          onPrimary: Color(0xffF4FCFB),
          secondary: Color(0xFF245366),
          tertiary: Color(0xff000328),
          background: Color(0xFFF4FFFE),
          error: Colors.red,

          //Theme.of(context).colorScheme.primary,
        ),
      ),
      home: FutureBuilder<String?>(
        future: checkUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final tipoUsuario = snapshot.data;

            // Aquí verifica el tipo de usuario y redirige en consecuencia
            if (tipoUsuario == 'Paciente') {
              return Principal(); // Ruta principal de pacientes
            } else if (tipoUsuario == 'Enfermera') {
              return PrincipalEnfermeras(); // Ruta principal de enfermeras
            } else {
              return LoginScreen(); // Ruta de inicio de sesión para usuarios desconocidos
            }
          }

          return SplashScreen(); // Muestra el SplashScreen mientras se verifica el tipo de usuario
        },
      ),
      routes: {
        '/register': (context) => RegisterHome(), // Ruta de registro
      },
    );
  }
}

ThemeData theme = ThemeData(
  primaryColor: Colors.teal, // Color principal de la aplicación
  textTheme: TextTheme(
    bodyText1: TextStyle(
      color:
          Color(0xFF1FBAAF), // Color del texto de los campos de texto y botones
    ),
  ),
);
