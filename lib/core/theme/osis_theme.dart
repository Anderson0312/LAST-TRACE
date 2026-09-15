import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Identidade visual OSIS / VANTA — thriller minimalista, premium, não "hacker".
class OsisTheme {
  static const bgDeep = Color(0xFF0B0C10);
  static const bgElevated = Color(0xFF14161C);
  static const glass = Color(0xCC1C1F27);
  static const glassLight = Color(0x99FFFFFF);
  static const textPrimary = Color(0xFFF4F5F7);
  static const textSecondary = Color(0xFF9AA0AE);
  static const accent = Color(0xFF5B8CFF); // azul frio, não roxo
  static const danger = Color(0xFFE85D5D);
  static const success = Color(0xFF4CD964);
  static const wallpaperA = Color(0xFF1A2233);
  static const wallpaperB = Color(0xFF0E121B);
  static const wallpaperC = Color(0xFF243044);

  static ThemeData dark({double fontScale = 1.0}) {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF7A8BA8),
        surface: bgElevated,
        error: danger,
      ),
      fontFamily: 'SF Pro Text', // fallback system; we style via TextStyle
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
        fontSizeFactor: fontScale,
      ),
    );
  }
}

class HapticService {
  static bool enabled = true;

  static Future<void> light() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> error() async {
    if (!enabled) return;
    await HapticFeedback.vibrate();
  }

  static Future<void> discovery() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }
}
