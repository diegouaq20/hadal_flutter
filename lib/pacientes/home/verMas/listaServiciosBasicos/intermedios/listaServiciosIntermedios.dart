import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/pacientes/home/verMas/descripcionListaRealtime.dart';
import 'package:hadal/pacientes/home/verMas/listaServiciosBasicos/basicos/descripcionListaRegistrado.dart';
import 'package:hadal/pacientes/home/verMas/descripcionListaTerceros.dart';
import 'package:hadal/pacientes/home/verMas/verMas.dart';


class ListaServiciosIntermedios extends StatefulWidget {
  @override
  _ListaServiciosIntermediosState createState() => _ListaServiciosIntermediosState();
}

class _ListaServiciosIntermediosState extends State<ListaServiciosIntermedios> {
  List<String> serviciosSeleccionados = [];
  List<String> iconosSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF4FCFB),
        body: MyHomePage(
          onServicioSelected: (serviceName, serviceIcon) {
            setState(() {
              if (serviciosSeleccionados.contains(serviceName)) {
                serviciosSeleccionados.remove(serviceName);
                iconosSeleccionados.remove(serviceIcon);
              } else {
                serviciosSeleccionados.add(serviceName);
                iconosSeleccionados.add(serviceIcon);
              }
            });
          },
          serviciosSeleccionados: serviciosSeleccionados,
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Function(String, String) onServicioSelected;
  final List<String> serviciosSeleccionados;

  MyHomePage({
    required this.onServicioSelected,
    required this.serviciosSeleccionados,
  });

  void navigateToHome(BuildContext context) {
    Navigator.pop(
      context,
      MaterialPageRoute(builder: (context) => verMas()),
    );
  }

  Widget buildServiciosList(
    BuildContext context,
    String title,
    List<QueryDocumentSnapshot> serviciosDocs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF235365),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: serviciosDocs.map((servicioDoc) {
              final data = servicioDoc.data() as Map<String, dynamic>;
              final serviceName = data['procedimiento'];
              final serviceIconUrl = data['icono'];

              final serviceNameFormatted = serviceName.length > 20
                  ? '${serviceName.substring(0, 17)}...'
                  : serviceName;

              final isSelected = serviciosSeleccionados.contains(serviceName);

              return Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        onServicioSelected(serviceName, serviceIconUrl),
                    child: Container(
                      width: 320,
                      height: 100,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.teal : const Color(0xFFF6FFFE),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
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
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF7C7F83),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    serviceNameFormatted,
                    style: TextStyle(
                      color: isSelected ? Colors.teal : Color(0xFF235365),
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FCFB),
      
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildServiciosSection(
                  context, 'serviciosintermedios', 'Elije tu lista'),             
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: ElevatedButton(
          onPressed: () => _showOptionsDialog(context),
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF1FBAAF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Mostrar opciones"),
          ),
        ),
      ),
    );
  }

  Widget _buildServiciosSection(
      BuildContext context, String collection, String title) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection(collection).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error al cargar los $title');
        }

        final serviciosDocs = snapshot.data!.docs;

        return Column(
          children: [
            buildServiciosList(context, title, serviciosDocs),
            const Divider(color: Color(0xFF235365)),
          ],
        );
      },
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Center(
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
                _buildOptionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescripcionListaRegistrado(
                          serviciosSeleccionados: serviciosSeleccionados,
                        ),
                      ),
                    );
                  },
                  label: "Domicilio registrado",
                ),
                _buildOptionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescripcionListaTerceros(
                          serviciosSeleccionados: serviciosSeleccionados,
                        ),
                      ),
                    );
                  },
                  label: "Para alguien más",
                ),
                _buildOptionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescripcionListaRealtime(
                          serviciosSeleccionados: serviciosSeleccionados,
                        ),
                      ),
                    );
                  },
                  label: "Ubicación actual",
                  subLabel:
                      "(Solo si se encuentra fuera de su domicilio registrado)",
                ),
                _buildOptionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  label: "Cancelar",
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required VoidCallback onPressed,
    required String label,
    String? subLabel,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          primary: color ?? const Color(0xFF1FBAAF),
        ),
        onPressed: onPressed,
        child: subLabel != null
            ? Column(
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    subLabel,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              )
            : Text(label),
      ),
    );
  }
}
