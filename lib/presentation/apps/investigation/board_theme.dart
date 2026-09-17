import 'package:flutter/material.dart';

/// Paleta cinematográfica do Quadro de Investigação (cortiça / thriller).
class BoardTheme {
  static const corkDeep = Color(0xFF2A1F16);
  static const corkMid = Color(0xFF3D2E22);
  static const corkLight = Color(0xFF4A3828);
  static const corkGrain = Color(0xFF1A120C);
  static const thread = Color(0xFFC62828);
  static const threadDark = Color(0xFF8B1A1A);
  static const pinHead = Color(0xFFE8E4DC);
  static const pinMetal = Color(0xFF9E9A92);
  static const polaroid = Color(0xFFF3EDE2);
  static const polaroidInk = Color(0xFF1C1712);
  static const paper = Color(0xFFEDE6D6);
  static const paperLines = Color(0xFFD4CBB8);
  static const stickyYellow = Color(0xFFE8D56A);
  static const stickyPink = Color(0xFFE8A8B8);
  static const stickyBlue = Color(0xFFA8C8E0);
  static const stickyGreen = Color(0xFFB8D4A8);
  static const labelVictim = Color(0xFF8B1A1A);
  static const labelSuspect = Color(0xFFB45309);
  static const labelWitness = Color(0xFF1D4E89);
  static const labelContact = Color(0xFF3F4A3C);
  static const labelUnknown = Color(0xFF4A4458);
  static const theoryBg = Color(0xFF1E2430);
  static const theoryBorder = Color(0xFF5B8CFF);

  static Color stickyFor(int style) {
    switch (style % 4) {
      case 1:
        return stickyPink;
      case 2:
        return stickyBlue;
      case 3:
        return stickyGreen;
      default:
        return stickyYellow;
    }
  }

  static List<Color> get corkGradient => const [
        Color(0xFF241910),
        Color(0xFF352618),
        Color(0xFF2C1F15),
        Color(0xFF3A2A1C),
      ];
}

enum BoardFilter { all, people, places, events, clues, theories }

extension BoardFilterLabel on BoardFilter {
  String get label {
    switch (this) {
      case BoardFilter.all:
        return 'Todos';
      case BoardFilter.people:
        return 'Pessoas';
      case BoardFilter.places:
        return 'Locais';
      case BoardFilter.events:
        return 'Eventos';
      case BoardFilter.clues:
        return 'Pistas';
      case BoardFilter.theories:
        return 'Teorias';
    }
  }
}
