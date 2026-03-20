import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Model3DViewer extends StatelessWidget {
  final String src;
  final String? alt;

  const Model3DViewer({super.key, required this.src, this.alt});

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      src: src,
      alt: alt ?? "A 3D model",
      ar: true,
      autoRotate: true,
      cameraControls: true,
    );
  }
}
