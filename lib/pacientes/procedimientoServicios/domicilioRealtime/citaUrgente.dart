import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
final DatabaseReference citasReference = databaseReference.child('citasUrgentes');
final DatabaseReference usersReference = databaseReference.child('users');
final FirebaseAuth _auth = FirebaseAuth.instance;

class FirebaseService {
  static Future<void> addCita({
    required String uid,
    required String serviceName,
    required String dayOfWeek,
    required int dayOfMonth,
    required String month,
    required String schedule,
    required String nombre,
  }) async {
    final newCitaRef = citasReference.push();
    await newCitaRef.set({
      'userId': uid,
      'serviceName': serviceName,
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'month': month,
      'schedule': schedule,
      'estado': 'pendiente',
      'nombre': nombre,
    });
  }
}

class CitaUrgente extends StatefulWidget {
  CitaUrgente({
    required this.userId,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.month,
    required this.serviceName,
    required this.schedule,
    required this.estado,
    required this.nombre,
  });
  final String userId;
  final String dayOfWeek;
  final int dayOfMonth;
  final String month;
  final String serviceName;
  final String schedule;
  final String estado;
  final String nombre;

  @override
  State<CitaUrgente> createState() => _citaUrgenteState();
}

class _citaUrgenteState extends State<CitaUrgente> {
  late StreamSubscription _streamSubscription;
  late DatabaseReference _newCitaRef;
  bool isApiCallProcess = false;

