import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';

class ControlCenter extends StatelessWidget {
  final VoidCallback onClose;
  const ControlCenter({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final rec = engine.c.osState['screenRecordingSeconds'] as int? ?? 0;
    final mm = (rec ~/ 60).toString().padLeft(2, '0');
    final ss = (rec % 60).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onClose,
      onVerticalDragUpdate: (d) {
        if (d.delta.dy < -6) onClose();
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: Colors.black45,
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _Tile(icon: Icons.wifi, label: 'Wi‑Fi', active: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _Tile(icon: Icons.bluetooth, label: 'Bluetooth', active: true)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Tile(icon: Icons.airplanemode_active, label: 'Avião', active: false)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Tile(
                      icon: Icons.fiber_manual_record,
                      label: 'Gravação $mm:$ss',
                      active: true,
                      danger: true,
                      onTap: () {
                        engine.discoverClue('CLUE_FILE_DAT');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Brilho', style: TextStyle(color: Colors.white70)),
                    Slider(value: 0.55, onChanged: (_) {}),
                    const Text('Volume', style: TextStyle(color: Colors.white70)),
                    Slider(value: 0.4, onChanged: (_) {}),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Gravação de tela interrompida em 00:03:41 — pode ser pista.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool danger;
  final VoidCallback? onTap;
  const _Tile({
    required this.icon,
    required this.label,
    required this.active,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: danger
                    ? OsisTheme.danger
                    : active
                        ? OsisTheme.accent
                        : Colors.white54),
            const Spacer(),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class AppSwitcher extends StatelessWidget {
  final VoidCallback onClose;
  final void Function(String id) onOpen;
  const AppSwitcher({super.key, required this.onClose, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final apps = engine.recentApps.isEmpty
        ? ['pulse', 'atlas', 'gallery', 'browser']
        : engine.recentApps;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: apps.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final id = apps[i];
            return GestureDetector(
              onTap: () => onOpen(id),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: OsisTheme.bgElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(id.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text(
                      id == 'browser'
                          ? 'Aberto em:\nComo apagar histórico de localização'
                          : 'App em segundo plano',
                      style: const TextStyle(color: Colors.white, height: 1.3),
                    ),
                    if (id == 'browser') ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          engine.discoverClue('CLUE_BROWSER_LOC');
                          onOpen('browser');
                        },
                        child: const Text('Abrir página'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
