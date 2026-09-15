import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/osis_theme.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class AtlasApp extends StatelessWidget {
  final VoidCallback onClose;
  const AtlasApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final fmt = DateFormat('dd/MM HH:mm');
    final locs = engine.c.locations;

    return AppScaffold(
      title: 'Mapas',
      onClose: onClose,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B3A4B), Color(0xFF0E1A24)],
                ),
              ),
              child: CustomPaint(
                painter: _MapPainter(locs.length),
                child: Stack(
                  children: [
                    for (var i = 0; i < locs.length; i++)
                      Positioned(
                        left: 24.0 + (i * 37) % 220,
                        top: 30.0 + (i * 53) % 160,
                        child: GestureDetector(
                          onTap: () {
                            engine.revealFromContent(locs[i].revealsClueIds);
                            autosave(context);
                          },
                          child: Column(
                            children: [
                              Icon(Icons.location_on,
                                  color: locs[i].kind == 'history'
                                      ? OsisTheme.danger
                                      : OsisTheme.accent),
                              Text(locs[i].name.split('—').first.trim(),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Histórico e pesquisas',
                      style: TextStyle(color: Colors.white54)),
                ),
                ...locs.map((l) => ListTile(
                      leading: Icon(
                        l.kind == 'searched'
                            ? Icons.search
                            : l.kind == 'favorite'
                                ? Icons.star
                                : Icons.history,
                      ),
                      title: Text(l.name),
                      subtitle: Text([
                        l.kind,
                        if (l.visitedAt != null) fmt.format(l.visitedAt!),
                        if (l.note != null) l.note!,
                      ].join(' · ')),
                      onTap: () {
                        engine.revealFromContent(l.revealsClueIds);
                        if (l.id == 'loc4') engine.discoverClue('CLUE_PARKING');
                        if (l.id == 'loc3') engine.discoverClue('CLUE_LOC_RESTAURANT');
                        autosave(context);
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final int n;
  _MapPainter(this.n);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x3342A5F5)
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      canvas.drawLine(Offset(0, i * size.height / 8),
          Offset(size.width, i * size.height / 8), p);
      canvas.drawLine(Offset(i * size.width / 8, 0),
          Offset(i * size.width / 8, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
