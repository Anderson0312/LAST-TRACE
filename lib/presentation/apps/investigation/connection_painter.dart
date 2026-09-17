import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/models/models.dart';
import 'board_theme.dart';

/// Fio vermelho físico entre dois alfinetes (curva + sombra + etiqueta).
class ConnectionPainter extends CustomPainter {
  final List<WireSeg> wires;
  final Offset? draftFrom;
  final Offset? draftTo;

  ConnectionPainter({
    required this.wires,
    this.draftFrom,
    this.draftTo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final w in wires) {
      _paintWire(canvas, w.a, w.b, w.relation, w.label, animate: w.fresh);
    }
    if (draftFrom != null && draftTo != null) {
      _paintWire(
        canvas,
        draftFrom!,
        draftTo!,
        BoardRelationType.related,
        null,
        draft: true,
      );
    }
  }

  void _paintWire(
    Canvas canvas,
    Offset a,
    Offset b,
    BoardRelationType relation,
    String? label, {
    bool draft = false,
    bool animate = false,
  }) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 4) return;
    final nx = -dy / len;
    final ny = dx / len;
    final sag = (len * 0.08).clamp(8.0, 36.0) * (animate ? 1.05 : 1.0);
    final c1 = Offset(a.dx + dx * 0.3 + nx * sag, a.dy + dy * 0.3 + ny * sag);
    final c2 = Offset(a.dx + dx * 0.7 + nx * sag, a.dy + dy * 0.7 + ny * sag);

    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: draft ? 0.15 : 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = draft ? 2.2 : 3.4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path.shift(const Offset(1.5, 2)), shadow);

    final color = switch (relation) {
      BoardRelationType.contradicts => const Color(0xFFFF6B4A),
      BoardRelationType.confirms => const Color(0xFFE53935),
      BoardRelationType.alibi => const Color(0xFF90CAF9),
      BoardRelationType.motive => const Color(0xFFFFB74D),
      _ => BoardTheme.thread,
    };

    final paint = Paint()
      ..color = draft ? color.withValues(alpha: 0.55) : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = draft ? 1.8 : 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);

    // Highlight fino
    final hi = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path.shift(const Offset(-0.4, -0.4)), hi);

    if (label != null && label.isNotEmpty && !draft) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFFF5F0E8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: mid.translate(0, -10),
          width: tp.width + 14,
          height: tp.height + 8,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = BoardTheme.corkGrain.withValues(alpha: 0.85),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      tp.paint(
        canvas,
        Offset(mid.dx - tp.width / 2, mid.dy - 10 - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) => true;
}

class WireSeg {
  final Offset a;
  final Offset b;
  final BoardRelationType relation;
  final String? label;
  final bool fresh;

  WireSeg({
    required this.a,
    required this.b,
    required this.relation,
    this.label,
    this.fresh = false,
  });
}

/// Helper para montar o painter a partir de conexões + centros de pinos.
class BoardWireLayer extends StatelessWidget {
  final List<BoardConnection> connections;
  final Map<String, Offset> pinCenters;
  final Offset? draftFrom;
  final Offset? draftTo;
  final String? freshConnectionId;

  const BoardWireLayer({
    super.key,
    required this.connections,
    required this.pinCenters,
    this.draftFrom,
    this.draftTo,
    this.freshConnectionId,
  });

  @override
  Widget build(BuildContext context) {
    final wires = <WireSeg>[];
    for (final c in connections) {
      final a = pinCenters[c.fromId];
      final b = pinCenters[c.toId];
      if (a == null || b == null) continue;
      wires.add(WireSeg(
        a: a,
        b: b,
        relation: c.relation,
        label: c.label,
        fresh: c.id == freshConnectionId,
      ));
    }
    return CustomPaint(
      painter: ConnectionPainter(
        wires: wires,
        draftFrom: draftFrom,
        draftTo: draftTo,
      ),
      size: Size.infinite,
    );
  }
}
