import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/assets/game_images.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';
import 'dynamic_island.dart';
import 'lock_screen.dart';
import 'home_screen.dart';
import 'control_center.dart';
import 'app_switcher.dart';
import '../apps/app_router.dart';

/// Tela cheia — o celular É o jogo.
class PhoneShell extends StatefulWidget {
  const PhoneShell({super.key});

  @override
  State<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<PhoneShell> {
  bool _showControlCenter = false;
  bool _showAppSwitcher = false;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final unlocked = engine.progress.deviceUnlocked;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _LiveWallpaper(),
          if (!unlocked)
            const LockScreen()
          else if (_showAppSwitcher)
            AppSwitcher(
              onClose: () => setState(() => _showAppSwitcher = false),
              onOpen: (id) {
                setState(() => _showAppSwitcher = false);
                engine.openApp(id);
              },
            )
          else if (engine.foregroundApp != null)
            AppHost(
              appId: engine.foregroundApp!,
              onClose: engine.closeApp,
            )
          else
            HomeScreen(
              onOpenApp: engine.openApp,
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: IphoneStatusOverlay(
                battery: engine.progress.batteryPercent,
                showTime: unlocked,
              ),
            ),
          ),
          if (_showControlCenter)
            ControlCenter(
              onClose: () => setState(() => _showControlCenter = false),
            ),
          Positioned(
            top: 0,
            right: 0,
            width: 130,
            height: 52,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (d) {
                if (d.delta.dy > 6) {
                  setState(() => _showControlCenter = true);
                }
              },
            ),
          ),
          Positioned(
            bottom: 7,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (engine.foregroundApp != null) {
                    engine.closeApp();
                  } else if (_showAppSwitcher) {
                    setState(() => _showAppSwitcher = false);
                  } else if (_showControlCenter) {
                    setState(() => _showControlCenter = false);
                  }
                },
                onVerticalDragUpdate: (d) {
                  if (d.delta.dy < -8 && unlocked) {
                    setState(() => _showAppSwitcher = true);
                  }
                },
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveWallpaper extends StatefulWidget {
  const _LiveWallpaper();

  @override
  State<_LiveWallpaper> createState() => _LiveWallpaperState();
}

class _LiveWallpaperState extends State<_LiveWallpaper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final key =
        (engine.caseData?.osState['wallpaper'] as String?) ?? 'dusk_harbor';

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_c.value);
          final scale = 1.06 + (t * 0.07);
          final dy = (t - 0.5) * 18;
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A2A3C),
                      Color(0xFF0B1018),
                      Color(0xFF05070C),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(
                  scale: scale,
                  child: GameAssetImage(
                    assetPath: GameImages.wallpaper(key),
                    fallback: const SizedBox.shrink(),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.28),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AppHost extends StatelessWidget {
  final String appId;
  final VoidCallback onClose;
  const AppHost({super.key, required this.appId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OsisTheme.bgDeep,
      child: Column(
        children: [
          const SizedBox(height: 58),
          Expanded(child: buildApp(appId, onClose)),
        ],
      ),
    );
  }
}
