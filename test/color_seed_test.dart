import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_medical/core/theme/color_seed.dart';

void main() {
  group('ColorSeed', () {
    test('should have 5 color options', () {
      expect(ColorSeed.values.length, 5);
    });

    test('should have correct labels', () {
      expect(ColorSeed.azul.label, 'Azul');
      expect(ColorSeed.rojo.label, 'Rojo');
      expect(ColorSeed.naranja.label, 'Naranja');
      expect(ColorSeed.morado.label, 'Morado');
      expect(ColorSeed.amarillo.label, 'Amarillo');
    });

    test('should have valid colors', () {
      for (final seed in ColorSeed.values) {
        expect(seed.color, isA<Color>());
        expect(seed.color.a, greaterThan(0.0));
      }
    });

    test('should return correct storageKey', () {
      expect(ColorSeed.azul.storageKey, 'azul');
      expect(ColorSeed.rojo.storageKey, 'rojo');
    });

    test('should return default for unknown key', () {
      final result = ColorSeed.fromKey('unknown_key');
      expect(result, ColorSeed.azul);
    });

    test('should return correct seed for valid key', () {
      expect(ColorSeed.fromKey('rojo'), ColorSeed.rojo);
      expect(ColorSeed.fromKey('naranja'), ColorSeed.naranja);
      expect(ColorSeed.fromKey('morado'), ColorSeed.morado);
      expect(ColorSeed.fromKey('amarillo'), ColorSeed.amarillo);
    });
  });
}
