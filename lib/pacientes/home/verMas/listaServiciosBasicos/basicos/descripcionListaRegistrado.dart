import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hadal/pacientes/home/verMas/listaServiciosBasicos/basicos/calendarioAgregarLista.dart';

class ServicioLista {
  String nombre;
  String icono;
  double total;
  String domicilio;
  String tipoCategoria;
  GeoPoint ubicacion;

  ServicioLista({
    required this.nombre,
    required this.icono,
    required this.total,
    required this.domicilio,
    required this.ubicacion,
    required this.tipoCategoria,
  });
}

class DescripcionListaRegistrado extends StatefulWidget {
  final List<dynamic> serviciosSeleccionados;

  DescripcionListaRegistrado({
    required this.serviciosSeleccionados,
  });

  @override
  _DescripcionListaRegistradoState createState() =>
      _DescripcionListaRegistradoState();
}

class _DescripcionListaRegistradoState
    extends State<DescripcionListaRegistrado> {
  late String _domicilio = "";
  late GeoPoint _ubicacion;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    initializeAppAndGetName();
    calcularTotal();
  }

  void calcularTotal() {
    _total = 0.0;
    for (var servicio in widget.serviciosSeleccionados) {
      obtenerInformacionServicio(servicio).then((infoServicio) {
        double precio = double.parse(infoServicio['precio']);
        setState(() {
          _total += precio;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de lista'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.serviciosSeleccionados.length,
              itemBuilder: (context, index) {
                dynamic servicio = widget.serviciosSeleccionados[index];

                return FutureBuilder(
                  future: obtenerInformacionServicio(servicio),
                  builder:
                      (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      Map<String, dynamic> infoServicio = snapshot.data!;
                      double precio = double.parse(infoServicio['precio']);

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            title: Text(
                              servicio,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF245366),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.network(
                                      infoServicio['icono'],
                                      height: 40.0,
                                      width: 40.0,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Descripción: ${infoServicio['descripcion']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF245366),
                                  ),
                                ),
                                Text(
                                  'Tipo de servicio: ${infoServicio['tipoCategoria']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF245366),
                                  ),
                                ),
                                Text(
                                  'Precio: \$${precio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF245366),
                                  ),
                                ),
                                Text(
                                  'Domicilio: $_domicilio',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF245366),
                                  ),
                                ),
                                Text(
                                  'Ubicación: ${_ubicacion.latitude}, ${_ubicacion.longitude}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF245366),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                          ServicioLista servicioLista = ServicioLista(
                            nombre: 'Lista de servicios',
                            icono: 'https://firebasestorage.googleapis.com/v0/b/hadal-8eb6f.appspot.com/o/Basicos%2Flista.svg?alt=media&token=1cf8dfce-6e68-4ea4-84f2-1112ed8acdb7',
                            total: _total,
                            domicilio:_domicilio,
                            ubicacion: _ubicacion,
                            tipoCategoria: 'Basico',
                          );
                         /*Navigator.push(
                            context,
                           MaterialPageRoute(
                              builder: (context) =>
                                  CalendarioAgregarLista(servicioLista: servicioLista),
                            ),
                          );*/
                        },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Agregar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Agregar lógica para el botón "Agregar"
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Urgente'),
                    ),
                  ],
                ),
                Text(
                  'Total: \$${_total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> obtenerInformacionServicio(
      String servicio) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> infoServicio = {};

    await firestore
        .collection('serviciosbasicos')
        .where('procedimiento', isEqualTo: servicio)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        infoServicio['descripcion'] = doc['descripcion'];
        infoServicio['precio'] = doc['precio'];
        infoServicio['tipoCategoria'] = doc['tipoCategoria'];
        infoServicio['icono'] = doc['icono'];
      });
    });
    return infoServicio;
  }

  Future<void> initializeAppAndGetName() async {
    await Firebase.initializeApp();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(currentUser!.uid)
        .get();
    setState(() {
      _domicilio = userDoc['domicilio'] ?? "";
      _ubicacion = userDoc['ubicacion'] ?? GeoPoint(0, 0);
    });
  }
}
