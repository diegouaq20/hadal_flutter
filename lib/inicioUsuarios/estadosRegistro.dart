import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EstadosRegistro extends StatefulWidget {
  const EstadosRegistro({super.key});

  @override
  _EstadosRegistroState createState() => _EstadosRegistroState();
}

class _EstadosRegistroState extends State<EstadosRegistro> {
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
                      8.0, 16.0, 8.0, 8.0), // Ajusta el espacio superior
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
                          setState(() {
                            selectedEstado = estado;
                            selectedMunicipio = "";
                          });
                          estadoSearchController.clear();
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
                        8.0, 16.0, 8.0, 8.0), // Ajusta el espacio superior
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Error",
              style: TextStyle(color: Color(0xFF245366)),
            ),
            content: const Text(
              "No hay municipios disponibles para el estado seleccionado.",
              style: TextStyle(color: Color(0xFF245366)),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    const Text("Cerrar", style: TextStyle(color: Color(0xFF245366))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (context, index) {
                final estado = filteredEstados[index];
                return ListTile(
                  title: Text(
                    estado,
                    style: const TextStyle(color: Color(0xFF245366), fontSize: 18.0),
                  ),
                  onTap: () {
                    setState(() {
                      selectedEstado = estado;
                      selectedMunicipio =
                          ""; // Limpiar selección de municipio al cambiar de estado
                    });
                    estadoSearchController.clear();
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
                          fontSize: 16.0), // Texto más pequeño
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Error",
              style: TextStyle(color: Color(0xFF245366)), // Color del título
            ),
            content: const Text(
              "No hay municipios disponibles para el estado seleccionado.",
              style: TextStyle(color: Color(0xFF245366)),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    const Text("Cerrar", style: TextStyle(color: Color(0xFF245366))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
            SizedBox(width: 40.0), // Ajusta el espaciado derecho del texto
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
              // Tarjeta principal
              Card(
                color: const Color(0xFFF4FCFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0, // Sin sombra
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Selección de Estado y Municipio",
                        style: TextStyle(
                          color: Color(0xFF245366),
                          fontSize: 20.0, // Tamaño de fuente del título
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Resto del contenido de la tarjeta principal
                    // ...
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // Tarjeta de Estado
              Card(
                color: const Color(0xFFF4FCFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0, // Sin sombra
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: estadoSearchController,
                              decoration: InputDecoration(
                                labelText: 'Buscar Estado',
                                labelStyle: const TextStyle(color: Color(0xFF245366)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color:
                                        Color(0xFF1FBAAF), // Color del contorno
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(
                                        0xFF1FBAAF), // Color del contorno al enfocar
                                  ),
                                ),
                              ),
                              onChanged: (text) {
                                // No hacer nada aquí
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search,
                                color: Color(0xFF1FBAAF)), // Color del icono
                            onPressed: () {
                              searchEstados(estadoSearchController.text);
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Estado Seleccionado: ",
                        style: TextStyle(
                            color: Color(0xFF245366),
                            fontSize: 14.0), // Texto más pequeño
                      ),
                      subtitle: Text(
                        selectedEstado,
                        style:
                            const TextStyle(color: Color(0xFF245366), fontSize: 18.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF1FBAAF)), // Color del icono
                        onPressed: () {
                          showEstadoList();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // Tarjeta de Municipio
              Card(
                color: const Color(0xFFF4FCFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0, // Sin sombra
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: municipioSearchController,
                              decoration: InputDecoration(
                                labelText: 'Buscar Municipio',
                                labelStyle: const TextStyle(color: Color(0xFF245366)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color:
                                        Color(0xFF1FBAAF), // Color del contorno
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(
                                        0xFF1FBAAF), // Color del contorno al enfocar
                                  ),
                                ),
                              ),
                              onChanged: (text) {
                                // No hacer nada aquí
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search,
                                color: Color(0xFF1FBAAF)), // Color del icono
                            onPressed: () {
                              searchMunicipios(municipioSearchController.text);
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Municipio Seleccionado: ",
                        style: TextStyle(
                            color: Color(0xFF245366),
                            fontSize: 14.0), // Texto más pequeño
                      ),
                      subtitle: Text(
                        selectedMunicipio,
                        style:
                            const TextStyle(color: Color(0xFF245366), fontSize: 18.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF1FBAAF)), // Color del icono
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
