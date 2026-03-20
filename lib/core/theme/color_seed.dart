import 'package:flutter/material.dart';

enum ColorSeed {
  azul('Azul', Color(0xFF137fec)),
  rojo('Rojo', Color(0xFFEF4444)),
  naranja('Naranja', Color(0xFFF97316)),
  morado('Morado', Color(0xFF8B5CF6)),
  amarillo('Amarillo', Color(0xFFEAB308));

  const ColorSeed(this.label, this.color);

  final String label;
  final Color color;

  String get storageKey => name;

  static ColorSeed fromKey(String key) {
    return ColorSeed.values.firstWhere(
      (s) => s.storageKey == key,
      orElse: () => ColorSeed.azul,
    );
  }
}
