import 'package:flutter/material.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioDeTerceros/citaAgendada.dart';
import 'package:hadal/pacientes/procedimientoServicios/domicilioDeTerceros/pantallaDescripcion.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioAgregarTerceros extends StatefulWidget {
  final Servicios servicio;

  CalendarioAgregarTerceros({required this.servicio});

  @override
  _CalendarioAgregarTercerosState createState() =>
      _CalendarioAgregarTercerosState();
}

class _CalendarioAgregarTercerosState extends State<CalendarioAgregarTerceros> {
  late String nombre;
  late GeoPoint _ubicacion;
  late String photoUrl;

  late TextEditingController _domicilioController;

  @override
  void initState() {
    super.initState();
    initializeAppAndGetName();
    _domicilioController =
        TextEditingController(text: widget.servicio.domicilio);
  }

  Future<void> initializeAppAndGetName() async {
    await Firebase.initializeApp();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(currentUser!.uid)
        .get();
    setState(() {
      nombre = userDoc['nombre'] ?? "";
      _ubicacion = userDoc['ubicacion'] ?? GeoPoint(0, 0);
      photoUrl = userDoc['photoUrl'] ?? "";
    });
  }

  int _selectedHorarioIndex = -1;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> horarios = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendar cita',
          style: TextStyle(
              color: Color(0xFF235365),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        toolbarHeight: kToolbarHeight - 15,
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
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            locale: 'es_ES',
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF1FBAAF),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 91, 255, 241),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayTextStyle: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 14.0),
          Expanded(
            child: ListView.separated(
              itemCount: horarios.length,
              separatorBuilder: (context, index) => Divider(
                color:
                    _selectedHorarioIndex == index ? null : Color(0xFF245366),
                thickness: 2.0,
                indent: MediaQuery.of(context).size.width * 0.2,
                endIndent: MediaQuery.of(context).size.width * 0.05,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: Colors.white,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          horarios[index],
                          style: TextStyle(
                            color: _selectedHorarioIndex == index
                                ? Color(0xFF1FBAAF)
                                : null,
                          ),
                        ),
                      ),
                      _selectedHorarioIndex == index
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.77,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 124, 191, 187),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 5.0),
                                  Text(
                                    '${widget.servicio.nombre}',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedHorarioIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            width: double.infinity,
            height: 50.0,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFF1FBAAF),
            ),
            child: TextButton(
              onPressed: () {
                if (_selectedDay == null || _selectedHorarioIndex == -1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        title: Text(
                          'Selecciona una fecha y un horario',
                          style: TextStyle(fontSize: 18),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                final now = DateTime.now();
                if (_selectedDay!
                    .isBefore(DateTime(now.year, now.month, now.day - 0))) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        title: Text(
                          'No puedes agendar citas en fechas pasadas',
                          style: TextStyle(fontSize: 18),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                final dayOfWeek =
                    DateFormat.EEEE('es_ES').format(_selectedDay!);
                final dayOfMonth = _selectedDay!.day;
                final month = DateFormat.MMMM('es_ES').format(_selectedDay!);
                final serviceName = widget.servicio.nombre;
                final schedule = horarios[_selectedHorarioIndex];
                final total = widget.servicio.total;
                final icono = widget.servicio.icono;
                final tipoCategoria = widget.servicio.tipoCategoria;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CitaAgendada(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      dayOfWeek: dayOfWeek,
                      dayOfMonth: dayOfMonth,
                      month: month,
                      serviceName: serviceName,
                      schedule: schedule,
                      estado: 'disponible',
                      tipoServicio: 'Cita',
                      nombre: nombre,
                      total: total,
                      icono: icono,
                      domicilio: _domicilioController.text,
                      ubicacion: _ubicacion,
                      photoUrl: photoUrl,
                      tipoCategoria: tipoCategoria,
                    ),
                  ),
                );
              },
              child: Text(
                'Agendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
