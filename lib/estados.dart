import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EstadosScreen extends StatefulWidget {
  const EstadosScreen({Key? key}) : super(key: key);

  @override
  _EstadosScreenState createState() => _EstadosScreenState();
}

class _EstadosScreenState extends State<EstadosScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();

  List<String> estados = [];
  Map<String, Map<String, dynamic>> nodosPorEstado = {};

  String selectedEstado = "";
  String selectedMunicipio = "";

  TextEditingController estadoSearchController = TextEditingController();
  TextEditingController municipioSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEstados();
  }

  void fetchEstados() {
    databaseReference.once().then((DatabaseEvent databaseEvent) {
      final DataSnapshot dataSnapshot = databaseEvent.snapshot;
      if (dataSnapshot.value is Map<dynamic, dynamic>) {
        final Map<dynamic, dynamic> data =
            dataSnapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          estados.add(key.toString());
          if (value is Map<dynamic, dynamic>) {
            final Map<String, dynamic> nodos = Map<String, dynamic>.from(value);
            nodosPorEstado[key.toString()] = nodos;
          }
        });
        setState(() {});
      }
    });
  }

  void showEstadoList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                      8.0, 16.0, 8.0, 8.0),
                  child: Text(
                    "Seleccionar Estado",
                    style: TextStyle(
                      color: Color(0xFF245366),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                Container(
                  height: 300,
                  child: ListView.separated(
                    itemCount: estados.length,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemBuilder: (context, index) {
                      final estado = estados[index];
                      return ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            estado,
                            style: const TextStyle(
                                color: Color(0xFF245366), fontSize: 18.0),
                          ),
                        ),
                        onTap: () {
                          final produccion = nodosPorEstado[estado]?['produccion'];
                          if (produccion is bool && !produccion) {
                            showNotAvailableDialog();
                          } else {
                            setState(() {
                              selectedEstado = estado;
                              selectedMunicipio = "";
                            });
                            estadoSearchController.clear();
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMunicipioList() {
    if (selectedEstado.isNotEmpty &&
        nodosPorEstado.containsKey(selectedEstado)) {
      final municipios =
          nodosPorEstado[selectedEstado]?.values.where((municipio) {
        return municipio is String;
      }).toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                        8.0, 16.0, 8.0, 8.0),
                    child: Text(
                      "Seleccionar Municipio",
                      style: TextStyle(
                        color: Color(0xFF245366),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Container(
                    height: 300,
                    child: ListView.separated(
                      itemCount: municipios!.length,
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (context, index) {
                        final municipio = municipios[index];
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              municipio.toString(),
                              style: const TextStyle(
                                  color: Color(0xFF245366), fontSize: 16.0),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedMunicipio = municipio.toString();
                            });
                            municipioSearchController.clear();
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showNotAvailableDialog();
    }
  }

  void showNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Estado no disponible",
            style: TextStyle(color: Color(0xFF245366)),
          ),
          content: const Text(
            "La app no está disponible en este estado por el momento.",
            style: TextStyle(color: Color(0xFF245366)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar",
                  style: TextStyle(color: Color(0xFF245366))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void searchEstados(String text) {
    final filteredEstados = estados.where((estado) {
      return estado.toLowerCase().contains(text.toLowerCase());
    }).toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: double.maxFinite,
            child: ListView.separated(
              itemCount: filteredEstados.length,
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (context, index) {
                final estado = filteredEstados[index];
                return ListTile(
                  title: Text(
                    estado,
                    style: const TextStyle(color: Color(0xFF245366), fontSize: 18.0),
                  ),
                  onTap: () {
                    final produccion = nodosPorEstado[estado]?['produccion'];
                    if (produccion is bool && !produccion) {
                      showNotAvailableDialog();
                    } else {
                      setState(() {
                        selectedEstado = estado;
                        selectedMunicipio = "";
                      });
                      estadoSearchController.clear();
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void searchMunicipios(String text) {
    if (selectedEstado.isNotEmpty &&
        nodosPorEstado.containsKey(selectedEstado)) {
      final municipios =
          nodosPorEstado[selectedEstado]?.values.where((municipio) {
        return municipio is String &&
            municipio.toLowerCase().contains(text.toLowerCase());
      }).toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: double.maxFinite,
              child: ListView.separated(
                itemCount: municipios!.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final municipio = municipios[index];
                  return ListTile(
                    title: Text(
                      municipio.toString(),
                      style: const TextStyle(
                          color: Color(0xFF245366),
                          fontSize: 16.0),
                    ),
                    onTap: () {
                      setState(() {
                        selectedMunicipio = municipio.toString();
                      });
                      municipioSearchController.clear();
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } else {
      showNotAvailableDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FCFB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4FCFB),
        title: Row(
          children: [
            SizedBox(width: 40.0),
            Text(
              'Estado y Municipio',
              style: TextStyle(
                color: Color(0xFF235365),
                fontSize: 20,
              ),
            ),
          ],
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
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: const Color(0xFFF4FCFB),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                color: const Color(0xFFF4FCFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Selección de Estado y Municipio",
                        style: TextStyle(
                          color: Color(0xFF245366),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                color: const Color(0xFFF4FCFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
  padding: const EdgeInsets.all(8.0),
  child: TextField(
    controller: estadoSearchController,
    decoration: InputDecoration(
      labelText: 'Buscar Estado',
      labelStyle: const TextStyle(color: Color(0xFF245366)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Color(0xFF1FBAAF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Color(0xFF1FBAAF),
        ),
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.search, color: Color(0xFF1FBAAF)),
        onPressed: () {
          searchEstados(estadoSearchController.text);
        },
      ),
    ),
    onChanged: (text) {
      // No hacer nada aquí
    },
  ),
),

                    ListTile(
                      title: const Text(
                        "Estado Seleccionado: ",
                        style: TextStyle(
                            color: Color(0xFF245366),
                            fontSize: 14.0),
                      ),
                      subtitle: Text(
                        selectedEstado,
                        style:
                            const TextStyle(color: Color(0xFF245366), fontSize: 18.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF1FBAAF)),
                        onPressed: () {
                          showEstadoList();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                color: const Color(0xFFF4FCFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
  padding: const EdgeInsets.all(8.0),
  child: TextField(
    controller: municipioSearchController,
    decoration: InputDecoration(
      labelText: 'Buscar Municipio',
      labelStyle: const TextStyle(color: Color(0xFF245366)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Color(0xFF1FBAAF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Color(0xFF1FBAAF),
        ),
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.search, color: Color(0xFF1FBAAF)),
        onPressed: () {
          searchMunicipios(municipioSearchController.text);
        },
      ),
    ),
    onChanged: (text) {
      // No hacer nada aquí
    },
  ),
),

                    ListTile(
                      title: const Text(
                        "Municipio Seleccionado: ",
                        style: TextStyle(
                            color: Color(0xFF245366),
                            fontSize: 14.0),
                      ),
                      subtitle: Text(
                        selectedMunicipio,
                        style:
                            const TextStyle(color: Color(0xFF245366), fontSize: 18.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF1FBAAF)),
                        onPressed: () {
                          showMunicipioList();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
