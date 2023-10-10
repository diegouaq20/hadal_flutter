import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Carrito extends StatefulWidget {
  @override
  _CarritoState createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final carritoRef = FirebaseFirestore.instance.collection('usuariopaciente').doc(currentUser!.uid).collection('carrito');

    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      appBar: AppBar(
        title: Text('Carrito', style: TextStyle(color: Color(0xFF235365))),
        backgroundColor: Color(0xFFF4FCFB),
        iconTheme: IconThemeData(color: Color(0xFF235365)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: carritoRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('El carrito está vacío.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final serviceData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceData['nombre'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF235365))),
                      Text('Total: \$${serviceData['precio']}', style: TextStyle(fontSize: 14, color: Color(0xFF235365))),
                    ],
                  ),
                  children: [
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuario: ${serviceData['nombreUsuario']}', style: TextStyle(color: Color(0xFF235365))),
                          Text('Fecha: ${serviceData['dia']} ${serviceData['diaDelMes']} de ${serviceData['mes']}', style: TextStyle(color: Color(0xFF235365))),
                          Text('Hora: ${serviceData['hora']}',style: TextStyle(color: Color(0xFF235365))), 
                          Text('Estado: ${serviceData['estado']}', style: TextStyle(color: Color(0xFF235365))),
                          Text('Categoría: ${serviceData['tipoCategoria']}', style: TextStyle(color: Color(0xFF235365))),
                          // Otros campos si es necesario
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
