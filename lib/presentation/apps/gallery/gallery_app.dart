import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/assets/game_images.dart';
import '../../../core/theme/osis_theme.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class GalleryApp extends StatefulWidget {
  final VoidCallback onClose;
  const GalleryApp({super.key, required this.onClose});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  PhotoItem? _open;
  bool _showDeleted = false;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    if (_open != null) {
      return _PhotoDetail(
        photo: _open!,
        onBack: () => setState(() => _open = null),
      );
    }

    final photos = engine.c.photos
        .where((p) => _showDeleted ? p.deleted : !p.deleted)
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));

    return AppScaffold(
      title: _showDeleted ? 'Apagadas' : 'Fotos',
      onClose: widget.onClose,
      actions: [
        IconButton(
          tooltip: 'Lixeira',
          onPressed: () => setState(() => _showDeleted = !_showDeleted),
          icon: Icon(_showDeleted ? Icons.photo_outlined : Icons.delete_outline),
        ),
      ],
      body: photos.isEmpty
          ? const Center(
              child: Text('Nenhuma foto',
                  style: TextStyle(color: Colors.white54)))
          : GridView.builder(
              padding: const EdgeInsets.all(6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: photos.length,
              itemBuilder: (_, i) {
                final p = photos[i];
                return GestureDetector(
                  onTap: () {
                    engine.viewPhoto(p.id, p.revealsClueIds);
                    autosave(context);
                    setState(() => _open = p);
                  },
                  child: _Thumb(photo: p),
                );
              },
            ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final PhotoItem photo;
  const _Thumb({required this.photo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _PhotoArtPainter(photo)),
          GameAssetImage(
            assetPath: GameImages.photo(photo.id),
            fallback: const SizedBox.shrink(),
          ),
          if (photo.corrupted)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          if (photo.isVideo)
            const Positioned(
              right: 4,
              top: 4,
              child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 18),
            ),
          if (photo.isScreenshot)
            const Positioned(
              left: 4,
              top: 4,
              child: Icon(Icons.phone_iphone, color: Colors.white54, size: 14),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Text(
                photo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arte procedural para simular fotos narrativas (sem assets externos).
class _PhotoArtPainter extends CustomPainter {
  final PhotoItem photo;
  _PhotoArtPainter(this.photo);

  @override
  void paint(Canvas canvas, Size size) {
    final seed = int.tryParse(photo.colorSeed, radix: 16) ?? photo.id.hashCode;
    final rng = Random(seed);
    final base = _palette(seed);

    // background wash
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: base,
        ).createShader(Offset.zero & size),
    );

    // soft shapes = subjects / environment
    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = Color.fromARGB(
          40 + rng.nextInt(70),
          20 + rng.nextInt(200),
          20 + rng.nextInt(200),
          30 + rng.nextInt(200),
        );
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = size.shortestSide * (0.12 + rng.nextDouble() * 0.35);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // night photos: darker vignette
    final night = photo.takenAt.hour >= 20 || photo.takenAt.hour < 5;
    if (night) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.55),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    // document / screenshot look
    if (photo.isScreenshot || photo.title.toLowerCase().contains('documento')) {
      final paper = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.12, size.height * 0.15, size.width * 0.76,
              size.height * 0.7),
          const Radius.circular(4),
        ),
        paper,
      );
      final line = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      for (var i = 0; i < 6; i++) {
        final y = size.height * 0.28 + i * 10;
        canvas.drawLine(
          Offset(size.width * 0.2, y),
          Offset(size.width * 0.8, y),
          line,
        );
      }
    }
  }

  List<Color> _palette(int seed) {
    final palettes = [
      [const Color(0xFF1A2233), const Color(0xFF3D4F6F)],
      [const Color(0xFF2A1F3D), const Color(0xFF6B4E71)],
      [const Color(0xFF1F3328), const Color(0xFF3E5C48)],
      [const Color(0xFF3B2A1A), const Color(0xFF8B6914)],
      [const Color(0xFF0E1A24), const Color(0xFF1B3A4B)],
      [const Color(0xFF2C1810), const Color(0xFF5C3317)],
      [const Color(0xFF1C2331), const Color(0xFF445566)],
      [const Color(0xFF241428), const Color(0xFF4A2C4A)],
    ];
    return palettes[seed.abs() % palettes.length];
  }

  @override
  bool shouldRepaint(covariant _PhotoArtPainter oldDelegate) =>
      oldDelegate.photo.id != photo.id;
}

class _PhotoDetail extends StatelessWidget {
  final PhotoItem photo;
  final VoidCallback onBack;
  const _PhotoDetail({required this.photo, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return AppScaffold(
      title: photo.title,
      onClose: onBack,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _PhotoArtPainter(photo)),
                  GameAssetImage(
                    assetPath: GameImages.photo(photo.id),
                    fallback: const SizedBox.shrink(),
                  ),
                  // hotspots
                  ...photo.hotspots.map((hs) {
                    return Positioned(
                      left: hs.x * MediaQuery.sizeOf(context).width * 0.72,
                      top: hs.y * 280,
                      child: GestureDetector(
                        onTap: () {
                          engine.unlockHotspot(hs);
                          autosave(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pista: ${hs.label}'),
                              backgroundColor: OsisTheme.bgElevated,
                            ),
                          );
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: OsisTheme.accent.withValues(alpha: 0.85),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: OsisTheme.accent.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.search,
                              color: Colors.white70, size: 18),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      photo.visualDescription,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.3,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(photo.caption,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          _meta('Tirada em', fmt.format(photo.takenAt)),
          if (photo.metadataTakenAt != null)
            _meta('Metadado EXIF', fmt.format(photo.metadataTakenAt!),
                highlight: photo.metadataTakenAt != photo.takenAt),
          if (photo.locationName != null) _meta('Local', photo.locationName!),
          if (photo.deviceName != null) _meta('Dispositivo', photo.deviceName!),
          if (photo.metadataTakenAt != null &&
              photo.metadataTakenAt != photo.takenAt)
            TextButton(
              onPressed: () {
                engine.discoverClue('CLUE_META_MISMATCH');
                autosave(context);
              },
              child: const Text('Analisar inconsistência de metadados'),
            ),
        ],
      ),
    );
  }

  Widget _meta(String k, String v, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(v,
                style: TextStyle(
                  color: highlight ? OsisTheme.danger : Colors.white,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
        ],
      ),
    );
  }
}
