import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DocumentosUsuarios extends StatefulWidget {
  final String nombre;
  final String tipoUsuario;
  final String acceso;
  final String userID;
  final String photoUrl;
  final String ine;
  final String curp;
  final String comprobanteDomicilio;
  final String receta;
  final String tituloProfecional;
  final String cedulaProfecional;
  final String referenciaUno;
  final String referenciaDos;

  DocumentosUsuarios(
      this.nombre, this.tipoUsuario, this.acceso, this.userID, this.photoUrl,
      this.ine,this.curp,this.comprobanteDomicilio,this.receta, 
      this.tituloProfecional, this.cedulaProfecional, this.referenciaUno, this.referenciaDos
      );

  @override
  _DocumentosUsuariosState createState() => _DocumentosUsuariosState();
}

class _DocumentosUsuariosState extends State<DocumentosUsuarios> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  bool _accesoDesbloqueado = false;
  bool _updated = false;

  Future<void> actualizarEstadoUsuario() async {
    DocumentReference usuario =
        firestore.collection("usuariopaciente").doc(widget.userID);

    await usuario
        .update({"acceso": _accesoDesbloqueado ? "desbloqueado" : "bloqueado"})
        .then((value) {
      print("Estado de usuario actualizado correctamente");
    }).catchError((error) {
      print("Hubo un error al actualizar el estado de usuario: $error");
    });
  }

  void _showAvatarFullscreen() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.photoUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showAvatarFullscreenIne() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.ine),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
void _showAvatarFullscreenCurp() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.curp),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
void _showAvatarFullscreenComprobante() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.comprobanteDomicilio),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
void _showAvatarFullscreenReceta() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.receta),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
////////////////////////////////////////////////////////
//pantallas para mostrar fullscreen de las enfermeras

void _showAvatarFullscreenTituloProfecional() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.tituloProfecional),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showAvatarFullscreenCedulaProfecional() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.cedulaProfecional),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showAvatarFullscreenReferenciaUno() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.referenciaUno),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showAvatarFullscreenReferenciaDos() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child: InteractiveViewer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.referenciaDos),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
  if (!_updated) {
    _accesoDesbloqueado = widget.acceso == "desbloqueado";
  }
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      title: Text('Documentos de ${widget.nombre}'),
    ),
    body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${widget.nombre}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tipo de usuario: ${widget.tipoUsuario}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  'Acceso:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Switch(
                  value: _accesoDesbloqueado,
                  onChanged: (value) async {
                    setState(() {
                      _accesoDesbloqueado = value;
                      _updated = true; // Update immediately after switch is switched
                    });
                    await actualizarEstadoUsuario();
                  },
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey,
                ),
                SizedBox(width: 10),
                Text(
                  _accesoDesbloqueado ? 'Desbloqueado' : 'Bloqueado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              'Id del usuario: ${widget.userID}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Documentos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            //foto de perfil
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                      widget.photoUrl,
                    ),
                    backgroundColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              "Foto de perfil",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                              ),
                            ),
                          ),
                          height: 30,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                  onTap: _showAvatarFullscreen,
                ),
              ],
            ),

            //condicion por si es paciente solo mostrar documentos de paciente
            if(widget.tipoUsuario == 'Paciente' && widget.tipoUsuario != 'Enfermera')
            // Folders in grid
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenIne();
                      },
                    ),
                    Text(
                      "INE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenCurp();
                      },
                    ),
                    Text(
                      "CURP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenComprobante();
                      },
                    ),
                    Text(
                      "COMPROBANTE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if(widget.tipoUsuario == 'Paciente' && widget.tipoUsuario != 'Enfermera')
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenReceta();
                      },
                    ),
                    Text(
                      "RECETA",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //condicion para mostrar los archivos adicionales si es enfermera
            if(widget.tipoUsuario == 'Enfermera' && widget.tipoUsuario != 'Paciente')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenTituloProfecional();
                      },
                    ),
                    Text(
                      "Título Profecional",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenCedulaProfecional();
                      },
                    ),
                    Text(
                      "Cédula Profecional",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if(widget.tipoUsuario == 'Enfermera' && widget.tipoUsuario != 'Paciente')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenReferenciaUno();
                      },
                    ),
                    Text(
                      "Primer  Referencia",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.folder,
                        size: 150,
                        color: Color(0xFF1FBAAF),
                      ),
                      onTap: () {
                        _showAvatarFullscreenReferenciaDos();
                      },
                    ),
                    Text(
                      "Segunda Referencia",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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