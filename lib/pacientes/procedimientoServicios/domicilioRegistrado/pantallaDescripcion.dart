import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioRegistrado/calendarioAgregar.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioRegistrado/calendarioUrgente.dart';

class Servicios {
  String nombre;
  String icono;
  double total;
  String domicilio;
  String tipoCategoria;
  GeoPoint ubicacion;

  Servicios({
    required this.nombre,
    required this.icono,
    required this.total,
    required this.domicilio,
    required this.ubicacion,
    required this.tipoCategoria,
  });
}

class Descripcion extends StatefulWidget {
  final dynamic servicio;

  Descripcion({required this.servicio});

  @override
  _DescripcionState createState() => _DescripcionState();
}

class _DescripcionState extends State<Descripcion> {
  double _total = 0.0;
  double _costoServicio = 0.0;
  late String _domicilio = "";
  late GeoPoint _ubicacion;

  Future<void> initializeAppAndGetName() async {
    await Firebase.initializeApp();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(currentUser!.uid)
        .get();
    setState(() {
      _domicilio = userDoc['domicilio'] ?? "";
      _ubicacion = userDoc['ubicacion'] ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    initializeAppAndGetName();
  }

  @override
  Widget build(BuildContext context) {
    _costoServicio = double.parse(widget.servicio['precio']) * .05;
    _total = double.parse(widget.servicio['precio']) + _costoServicio;

    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4FCFB),
        title: Text(
          'Agregar servicio',
          style: TextStyle(
            color: Color(0xFF235365),
            fontSize: 20,
          ),
        ),
        toolbarHeight: kToolbarHeight - 10,
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(
                            0xFF1FBAAF), // Puedes cambiar este color al que desees
                        borderRadius: BorderRadius.circular(
                            10.0), // Ajusta el radio de los bordes
                      ),
                      padding: EdgeInsets.all(
                          8), // Ajusta el espaciado interno según tus necesidades
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Centra los elementos horizontalmente
                        children: [
                          SvgPicture.network(
                            widget.servicio['icono'],
                            width: 45,
                            height: 45,
                            color: Colors.white, // Color del icono
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                Text(
                                  widget.servicio['procedimiento'],
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Color del texto
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    Text(
                      '\nDescripción',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF245366)),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xFF1FBAAF), width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 18.0, color: Color(0xFF245366)),
                            text: widget.servicio['descripcion'],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    Text(
                      'Tiempo',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF245366)),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xFF1FBAAF), width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 18.0, color: Color(0xFF245366)),
                            text: '${widget.servicio['tiempo'] ?? 0} minutos',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 35),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(
                            0xFF245366), // Puedes cambiar a cualquier color que desees
                        borderRadius: BorderRadius.circular(
                            10.0), // Ajusta el radio de acuerdo a tus necesidades
                      ),
                      padding: EdgeInsets.all(
                          7.0), // Ajusta el espacio interno según tus necesidades
                      child: Center(
                        child: Text(
                          'Pedir servicio',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Color del texto
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20), // Espacio para separar
                    Text(
                      'Mi domicilio',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF245366)),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xFF1FBAAF), width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 18.0, color: Color(0xFF245366)),
                            text: '$_domicilio',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xFF1FBAAF), width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Precio: \$${double.parse(widget.servicio['precio']).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF245366), // Color del texto
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Costo de servicio (5%): \$${_costoServicio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF245366), // Color del texto
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total: \$$_total',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF245366), // Color del texto
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Color(0xFFF4FCFB),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Servicios servicio = Servicios(
                            nombre: widget.servicio['procedimiento'],
                            icono: widget.servicio['icono'],
                            total: _total,
                            domicilio: _domicilio,
                            ubicacion: _ubicacion,
                            tipoCategoria: widget.servicio['tipoCategoria'],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CalendarioAgregar(servicio: servicio),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: Color(0xFF1FBAAF),
                          minimumSize: Size(135, 50.0),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('Agregar'),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Servicios servicio = Servicios(
                            nombre: widget.servicio['procedimiento'],
                            icono: widget.servicio['icono'],
                            total: _total,
                            domicilio: _domicilio,
                            ubicacion: _ubicacion,
                            tipoCategoria: widget.servicio['tipoCategoria'],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CalendarioUrgente(servicio: servicio),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: Colors.red,
                          minimumSize: Size(135, 50.0),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('Urgente'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
