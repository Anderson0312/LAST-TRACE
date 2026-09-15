import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/engines/game_engine.dart';
import '../apps/app_catalog.dart';
import '../apps/ios_icons.dart';

class HomeScreen extends StatelessWidget {
  final void Function(String appId) onOpenApp;
  final VoidCallback onOpenSwitcher;

  const HomeScreen({
    super.key,
    required this.onOpenApp,
    required this.onOpenSwitcher,
  });

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    // Home page 1: first 16 apps (4x4), dock separate
    final apps = AppCatalog.homeApps.take(16).toList();
    final dock = AppCatalog.dockApps;
    final now = DateTime.now();
    final unreadWhatsApp = engine.unreadWhatsAppCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 78, 18, 18),
      child: Column(
        children: [
          // Widgets estilo iOS — linha 1
          SizedBox(
            height: 152,
            child: Row(
              children: [
                Expanded(
                  child: _IosCalendarWidget(
                    onTap: () {
                      engine.discoverClue('CLUE_CAL_EVENT');
                      onOpenApp('calendar');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _IosPhotosWidget(
                    onTap: () => onOpenApp('gallery'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: Row(
              children: [
                Expanded(
                  child: _IosBatteryWidget(
                    percent: engine.progress.batteryPercent,
                    warning: engine.progress.remoteAccessDetected,
                    onTap: () => onOpenApp('settings'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _IosNotesWidget(
                    onTap: () => onOpenApp('notes'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 6,
                childAspectRatio: 0.72,
              ),
              itemCount: apps.length,
              itemBuilder: (_, i) {
                final app = apps[i];
                return _AppIconButton(
                  app: app,
                  badge: app.id == 'pulse' ? unreadWhatsApp : 0,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenApp(app.id);
                  },
                );
              },
            ),
          ),
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Dock iOS
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dock
                      .map((a) => _AppIconButton(
                            app: a,
                            compact: true,
                            badge: a.id == 'pulse' ? unreadWhatsApp : 0,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onOpenApp(a.id);
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Text(
            DateFormat('HH:mm').format(now),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0),
              fontSize: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppIconButton extends StatelessWidget {
  final PhoneApp app;
  final VoidCallback onTap;
  final bool compact;
  final int badge;

  const _AppIconButton({
    required this.app,
    required this.onTap,
    this.compact = false,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 56.0 : 60.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IosAppIcon(style: app.iconStyle, size: size),
              if (badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black26, width: 0.5),
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 5),
            Text(
              app.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IosCalendarWidget extends StatelessWidget {
  final VoidCallback onTap;
  const _IosCalendarWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE', 'pt_BR').format(now).toUpperCase();
    final day = '${now.day}';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: const TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    height: 1.05,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '23:30  NÃO ESQUECER',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IosPhotosWidget extends StatelessWidget {
  final VoidCallback onTap;
  const _IosPhotosWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A2233), Color(0xFF3D4F6F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFF2A1F3D),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFF1F3328),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                '3 fotos · 13/08',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosBatteryWidget extends StatelessWidget {
  final int percent;
  final bool warning;
  final VoidCallback onTap;
  const _IosBatteryWidget({
    required this.percent,
    required this.warning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.battery_std,
                  color: warning ? const Color(0xFFFF3B30) : Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        warning ? 'Atividade anormal' : 'Última carga 23:47',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IosNotesWidget extends StatelessWidget {
  final VoidCallback onTap;
  const _IosNotesWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6B0),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notas',
                style: TextStyle(
                  color: Color(0xFF8E8E00),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Se alguma coisa acontecer comigo…',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
