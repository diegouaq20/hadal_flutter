import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hadal/pacientes/calendario/calendario.dart';
import 'package:hadal/pacientes/chats/salasPrivadasPacientes.dart';
import 'package:hadal/pacientes/home/home.dart';
import 'package:hadal/pacientes/ajustes/ajustes.dart';
import 'package:hadal/services/notification_service.dart';

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int _selectedIndex = 2; // seleccionamos la pestaña del índice 2 (Home).

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
                  color: Colors.white, // Color blanco
                  fontWeight: FontWeight.bold, // Texto en negrita
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                Container(
                  color: Color(0xFFF4FCFB), // Puedes cambiar a tu color deseado
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await NotificationService.showNotification(
                          title: "Title of the notification",
                          body: "Body of the notification",
                        );
                      },
                      child: Text('Notificaciónopopop'),
                    ),
                  ),
                ),
                SalasPrivadasPacientes(),
                Home(),
                Calendario(),
                Ajustes(),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 1.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 32, 204, 193).withOpacity(0.1),
              border: Border(
                top: BorderSide(
                  color: Color.fromARGB(255, 32, 204, 193).withOpacity(
                      0.1), // Puedes ajustar el color según tus necesidades
                  width:
                      0.4, // Puedes ajustar el ancho del borde según tus necesidades
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(0, 'assets/notification.svg'),
                _buildTabItem(1, 'assets/chat.svg'),
                _buildTabItem(2, 'assets/home.svg'),
                _buildTabItem(3, 'assets/calendar.svg'),
                _buildTabItem(4, 'assets/settings.svg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String iconPath) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 50, // Alto del tab
                decoration: BoxDecoration(
                  color: _selectedIndex == index
                      ? Color.fromARGB(255, 32, 204, 193)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 28,
                    height: 40,
                    color: _selectedIndex == index
                        ? Colors.white
                        : Color(0xFF7C7F83),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
