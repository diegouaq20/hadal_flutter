import 'package:flutter/material.dart';

class DescripcionListaTerceros extends StatelessWidget {
  final List<String> serviciosSeleccionados;
  //final List<String> iconosSeleccionados;

  DescripcionListaTerceros({
    required this.serviciosSeleccionados,
    //required this.iconosSeleccionados,
  });

  @override
  Widget build(BuildContext context) {
    // Aquí puedes utilizar serviciosSeleccionados e iconosSeleccionados
    // para mostrar la información que necesitas en esta pantalla.
    return Scaffold(
      appBar: AppBar(
        title: Text('Descripción'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Servicios Seleccionados: ${serviciosSeleccionados.join(', ')}',
              style: TextStyle(fontSize: 18),
            ),
            /*Text(
              'Iconos Seleccionados: ${iconosSeleccionados.join(', ')}',
              style: TextStyle(fontSize: 18),
            ),*/
          ],
        ),
      ),
    );
  }
}