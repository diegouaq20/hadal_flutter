import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VisualizacionImagenes extends StatelessWidget {
  final String photoUrl;

  VisualizacionImagenes({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}