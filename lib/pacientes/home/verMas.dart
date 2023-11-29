import 'package:flutter/material.dart';
import 'package:hadal/pacientes/home/principalPaciente.dart';
import 'package:hadal/pacientes/servicios/columnasAvanzados.dart';
import 'package:hadal/pacientes/servicios/columnasBasicos.dart';
import 'package:hadal/pacientes/servicios/columnasIntermedios.dart';

class verMas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // propiedad para quitar la etiqueda de debug
      debugShowCheckedModeBanner: false,
      title: 'HADAL',
      home: MyHomePage(),
      theme: ThemeData(
        tabBarTheme: TabBarTheme(
          indicator: BoxDecoration(
            color: Color(0xFFF4FCFB),
            borderRadius: BorderRadius.circular(0),
          ),
          labelColor: Color(0xFF235365),
          unselectedLabelColor:
              Color(0xFF135571), // Cambia el color de los tabs no seleccionados
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
        backgroundColor: Color(0xFF1FBAAF),
        elevation: 0,
        title: Container(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'HADAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        leading: Row(
  children: [
    IconButton(
      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Principal()),
        );
      },
    ),
  ],
),
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: Colors.white),
            onPressed: () {
              // Acciones al presionar el ícono de lista
              // Puedes navegar a otra pantalla aquí
            },
          ),
        ],
      ),
      body: Column(
  children: [
    Container(
      color: Color(0xFFE2E9E9),
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
        indicator: BoxDecoration(
          color: Color(0xFFF4FCFB), // Cambia el color del indicador a blanco
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Hace que el indicador ocupe todo el tamaño del contenedor
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
