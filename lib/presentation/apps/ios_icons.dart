import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'apple_sf.dart';

/// Ícones da SpringBoard no formato do HIG:
/// [App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
/// — canvas quadrado, máscara squircle (~22.37%), camadas Liquid Glass.
/// Glifos: [SF Symbols](https://developer.apple.com/sf-symbols/) via Cupertino.
enum IosIconStyle {
  phone,
  messages,
  safari,
  camera,
  photos,
  mail,
  maps,
  notes,
  files,
  calendar,
  contacts,
  settings,
  instagram,
  bank,
  voiceMemo,
  clock,
  weather,
  mystery,
  board,
  trash,
  search,
}

class IosAppIcon extends StatelessWidget {
  final IosIconStyle style;
  final double size;

  const IosAppIcon({super.key, required this.style, this.size = 60});

  /// Raio de parâmetro do squircle iOS (~22.37% do lado).
  static double squircleRadius(double size) => size * 0.2237;

  @override
  Widget build(BuildContext context) {
    final radius = squircleRadius(size);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: _glow.withValues(alpha: 0.32),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(decoration: BoxDecoration(gradient: _gradient)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x8CFFFFFF),
                      Color(0x1FFFFFFF),
                      Color(0x00000000),
                      Color(0x1F000000),
                    ],
                    stops: [0.0, 0.28, 0.55, 1.0],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size * 0.38,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x59FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
              _glyph(),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.42),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glyph() {
    if (style == IosIconStyle.calendar) {
      return _CalendarGlyph(size: size);
    }
    if (style == IosIconStyle.photos) {
      return _PhotosGlyph(size: size);
    }
    return Center(
      child: Icon(
        _symbol,
        size: size * 0.50,
        color: _glyphColor,
      ),
    );
  }

  IconData get _symbol {
    switch (style) {
      case IosIconStyle.phone:
        return AppleSymbol.phone;
      case IosIconStyle.messages:
        return AppleSymbol.messages;
      case IosIconStyle.safari:
        return AppleSymbol.safari;
      case IosIconStyle.camera:
        return AppleSymbol.camera;
      case IosIconStyle.photos:
        return AppleSymbol.photos;
      case IosIconStyle.mail:
        return AppleSymbol.mail;
      case IosIconStyle.maps:
        return AppleSymbol.maps;
      case IosIconStyle.notes:
        return AppleSymbol.notes;
      case IosIconStyle.files:
        return AppleSymbol.files;
      case IosIconStyle.calendar:
        return AppleSymbol.calendar;
      case IosIconStyle.contacts:
        return AppleSymbol.contacts;
      case IosIconStyle.settings:
        return AppleSymbol.settings;
      case IosIconStyle.instagram:
        return AppleSymbol.instagram;
      case IosIconStyle.bank:
        return AppleSymbol.wallet;
      case IosIconStyle.voiceMemo:
        return AppleSymbol.voiceMemo;
      case IosIconStyle.clock:
        return AppleSymbol.clock;
      case IosIconStyle.weather:
        return AppleSymbol.weather;
      case IosIconStyle.mystery:
        return AppleSymbol.mystery;
      case IosIconStyle.board:
        return AppleSymbol.board;
      case IosIconStyle.trash:
        return AppleSymbol.trash;
      case IosIconStyle.search:
        return AppleSymbol.search;
    }
  }

  Color get _glyphColor {
    switch (style) {
      case IosIconStyle.notes:
        return const Color(0xFF1C1C1E);
      case IosIconStyle.safari:
        return AppleColor.red;
      default:
        return Colors.white;
    }
  }

  Color get _glow {
    switch (style) {
      case IosIconStyle.messages:
        return const Color(0xFF25D366);
      case IosIconStyle.instagram:
        return const Color(0xFFDD2A7B);
      case IosIconStyle.phone:
      case IosIconStyle.mail:
      case IosIconStyle.safari:
        return AppleColor.blue;
      case IosIconStyle.bank:
        return AppleColor.purple;
      case IosIconStyle.voiceMemo:
        return AppleColor.red;
      default:
        return Colors.white;
    }
  }

  LinearGradient get _gradient {
    switch (style) {
      case IosIconStyle.phone:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64D2FF), AppleColor.blue],
        );
      case IosIconStyle.messages:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        );
      case IosIconStyle.safari:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD1D1D6), AppleColor.gray5],
        );
      case IosIconStyle.camera:
        return const LinearGradient(
          colors: [AppleColor.gray, AppleColor.gray4],
        );
      case IosIconStyle.photos:
        return const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
        );
      case IosIconStyle.mail:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppleColor.cyan, AppleColor.blue],
        );
      case IosIconStyle.maps:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppleColor.cyan, AppleColor.green],
        );
      case IosIconStyle.notes:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6B0), AppleColor.yellow],
        );
      case IosIconStyle.files:
        return const LinearGradient(
          colors: [AppleColor.cyan, AppleColor.blue],
        );
      case IosIconStyle.calendar:
        return const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
        );
      case IosIconStyle.contacts:
      case IosIconStyle.settings:
      case IosIconStyle.trash:
      case IosIconStyle.search:
        return const LinearGradient(
          colors: [AppleColor.gray, AppleColor.gray2],
        );
      case IosIconStyle.instagram:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFEDA77),
            Color(0xFFF58529),
            Color(0xFFDD2A7B),
            Color(0xFF8134AF),
            Color(0xFF515BD4),
          ],
        );
      case IosIconStyle.bank:
        return const LinearGradient(
          colors: [Color(0xFF9B30E8), Color(0xFF5B0A9E)],
        );
      case IosIconStyle.voiceMemo:
        return const LinearGradient(
          colors: [AppleColor.red, Color(0xFFBF140A)],
        );
      case IosIconStyle.clock:
      case IosIconStyle.mystery:
        return const LinearGradient(
          colors: [AppleColor.gray4, AppleColor.gray6],
        );
      case IosIconStyle.weather:
        return const LinearGradient(
          colors: [AppleColor.cyan, AppleColor.blue],
        );
      case IosIconStyle.board:
        return const LinearGradient(
          colors: [AppleColor.purple, AppleColor.indigo],
        );
    }
  }
}

class _CalendarGlyph extends StatelessWidget {
  final double size;
  const _CalendarGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
    return Column(
      children: [
        SizedBox(height: size * 0.12),
        Text(
          weekdays[now.weekday % 7],
          style: TextStyle(
            color: AppleColor.red,
            fontSize: size * 0.16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            height: 1,
          ),
        ),
        Text(
          '${now.day}',
          style: TextStyle(
            color: const Color(0xFF1C1C1E),
            fontSize: size * 0.46,
            fontWeight: FontWeight.w300,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _PhotosGlyph extends StatelessWidget {
  final double size;
  const _PhotosGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    const petals = [
      AppleColor.blue,
      AppleColor.orange,
      AppleColor.red,
      AppleColor.pink,
      AppleColor.purple,
      AppleColor.indigo,
      AppleColor.green,
      AppleColor.yellow,
    ];
    return Center(
      child: SizedBox(
        width: size * 0.62,
        height: size * 0.62,
        child: CustomPaint(painter: _PetalPainter(petals)),
      ),
    );
  }
}

class _PetalPainter extends CustomPainter {
  final List<Color> colors;
  const _PetalPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.16;
    final dist = size.width * 0.22;
    for (var i = 0; i < colors.length; i++) {
      final dir = Offset.fromDirection((i / colors.length) * 6.28318530718);
      canvas.drawCircle(
        c + dir * dist,
        r,
        Paint()..color = colors[i].withValues(alpha: 0.92),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) => false;
}