  void _sendDataToFirebase(BuildContext context) async {
    final currentUser = _auth.currentUser;
    final uid = currentUser!.uid;
    _newCitaRef = citasReference.push();
    _newCitaRef.set({
      'userId': uid,
      'serviceName': widget.serviceName,
      'dayOfWeek': widget.dayOfWeek,
      'dayOfMonth': widget.dayOfMonth,
      'month': widget.month,
      'schedule': widget.schedule,
      'estado': 'pendiente',
      'nombre': widget.nombre,
    });

    setState(() {
  isApiCallProcess = true;
  _streamSubscription = _newCitaRef.onValue.listen((event) {
    final jsonData = event.snapshot.value;
    if (jsonData != null) {
      setState(() {
        isApiCallProcess = false;
      });
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => cancelar(nodo:_newCitaRef)));
    }
  });
});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FCFB),
        title: const Text(
          'Confirmación de Cita Urgente',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        toolbarHeight: kToolbarHeight - 15,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF235365),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF1FBAAF),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(20.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del servicio',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Paciente: ${widget.nombre}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Fecha: ${widget.dayOfWeek}, ${widget.dayOfMonth} de ${widget.month}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Horario: ${widget.schedule}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Estado: ${widget.estado}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            isApiCallProcess
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _sendDataToFirebase(context),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Color(0xFF1FBAAF)),
                          minimumSize:
                              MaterialStateProperty.all<Size>(Size(200, 40)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: Text('Confirmar'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class LatestCita extends StatefulWidget {
  LatestCita({required this.nodo, this.height, this.width});
  final DatabaseReference nodo;
  final double? height;
  final double? width;

  @override
  _LatestCitaState createState() => _LatestCitaState();
}
class _LatestCitaState extends State<LatestCita> {
  bool deleted = false;
  bool isLoading = true;

  void deleteNode() {
    widget.nodo.remove();
    setState(() {
      deleted = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FCFB),
        title: const Text(
          'Estado del pedido',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        toolbarHeight: kToolbarHeight - 15,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF235365),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        elevation: 0.0,
      ),
      body: deleted
          ? Center(
              child: Text(
                '¡Solicitud cancelada exitosamente!',
                style: TextStyle(fontSize: 20),
              ),
            )
          : StreamBuilder(
              stream: widget.nodo.onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final jsonData = snapshot.data!.snapshot.value;
                  final aceptadoPor = jsonData["aceptadoPor"];

                  if (jsonData['estado'] == 'aceptado') {
                    isLoading = false;
                  }

                  return Container(
                    height: widget.height ?? MediaQuery.of(context).size.height,
                    width: widget.width ?? MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 0.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF1FBAAF),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: aceptadoPor != null,
                                  child: Text(
                                    'Aceptado por: $aceptadoPor',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Paciente: ${jsonData["nombre"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  jsonData["serviceName"],
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Fecha: ${jsonData["dayOfWeek"]}, ${jsonData["dayOfMonth"]} de ${jsonData["month"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Horario: ${jsonData["schedule"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Estado: ${jsonData["estado"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.0),
                          Visibility(
                            visible: isLoading,
                            child: Center(
                              child: SizedBox(
                                height: 5.0,
                                width: 500.0, // ancho
                                child: LinearProgressIndicator(
                                  backgroundColor: Color.fromARGB(255, 24, 148, 140),
                                  valueColor: AlwaysStoppedAnimation(
                                    Color.fromARGB(255, 20, 255, 239),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(height: 2),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: Center(
                              child: Text(
                                'Esperando a que alguna enfermera tome el servicio.',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Color(0xFF235365),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50.0),
                          Center(
                            child: ElevatedButton(
                              child: Text(
                                'Cancelar Solicitud',
                                style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF1FBAAF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: Size(200, 40),
                              
                            ),
                            onPressed: deleteNode,
                          ),
                        ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Cargando información...')
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }
}

class cancelar extends StatefulWidget {
  cancelar({required this.nodo, this.height, this.width});
  final DatabaseReference nodo;
  final double? height;
  final double? width;

  @override
  _cancelarState createState() => _cancelarState();
}
class _cancelarState extends State<cancelar> {
  bool deleted = false;
  bool isLoading = true;

  void deleteNode() {
    widget.nodo.remove();
    setState(() {
      deleted = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FCFB),
        title: const Text(
          'Estado del pedido',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        toolbarHeight: kToolbarHeight - 15,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF235365),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        elevation: 0.0,
      ),
      body: deleted
          ? Center(
              child: Text(
                '¡Solicitud cancelada exitosamente!',
                style: TextStyle(fontSize: 20),
              ),
            )
          : StreamBuilder(
              stream: widget.nodo.onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final jsonData = snapshot.data!.snapshot.value;
                  final aceptadoPor = jsonData["aceptadoPor"];

                  if (jsonData['estado'] == 'aceptado') {
                    isLoading = false;
                  }
                  return Container(
                    height: widget.height ?? MediaQuery.of(context).size.height,
                    width: widget.width ?? MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 0.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF1FBAAF),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: aceptadoPor != null,
                                  child: FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(aceptadoPor).get(),
                                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.hasData != null) {
                                          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                          return Text(
                                            'Aceptado Por: ${data['nombre']}',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                          );
                                        } else {
                                          return Text('');
                                        }
                                      } else {
                                        return Text('');
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Paciente: ${jsonData["nombre"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  jsonData["serviceName"],
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Fecha: ${jsonData["dayOfWeek"]}, ${jsonData["dayOfMonth"]} de ${jsonData["month"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Horario: ${jsonData["schedule"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Estado: ${jsonData["estado"]}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.0),
                          Visibility(
                            visible: isLoading,
                            child: Center(
                              child: SizedBox(
                                height: 5.0,
                                width: 500.0, // ancho
                                child: LinearProgressIndicator(
                                  backgroundColor: Color.fromARGB(255, 24, 148, 140),
                                  valueColor: AlwaysStoppedAnimation(
                                    Color.fromARGB(255, 20, 255, 239),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(height: 2),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: Center(
                              child: Text(
                                'Esperando a que alguna enfermera tome el servicio.',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Color(0xFF235365),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50.0),
                          Center(
                            child: ElevatedButton(
                              child: Text(
                                'Cancelar Solicitud',
                                style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF1FBAAF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: Size(200, 40),
                              
                            ),
                            onPressed: deleteNode,
                          ),
                        ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Cargando información...')
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }
}