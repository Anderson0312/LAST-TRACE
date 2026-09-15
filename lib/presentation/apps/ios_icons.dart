import 'package:flutter/material.dart';

/// Ícones estilo iOS — visual familiar, desenhados em código (sem assets proprietários).
enum IosIconStyle {
  phone,
  messages, // WhatsApp-like
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

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.2237;
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: _glow.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
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
              // Base color / glass tint
              DecoratedBox(decoration: BoxDecoration(gradient: _gradient)),
              // Specular liquid-glass highlight
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.12),
                    ],
                    stops: const [0.0, 0.28, 0.55, 1.0],
                  ),
                ),
              ),
              // Inner top rim light
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size * 0.38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Glyph
              CustomPaint(painter: _IconPainter(style)),
              // Glass border
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
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

  Color get _glow {
    switch (style) {
      case IosIconStyle.messages:
        return const Color(0xFF25D366);
      case IosIconStyle.instagram:
        return const Color(0xFFDD2A7B);
      case IosIconStyle.phone:
      case IosIconStyle.mail:
      case IosIconStyle.safari:
        return const Color(0xFF0A84FF);
      case IosIconStyle.bank:
        return const Color(0xFF820AD1);
      case IosIconStyle.voiceMemo:
        return const Color(0xFFFF453A);
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
          colors: [Color(0xAA64D2FF), Color(0xCC0A84FF)],
        );
      case IosIconStyle.messages:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xBB25D366), Color(0xCC128C7E)],
        );
      case IosIconStyle.safari:
        return const LinearGradient(
          colors: [Color(0xBBD0D0D5), Color(0xCC2C2C2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case IosIconStyle.camera:
        return const LinearGradient(
          colors: [Color(0xBB9E9EA3), Color(0xCC3A3A3C)],
        );
      case IosIconStyle.photos:
        return const LinearGradient(
          colors: [Color(0xEEFFFFFF), Color(0xCCF2F2F7)],
        );
      case IosIconStyle.mail:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xBB5AC8FA), Color(0xCC007AFF)],
        );
      case IosIconStyle.maps:
        return const LinearGradient(
          colors: [Color(0xBB64D2FF), Color(0xCC30D158)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case IosIconStyle.notes:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEEFFF9C4), Color(0xCCFFCC00)],
        );
      case IosIconStyle.files:
        return const LinearGradient(
          colors: [Color(0xBB5AC8FA), Color(0xCC007AFF)],
        );
      case IosIconStyle.calendar:
        return const LinearGradient(
          colors: [Color(0xEEFFFFFF), Color(0xCCF2F2F7)],
        );
      case IosIconStyle.contacts:
        return const LinearGradient(
          colors: [Color(0xBB9E9EA3), Color(0xCC636366)],
        );
      case IosIconStyle.settings:
        return const LinearGradient(
          colors: [Color(0xBB9E9EA3), Color(0xCC636366)],
        );
      case IosIconStyle.instagram:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xCCFEDA77),
            Color(0xCCF58529),
            Color(0xCCDD2A7B),
            Color(0xCC8134AF),
            Color(0xCC515BD4),
          ],
        );
      case IosIconStyle.bank:
        return const LinearGradient(
          colors: [Color(0xBB9B30E8), Color(0xCC5B0A9E)],
        );
      case IosIconStyle.voiceMemo:
        return const LinearGradient(
          colors: [Color(0xBBFF453A), Color(0xCCBF140A)],
        );
      case IosIconStyle.clock:
        return const LinearGradient(
          colors: [Color(0xBB3A3A3C), Color(0xCC000000)],
        );
      case IosIconStyle.weather:
        return const LinearGradient(
          colors: [Color(0xBB64D2FF), Color(0xCC0A84FF)],
        );
      case IosIconStyle.mystery:
        return const LinearGradient(
          colors: [Color(0xBB3A3A3C), Color(0xCC1C1C1E)],
        );
      case IosIconStyle.board:
        return const LinearGradient(
          colors: [Color(0xBBAF52DE), Color(0xCC5856D6)],
        );
      case IosIconStyle.trash:
        return const LinearGradient(
          colors: [Color(0xBB9E9EA3), Color(0xCC636366)],
        );
      case IosIconStyle.search:
        return const LinearGradient(
          colors: [Color(0xBB9E9EA3), Color(0xCC48484A)],
        );
    }
  }
}

