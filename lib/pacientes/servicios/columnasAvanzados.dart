import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioDeTerceros/pantallaDescripcion.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              Padding(
                padding: EdgeInsets.only(left: 13), // Agrega el padding izquierdo
                child: Text(
                  'Servicios Avanzados',
                  style: TextStyle(
                    color: Color(0xFF235365),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.teal), // Color turquesa
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
                        final data =
                            servicioDoc.data() as Map<String, dynamic>;
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      title: Center(
                        child: Text(
                          "Selecciona una opción",
                          style: TextStyle(
                            color: Color(0xFF235365),
                          ),
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  primary: Color(0xFF1FBAAF),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Descripcion(
                                        servicio: servicioDoc,
                                      ),
                                    ),
                                  );
                                },
                                child: Text("Domicilio registrado"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  primary: Color(0xFF1FBAAF),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DescripcionParaTerceros(
                                        servicio: servicioDoc,
                                      ),
                                    ),
                                  );
                                },
                                child: Text("Para alguien más"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  primary: Color(0xFF1FBAAF),
                                ),
                                onPressed: () {
                                  // Navegar a una ruta no diseñada
                                  // Aquí puedes agregar la lógica para la tercera opción
                                },
                                child: Text("Ubicación actual"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  primary: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancelar"),
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
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Color(0xFFF6FFFE),
          borderRadius: BorderRadius.circular(15.0),
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
              color: Color(0xFF7C7F83),
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
        fontSize: 15.0,
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
