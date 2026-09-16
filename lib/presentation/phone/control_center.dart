import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';
import '../apps/app_catalog.dart';
import '../apps/apple_sf.dart';
import '../apps/ios_icons.dart';
import 'liquid_glass.dart';

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
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          color: Colors.black.withValues(alpha: 0.28),
          padding: const EdgeInsets.fromLTRB(18, 72, 18, 36),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LiquidGlass(
                      radius: 28,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MiniTile(
                                  icon: AppleSymbol.wifi,
                                  label: 'Wi‑Fi',
                                  active: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniTile(
                                  icon: AppleSymbol.bluetooth,
                                  label: 'Bluetooth',
                                  active: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniTile(
                                  icon: AppleSymbol.airplane,
                                  label: 'Avião',
                                  active: false,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniTile(
                                  icon: AppleSymbol.airdrop,
                                  label: 'AirDrop',
                                  active: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 108,
                    child: Column(
                      children: [
                        LiquidGlass(
                          radius: 22,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              Icon(
                                AppleSymbol.brightness,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 6,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      icon: AppleSymbol.record,
                      label: 'Gravação $mm:$ss',
                      active: true,
                      danger: true,
                      onTap: () {
                        engine.discoverClue('CLUE_FILE_DAT');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _Tile(
                      icon: AppleSymbol.flashlight,
                      label: 'Lanterna',
                      active: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LiquidGlass(
                radius: 22,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Slider(
                      value: 0.4,
                      onChanged: (_) {},
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Gravação de tela interrompida em 00:03:41 — pode ser pista.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _MiniTile({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF0A84FF)
                : Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
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
      child: LiquidGlass(
        radius: 22,
        opacity: 0.16,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: danger
                    ? OsisTheme.danger
                    : active
                        ? OsisTheme.accent
                        : Colors.white54,
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: Colors.black.withValues(alpha: 0.42),
          padding: const EdgeInsets.fromLTRB(16, 92, 16, 48),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final id = apps[i];
              final name = AppCatalog.displayName(id);
              return GestureDetector(
                onTap: () => onOpen(id),
                child: SizedBox(
                  width: 210,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: OsisTheme.bgElevated,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                id == 'browser'
                                    ? 'Aberto em:\nComo apagar histórico de localização'
                                    : 'App em segundo plano',
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.3,
                                ),
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
                      ),
                      const SizedBox(height: 10),
                      IosAppIcon(
                        style: _iconFor(id),
                        size: 36,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IosIconStyle _iconFor(String id) {
    for (final a in [...AppCatalog.homeApps, ...AppCatalog.dockApps]) {
      if (a.id == id) return a.iconStyle;
    }
    return IosIconStyle.search;
  }
}
