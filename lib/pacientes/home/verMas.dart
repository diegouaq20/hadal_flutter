import 'package:flutter/material.dart';
import 'package:hadal/pacientes/servicios/columnasAvanzados.dart';
import 'package:hadal/pacientes/servicios/columnasBasicos.dart';
import 'package:hadal/pacientes/servicios/columnasIntermedios.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

class verMas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // propiedad para quitar la etiqueda de debug
      debugShowCheckedModeBanner: false,
      title: 'HADAL',
      home: MyHomePage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1FBAAF), // Cambia el color del AppBar
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Cambia el tamaño del texto del AppBar
          ),
        ),
        tabBarTheme: TabBarTheme(
          indicator: BoxDecoration(
            color: Color(0xFFF4FCFB),
            borderRadius: BorderRadius.circular(0),
          ),
          labelColor: Color(0xFF235365),
          unselectedLabelColor: Color(0xFF135571), // Cambia el color de los tabs no seleccionados
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _newService = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HADAL',
        ),
        backgroundColor: Color(0xFF1FBAAF),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFE2E9E9), // Cambia el color de fondo del tabBar a gris
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'Básicos',
                ),
                Tab(
                  text: 'Intermedios',
                ),
                Tab(
                  text: 'Avanzados',
                ),
              ],
              indicatorColor: Colors.black, // Cambia el color de la línea indicadora a negro
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(child: ColumnasBasicos()),
                Center(child: ColumnasIntermedios()),
                Center(child: ColumnasAvanzados()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}