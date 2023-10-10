import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  TextEditingController _noteController = TextEditingController();
  int _editingIndex = -1;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadEvents(_selectedDay);
  }

  Future<void> _loadUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _loadEvents(DateTime selectedDay) async {
    if (_userId != null) {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('usuariopaciente')
          .doc(_userId)
          .collection('notas')
          .doc(DateFormat('yyyy-MM-dd').format(selectedDay))
          .get();

      if (eventsSnapshot.exists) {
        final eventsData = eventsSnapshot.data() as Map<String, dynamic>;
        final eventsList = eventsData['events'] as List<dynamic>;

        setState(() {
          _events[selectedDay] = eventsList.cast<String>();
        });
      } else {
        setState(() {
          _events[selectedDay] = [];
        });
      }
    }
  }

  List<String> _getEventsForDay(DateTime date) {
    final events = _events[date];
    return events ?? [];
  }

  void _addEvent(String note) {
    if (note.isNotEmpty) {
      setState(() {
        _events[_selectedDay]?.add(note);
      });

      _saveEvents();
      _noteController.clear();
    }
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editingIndex == -1 ? 'Agregar Nota' : 'Editar Nota',
                  style: TextStyle(
                    color: Color(0xFF245366),
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu nota aquí',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String note = _noteController.text;
                        if (_editingIndex == -1) {
                          _addEvent(note);
                        } else {
                          _saveEditedEvent();
                        }
                        _noteController.clear();
                        Navigator.of(context).pop();
                      },
                      child:
                          Text(_editingIndex == -1 ? 'Guardar' : 'Actualizar'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF1FBAAF),
                        onPrimary: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _editingIndex = -1;
    });

    _loadEvents(selectedDay);
  }

  void _editEvent(int index) {
    setState(() {
      _editingIndex = index;
      _noteController.text = _events[_selectedDay]?[index] ?? '';
    });
  }

  void _saveEditedEvent() {
    String editedNote = _noteController.text;
    if (editedNote.isNotEmpty && _editingIndex >= 0) {
      setState(() {
        _events[_selectedDay]?[_editingIndex] = editedNote;
      });

      _saveEvents();
      _noteController.clear();
      setState(() {
        _editingIndex = -1;
      });
    }
  }

  void _deleteEvent(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Borrar Nota'),
          content: Text('¿Estás seguro de que quieres borrar esta nota?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _events[_selectedDay]?.removeAt(index);
                });

                _saveEvents();
                Navigator.of(context).pop();
              },
              child: Text(
                'Borrar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveEvents() async {
    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('usuariopaciente')
          .doc(_userId)
          .collection('notas')
          .doc(DateFormat('yyyy-MM-dd').format(_selectedDay))
          .set({'events': _events[_selectedDay]});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FCFB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Text(
                'Mi Calendario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF245366),
                ),
              ),
            ),
            Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 0,
  ),
  child: TableCalendar(
    locale: 'es_ES',
    firstDay: DateTime.utc(2000),
    lastDay: DateTime.utc(2050),
    focusedDay: _focusedDay,
    calendarFormat: _calendarFormat,
    onFormatChanged: (format) {
      setState(() {
        _calendarFormat = format;
      });
    },
    selectedDayPredicate: (day) {
      return isSameDay(_selectedDay, day);
    },
    onDaySelected: _onDaySelected,
    calendarStyle: CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Color(0xFF1FBAAF),
        shape: BoxShape.circle,
      ),
      markersMaxCount: 1, // Establece siempre el markersMaxCount en 1
    ),
    // Utiliza eventLoader para cargar los eventos en cada fecha
    eventLoader: _getEventsForDay,
  ),
),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                'Notas para ${DateFormat('dd/MM/yyyy').format(_selectedDay)}:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF245366),
                ),
              ),
            ),
            Column(
              children: List.generate(
                _events[_selectedDay]?.length ?? 0,
                (index) {
                  return _buildEventCard(index);
                },
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF1FBAAF),
      ),
    );
  }

  Widget _buildEventCard(int index) {
    if (index == _editingIndex) {
      return Container(
        margin: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _noteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Edita tu nota aquí',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _saveEditedEvent,
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF1FBAAF),
                      onPrimary: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _events[_selectedDay]?[index] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF245366),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xFF1FBAAF),
                    ),
                    onPressed: () {
                      _editEvent(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _deleteEvent(index);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
