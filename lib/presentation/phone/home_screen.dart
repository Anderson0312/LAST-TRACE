import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/assets/game_images.dart';
import '../../domain/engines/game_engine.dart';
import '../apps/app_catalog.dart';
import '../apps/apple_sf.dart';
import '../apps/ios_icons.dart';
import 'liquid_glass.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String appId) onOpenApp;

  const HomeScreen({
    super.key,
    required this.onOpenApp,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final unreadWhatsApp = engine.unreadWhatsAppCount;
    final pages = [AppCatalog.homePage1, AppCatalog.homePage2];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 28),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, page) {
                return _HomePage(
                  apps: pages[page],
                  showWidgets: page == 0,
                  unreadWhatsApp: unreadWhatsApp,
                  battery: engine.progress.batteryPercent,
                  warning: engine.progress.remoteAccessDetected,
                  onOpenApp: widget.onOpenApp,
                  onCalendar: () {
                    engine.discoverClue('CLUE_CAL_EVENT');
                    widget.onOpenApp('calendar');
                  },
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () => widget.onOpenApp('search'),
            child: LiquidGlass(
              radius: 22,
              blur: 22,
              opacity: 0.14,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppleSymbol.search,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Buscar',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: active ? 8 : 7,
                height: active ? 8 : 7,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: active ? 1 : 0.32),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          LiquidGlass(
            radius: 34,
            blur: 32,
            opacity: 0.22,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppCatalog.dockApps
                  .map(
                    (a) => _AppIconButton(
                      app: a,
                      compact: true,
                      badge: a.id == 'pulse' ? unreadWhatsApp : 0,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onOpenApp(a.id);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  final List<PhoneApp> apps;
  final bool showWidgets;
  final int unreadWhatsApp;
  final int battery;
  final bool warning;
  final void Function(String appId) onOpenApp;
  final VoidCallback onCalendar;

  const _HomePage({
    required this.apps,
    required this.showWidgets,
    required this.unreadWhatsApp,
    required this.battery,
    required this.warning,
    required this.onOpenApp,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showWidgets) ...[
          SizedBox(
            height: 148,
            child: Row(
              children: [
                Expanded(child: _IosCalendarWidget(onTap: onCalendar)),
                const SizedBox(width: 12),
                Expanded(
                  child: _IosPhotosWidget(onTap: () => onOpenApp('gallery')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 78,
            child: Row(
              children: [
                Expanded(
                  child: _IosWeatherWidget(onTap: () => onOpenApp('atlas')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IosBatteryWidget(
                    percent: battery,
                    warning: warning,
                    onTap: () => onOpenApp('settings'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ] else
          const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.74,
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
      ],
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
    final size = compact ? 58.0 : 62.0;
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
                  right: -3,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
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
                letterSpacing: -0.2,
                shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
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
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: const TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    height: 1.02,
                    letterSpacing: -1,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '23:30  NÃO ESQUECER',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontSize: 10.5,
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
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GameAssetImage(
                    assetPath: GameImages.photo('ph1'),
                    fallback: const ColoredBox(color: Color(0xFF1A2233)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: GameAssetImage(
                          assetPath: GameImages.photo('ph3'),
                          fallback: const ColoredBox(color: Color(0xFF2A1F3D)),
                        ),
                      ),
                      Expanded(
                        child: GameAssetImage(
                          assetPath: GameImages.photo('ph5'),
                          fallback: const ColoredBox(color: Color(0xFF1F3328)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DecoratedBox(
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
                'Recentes · 13/08',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosWeatherWidget extends StatelessWidget {
  final VoidCallback onTap;
  const _IosWeatherWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        radius: 22,
        blur: 18,
        opacity: 0.16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(AppleSymbol.weather, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '18°',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Santos · nublado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
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
      child: LiquidGlass(
        radius: 22,
        blur: 16,
        opacity: warning ? 0.22 : 0.16,
        tint: warning ? const Color(0xFFFF3B30) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              AppleSymbol.battery,
              color: warning ? const Color(0xFFFF8A80) : Colors.white,
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
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    warning ? 'Atividade anormal' : 'Última carga 23:47',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}
