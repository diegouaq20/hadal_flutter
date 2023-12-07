// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hadal/registroUsuario/registroPaciente.dart';
import 'package:hadal/registroUsuario/registroEnfermera.dart';
//import 'package:flutter/animation.dart';

class RegisterHome extends StatefulWidget {
  const RegisterHome({super.key});

  @override
  _RegisterHomeState createState() => _RegisterHomeState();
}

class _RegisterHomeState extends State<RegisterHome>
    with SingleTickerProviderStateMixin {
  //bool _newService = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        //backgroundColor: Colors.transparent,
        elevation: 1,
        toolbarHeight: 35,
        //shadowColor: const Color(0xFFe6eff8),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1FBAAF),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'CREAR PERFIL',
          style: TextStyle(
              fontSize: 20,
              color: Color(0xFF1FBAAF),
              fontWeight: FontWeight.bold // Cambia el color aquí
              ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF6FFFE),
                Color(0xFFF6FFFE),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6FFFE),
              Color(0xFFF6FFFE),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF6FFFE),
                      Color(0xFFF6FFFE),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      child: Text(
                        "Paciente",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Enfermera",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF1FBAAF),
                        Color(0xFF1FBAAF),
                      ],
                    ),
                  ),
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: const Color(0xFF676f77),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF6FFFE),
                        Color(0xFFF6FFFE),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      RegistroPaciente(),
                      RegistroEnfermera(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