class _IconPainter extends CustomPainter {
  final IosIconStyle style;
  _IconPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case IosIconStyle.phone:
        _phone(canvas, size);
      case IosIconStyle.messages:
        _whatsapp(canvas, size);
      case IosIconStyle.safari:
        _safari(canvas, size);
      case IosIconStyle.camera:
        _camera(canvas, size);
      case IosIconStyle.photos:
        _photos(canvas, size);
      case IosIconStyle.mail:
        _mail(canvas, size);
      case IosIconStyle.maps:
        _maps(canvas, size);
      case IosIconStyle.notes:
        _notes(canvas, size);
      case IosIconStyle.files:
        _folder(canvas, size);
      case IosIconStyle.calendar:
        _calendar(canvas, size);
      case IosIconStyle.contacts:
        _contacts(canvas, size);
      case IosIconStyle.settings:
        _gear(canvas, size);
      case IosIconStyle.instagram:
        _instagram(canvas, size);
      case IosIconStyle.bank:
        _bank(canvas, size);
      case IosIconStyle.voiceMemo:
        _mic(canvas, size);
      case IosIconStyle.clock:
        _clock(canvas, size);
      case IosIconStyle.weather:
        _sun(canvas, size);
      case IosIconStyle.mystery:
        _question(canvas, size);
      case IosIconStyle.board:
        _board(canvas, size);
      case IosIconStyle.trash:
        _trash(canvas, size);
      case IosIconStyle.search:
        _search(canvas, size);
    }
  }

  void _phone(Canvas c, Size s) {
    final p = Paint()..color = Colors.white;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width / 2, s.height / 2), width: s.width * 0.38, height: s.height * 0.5),
        Radius.circular(s.width * 0.08),
      ));
    c.drawPath(path, p);
  }

  void _whatsapp(Canvas c, Size s) {
    final p = Paint()..color = Colors.white;
    c.drawCircle(Offset(s.width / 2, s.height / 2 - 2), s.width * 0.28, p);
    final tail = Path()
      ..moveTo(s.width * 0.28, s.height * 0.68)
      ..lineTo(s.width * 0.22, s.height * 0.82)
      ..lineTo(s.width * 0.42, s.height * 0.7)
      ..close();
    c.drawPath(tail, p);
    final phone = Paint()
      ..color = const Color(0xFF128C7E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    c.drawArc(
      Rect.fromCenter(center: Offset(s.width / 2, s.height / 2 - 2), width: s.width * 0.28, height: s.height * 0.28),
      0.8,
      2.2,
      false,
      phone,
    );
  }

  void _safari(Canvas c, Size s) {
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.28, ring);
    final needle = Path()
      ..moveTo(s.width * 0.5, s.height * 0.22)
      ..lineTo(s.width * 0.58, s.height * 0.58)
      ..lineTo(s.width * 0.5, s.height * 0.52)
      ..lineTo(s.width * 0.42, s.height * 0.58)
      ..close();
    c.drawPath(needle, Paint()..color = const Color(0xFFFF3B30));
    c.drawPath(
      Path()
        ..moveTo(s.width * 0.5, s.height * 0.78)
        ..lineTo(s.width * 0.42, s.height * 0.42)
        ..lineTo(s.width * 0.5, s.height * 0.48)
        ..lineTo(s.width * 0.58, s.height * 0.42)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  void _camera(Canvas c, Size s) {
    final body = Paint()..color = Colors.white;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width / 2, s.height / 2), width: s.width * 0.55, height: s.height * 0.4),
        const Radius.circular(8),
      ),
      body,
    );
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.14, Paint()..color = const Color(0xFF1C1C1E));
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.08, Paint()..color = const Color(0xFF5AC8FA));
  }

  void _photos(Canvas c, Size s) {
    final colors = [
      const Color(0xFFFF2D55),
      const Color(0xFFFF9500),
      const Color(0xFFFFCC00),
      const Color(0xFF34C759),
      const Color(0xFF5AC8FA),
      const Color(0xFF007AFF),
      const Color(0xFF5856D6),
      const Color(0xFFAF52DE),
    ];
    for (var i = 0; i < 8; i++) {
      final a = i * 0.785;
      c.drawCircle(
        Offset(s.width / 2 + 10 * (i.isEven ? 1 : -0.3), s.height / 2),
        0,
        Paint(),
      );
      final p = Paint()..color = colors[i].withValues(alpha: 0.85);
      c.save();
      c.translate(s.width / 2, s.height / 2);
      c.rotate(a);
      c.drawOval(Rect.fromCenter(center: const Offset(0, -8), width: 14, height: 22), p);
      c.restore();
    }
  }

  void _mail(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(s.width / 2, s.height / 2), width: s.width * 0.55, height: s.height * 0.4),
      const Radius.circular(4),
    );
    c.drawRRect(r, p);
    c.drawLine(Offset(s.width * 0.24, s.height * 0.38), Offset(s.width / 2, s.height * 0.55), p);
    c.drawLine(Offset(s.width * 0.76, s.height * 0.38), Offset(s.width / 2, s.height * 0.55), p);
  }

  void _maps(Canvas c, Size s) {
    final pin = Path()
      ..moveTo(s.width / 2, s.height * 0.72)
      ..quadraticBezierTo(s.width * 0.28, s.height * 0.45, s.width / 2, s.height * 0.28)
      ..quadraticBezierTo(s.width * 0.72, s.height * 0.45, s.width / 2, s.height * 0.72);
    c.drawPath(pin, Paint()..color = const Color(0xFFFF3B30));
    c.drawCircle(Offset(s.width / 2, s.height * 0.42), s.width * 0.08, Paint()..color = Colors.white);
  }

  void _notes(Canvas c, Size s) {
    final p = Paint()..color = const Color(0xFF1C1C1E);
    for (var i = 0; i < 4; i++) {
      final y = s.height * 0.35 + i * 8.0;
      c.drawLine(Offset(s.width * 0.28, y), Offset(s.width * 0.72, y), p..strokeWidth = 1.6);
    }
  }

  void _folder(Canvas c, Size s) {
    final p = Paint()..color = Colors.white;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.2, s.height * 0.38, s.width * 0.6, s.height * 0.38),
        const Radius.circular(4),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.2, s.height * 0.32, s.width * 0.28, s.height * 0.12),
        const Radius.circular(3),
      ),
      p,
    );
  }

  void _calendar(Canvas c, Size s) {
    c.drawRect(Rect.fromLTWH(0, 0, s.width, s.height * 0.28), Paint()..color = const Color(0xFFFF3B30));
    final tp = TextPainter(
      text: TextSpan(
        text: '${DateTime.now().day}',
        style: TextStyle(
          color: const Color(0xFF1C1C1E),
          fontSize: s.width * 0.42,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset((s.width - tp.width) / 2, s.height * 0.38));
  }

  void _contacts(Canvas c, Size s) {
    c.drawCircle(Offset(s.width / 2, s.height * 0.38), s.width * 0.14, Paint()..color = Colors.white);
    c.drawOval(
      Rect.fromCenter(center: Offset(s.width / 2, s.height * 0.68), width: s.width * 0.42, height: s.height * 0.28),
      Paint()..color = Colors.white,
    );
  }

  void _gear(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.18, p);
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.08, Paint()..color = Colors.white);
    for (var i = 0; i < 8; i++) {
      c.save();
      c.translate(s.width / 2, s.height / 2);
      c.rotate(i * 0.785);
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, -16), width: 5, height: 10), const Radius.circular(1)),
        Paint()..color = Colors.white,
      );
      c.restore();
    }
  }

  void _instagram(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width / 2, s.height / 2), width: s.width * 0.55, height: s.height * 0.55),
        Radius.circular(s.width * 0.14),
      ),
      p,
    );
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.14, p);
    c.drawCircle(Offset(s.width * 0.68, s.height * 0.32), 2.5, Paint()..color = Colors.white);
  }

  void _bank(Canvas c, Size s) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'nu',
        style: TextStyle(color: Colors.white, fontSize: s.width * 0.32, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset((s.width - tp.width) / 2, (s.height - tp.height) / 2));
  }

  void _mic(Canvas c, Size s) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width / 2, s.height * 0.42), width: s.width * 0.22, height: s.height * 0.36),
        const Radius.circular(12),
      ),
      Paint()..color = Colors.white,
    );
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    c.drawArc(Rect.fromCenter(center: Offset(s.width / 2, s.height * 0.48), width: s.width * 0.4, height: s.height * 0.4), 0.15, 2.8, false, p);
    c.drawLine(Offset(s.width / 2, s.height * 0.68), Offset(s.width / 2, s.height * 0.78), p);
  }

  void _clock(Canvas c, Size s) {
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.32, Paint()..color = Colors.white);
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.28, Paint()..color = const Color(0xFF1C1C1E));
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(s.width / 2, s.height / 2), Offset(s.width / 2, s.height * 0.32), p);
    c.drawLine(Offset(s.width / 2, s.height / 2), Offset(s.width * 0.68, s.height * 0.55), p..color = const Color(0xFFFF3B30));
  }

  void _sun(Canvas c, Size s) {
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width * 0.16, Paint()..color = Colors.white);
    for (var i = 0; i < 8; i++) {
      c.save();
      c.translate(s.width / 2, s.height / 2);
      c.rotate(i * 0.785);
      c.drawLine(const Offset(0, -18), const Offset(0, -24), Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round);
      c.restore();
    }
  }

  void _question(Canvas c, Size s) {
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(color: Colors.white70, fontSize: s.width * 0.5, fontWeight: FontWeight.w300),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset((s.width - tp.width) / 2, (s.height - tp.height) / 2 - 2));
  }

  void _board(Canvas c, Size s) {
    final p = Paint()..color = Colors.white;
    c.drawCircle(Offset(s.width * 0.35, s.height * 0.35), 4, p);
    c.drawCircle(Offset(s.width * 0.65, s.height * 0.4), 4, p);
    c.drawCircle(Offset(s.width * 0.45, s.height * 0.65), 4, p);
    final line = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5;
    c.drawLine(Offset(s.width * 0.35, s.height * 0.35), Offset(s.width * 0.65, s.height * 0.4), line);
    c.drawLine(Offset(s.width * 0.35, s.height * 0.35), Offset(s.width * 0.45, s.height * 0.65), line);
  }

  void _trash(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.3, s.height * 0.38, s.width * 0.4, s.height * 0.38), const Radius.circular(3)),
      p,
    );
    c.drawLine(Offset(s.width * 0.28, s.height * 0.38), Offset(s.width * 0.72, s.height * 0.38), p);
    c.drawLine(Offset(s.width * 0.4, s.height * 0.3), Offset(s.width * 0.6, s.height * 0.3), p);
  }

  void _search(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    c.drawCircle(Offset(s.width * 0.42, s.height * 0.42), s.width * 0.16, p);
    c.drawLine(Offset(s.width * 0.54, s.height * 0.54), Offset(s.width * 0.7, s.height * 0.7), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
