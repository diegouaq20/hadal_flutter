import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/pacientes/home/verMas/listaServiciosBasicos/avanzados/listaServiciosAvanzados.dart';
import 'package:hadal/pacientes/home/verMas/listaServiciosBasicos/basicos/listaServiciosBasicos.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioDeTerceros/pantallaDescripcion.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioRealtime/pantallaDescripcionRealtime.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioRegistrado/pantallaDescripcion.dart';

void main() => runApp(ColumnasAvanzados());

class ColumnasAvanzados extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF4FCFB),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 13), // Cambiado a right
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Servicios Avanzados',
                      style: TextStyle(
                        color: Color(0xFF235365),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.list, color: Colors.black),
                      onPressed: () {
                        // Mostrar el BottomSheet con tamaño vertical personalizado
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // Permite el desplazamiento vertical
                          builder: (BuildContext context) {
                            return Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                      1, // Ajusta el tamaño vertical según tus necesidades
                                  child: ListaServiciosAvanzados(),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Cierra el BottomSheet
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('serviciosavanzados')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error al cargar los servicios Avanzados');
                  }
                  final serviciosAvanzadosDocs = snapshot.data!.docs;

                  return Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: serviciosAvanzadosDocs.map((servicioDoc) {
                        final data = servicioDoc.data() as Map<String, dynamic>;
                        final serviceName = data['procedimiento'];
                        final serviceIconUrl = data['icono'];

                        final serviceNameFormatted = serviceName.length > 20
                            ? serviceName.substring(0, 17) + '...'
                            : serviceName;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      title: Center(
                                        child: Text(
                                          "Selecciona una opción",
                                          style: TextStyle(
                                              color: Color(0xFF235365),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  primary: Color(0xFF1FBAAF),
                                                  minimumSize: Size(
                                                      double.infinity, 45.0),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Descripcion(
                                                        servicio: servicioDoc,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Domicilio registrado",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  primary: Color(0xFF1FBAAF),
                                                  minimumSize: Size(
                                                      double.infinity, 45.0),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DescripcionParaTerceros(
                                                        servicio: servicioDoc,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Para alguien más",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  primary: Color(0xFF1FBAAF),
                                                  minimumSize: Size(
                                                      double.infinity, 45.0),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DescripcionRealtime(
                                                        servicio: servicioDoc,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Mi ubicación",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                    Text(
                                                      "(Fuera de su domicilio registrado)",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  primary: Colors.red,
                                                  minimumSize: Size(
                                                      double.infinity, 40.0),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "Cancelar",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF6FFFE),
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.network(
                                      serviceIconUrl,
                                      height: 60.0,
                                      color: Color(0xFF1FBAAF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              serviceNameFormatted,
                              style: TextStyle(
                                color: Color(0xFF235365),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
