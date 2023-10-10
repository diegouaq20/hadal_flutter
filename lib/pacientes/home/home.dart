import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadal/pacientes/procedimientoServicios/pantallaDescripcion.dart';
import 'package:hadal/pacientes/procedimientoServicios/detallesCitas.dart';
import 'verMas.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String nombre = "";
  String primerApellido = "";
  String segundoApellido = "";
  String tipoUsuario = "";
  String tipoCategoria = "";

  List<QueryDocumentSnapshot> serviciosBasicosDocs = [];
  bool showContent = false;

  void _getUserData() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('usuariopaciente')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (documentSnapshot.exists) {
      setState(() {
        nombre = documentSnapshot.get('nombre') ?? "";
        primerApellido = documentSnapshot.get('primerApellido') ?? "";
        segundoApellido = documentSnapshot.get('segundoApellido') ?? "";
        tipoUsuario = documentSnapshot.get('tipoUsuario') ?? "";
        showContent = true; // Mostrar contenido después de cargar los datos
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    _loadServicios();
  }

  void _loadServicios() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('serviciosbasicos')
        .limit(4)
        .get();

    setState(() {
      serviciosBasicosDocs = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showContent ? 1.0 : 0.0,
      duration: Duration(milliseconds: 800),
      child: Column(
        children: [
          Container(
            color: Color(0xFFCFE3E1),
            width: double.infinity,
            child: nombre != "" &&
                    primerApellido != "" &&
                    segundoApellido != "" &&
                    tipoUsuario != ""
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 3; i++)
                            Expanded(
                              flex: i == 1 ? 2 : 1,
                              child: i == 1
                                  ? Image.asset(
                                      'assets/logoInicio.png',
                                      width: 130,
                                      height: 130,
                                    )
                                  : Container(),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          for (String field in [
                            'BIENVENIDO',
                            '$nombre $primerApellido $segundoApellido',
                            '$tipoUsuario'
                          ])
                            FittedBox(
                              child: Text(
                                field,
                                style: TextStyle(
                                    fontSize:
                                        field.contains('BIENVENIDO') ? 18 : 28,
                                    color: Color(0xFF245366)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                : Text(''),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFF4FCFB),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 35.0, top: 20.0, bottom: 20.0),
                          child: Text(
                            'Servicios',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => verMas(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: 35.0, top: 20.0, bottom: 20.0),
                            child: Text(
                              'Ver más',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF1FBAAF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      constraints: BoxConstraints(maxHeight: 60),
                      child: Center(
                        child: Wrap(
                          spacing: 27,
                          runSpacing: 10,
                          children: serviciosBasicosDocs.map((servicioDoc) {
                            final data =
                                servicioDoc.data() as Map<String, dynamic>;
                            final serviceName = data['procedimiento'];
                            final serviceIconUrl = data['icono'];

                            final serviceNameFormatted = serviceName.length > 10
                                ? serviceName.substring(0, 8) + '..'
                                : serviceName;

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Descripcion(
                                          servicio: servicioDoc,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF6FFFE),
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SvgPicture.network(
                                          serviceIconUrl,
                                          height: 40.0,
                                          color: Color(0xFF7C7F83),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Text(
                                    serviceNameFormatted,
                                    style: TextStyle(
                                      color: Color(0xFF235365),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 35.0, top: 20.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Citas',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF245366),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dentro del StreamBuilder actual, donde deseas mostrar la foto de perfil
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('citas')
                          .where('pacienteId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Mostrar un indicador de carga mientras se espera la consulta.
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 75), // Ajusta el valor del padding vertical
                              child: Text(
                                'No hay servicios pendientes.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }

                        final citasUsuario = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: citasUsuario.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final citaData = citasUsuario[index].data()
                                as Map<String, dynamic>;
                            final citaId = citasUsuario[index].id;
                            final servicio = citaData['servicio'];
                            final servicioRecortado = servicio.length > 15
                                ? servicio.substring(0, 15) + '...'
                                : servicio;
                            final tipoServicio = citaData['tipoServicio'];
                            final hora = citaData['hora'];
                            final nombre = citaData['nombre'];
                            final domicilio = citaData['domicilio'];
                            //final ubicacion = citaData['uicacionPaciente'];
                            final enfermeraId = citaData['enfermeraId'] ?? '';
                            final pacienteId = citaData['pacienteId'] ?? '';
                            final estado = citaData['estado'];
                            final iconoUrl = citaData['icono'];
                            final dia = citaData['dia'];
                            final diaDelMes = citaData['diaDelMes'];
                            final mes = citaData['mes'];
                            //final photoUrl = citaData['photoUrl'];
                            final tipoCategoria = citaData['tipoCategoria'];
                            final total = citaData['total'].toString();
                            //final distancia = citaData['distancia'];

                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    FutureBuilder<DocumentSnapshot>(
  future: enfermeraId.isNotEmpty
      ? FirebaseFirestore.instance
          .collection('usuarioenfermera')
          .doc(enfermeraId)
          .get()
      : null, // Usar null como future cuando enfermeraId esté vacío
  builder: (context, enfermeraSnapshot) {
    if (enfermeraId.isNotEmpty && enfermeraSnapshot.connectionState ==
        ConnectionState.waiting) {
      // Mostrar un indicador de carga mientras se espera la consulta.
      return CircularProgressIndicator();
    }

    if (enfermeraId.isEmpty || !enfermeraSnapshot.hasData) {
      // Mostrar un icono de perfil predeterminado si enfermeraId está vacío o no hay datos de la enfermera.
      return CircleAvatar(
        child: Icon(Icons.person, size: 20, color: Colors.white),
        backgroundColor: Color(0xFF235365),
        radius: 30,
      );
    }

    final enfermeraData =
        enfermeraSnapshot.data!.data() as Map<String, dynamic>;
    final enfermeraPhotoUrl = enfermeraData['photoUrl'];

    return CachedNetworkImage(
      imageUrl: enfermeraPhotoUrl,
      placeholder: (context, url) => CircleAvatar(
        child: Icon(Icons.person, size: 20, color: Colors.white),
        backgroundColor: Color(0xFF235365),
        radius: 30,
      ), // Indicador de carga personalizado
      errorWidget: (context, url, error) => Icon(
          Icons.error), // Widget para mostrar en caso de error
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
        radius: 30,
      ),
    );
  },
),

                                    SizedBox(
                                        width:
                                            10), // Espacio entre la imagen y el serviceName
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          servicio,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF235365),
                                          ),
                                          maxLines: 2, // Limitar a una línea
                                          overflow: TextOverflow
                                              .ellipsis, // Mostrar puntos suspensivos (...) si se desborda
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  ListTile(
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Usuario: $nombre',
                                          style: TextStyle(
                                              color: Color(0xFF235365)),
                                        ),
                                        Text(
                                          'Fecha: $dia, $diaDelMes de $mes',
                                          style: TextStyle(
                                              color: Color(0xFF235365)),
                                        ),
                                        Text(
                                          'Hora: $hora',
                                          style: TextStyle(
                                              color: Color(0xFF235365)),
                                        ),
                                        Text(
                                          'Estado: $estado',
                                          style: TextStyle(
                                              color: Color(0xFF235365)),
                                        ),
                                        Text(
                                          'Total: \$${total}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF235365)),
                                        ),
                                        SizedBox(height: 10),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetallesCita(
                                                    dia: dia,
                                                    diaDelMes: diaDelMes,
                                                    domicilio: domicilio,
                                                    //ubicacionPaciente: ubicacion,
                                                    estado: estado,
                                                    hora: hora,
                                                    icono: iconoUrl,
                                                    mes: mes,
                                                    nombre: nombre,
                                                    servicio: servicio,
                                                    tipoCategoria: tipoCategoria,
                                                    tipoServicio: tipoServicio,
                                                    total: total,
                                                    fecha: '$dia, $diaDelMes de $mes',
                                                    categoria: 'Servicio $tipoCategoria',
                                                    pacienteId: pacienteId,
                                                    enfermeraId: enfermeraId,
                                                    citaId: citaId, // Agregado citaId aquí
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xFF235365),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              'Ver más detalles',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
