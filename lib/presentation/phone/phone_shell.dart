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
import 'status_bar.dart';
import '../apps/app_router.dart';

/// Shell do smartphone VANTA / OSIS — o celular É o jogo.
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
    final size = MediaQuery.sizeOf(context);
    final phoneW = size.width.clamp(320.0, 430.0);
    final phoneH = size.height.clamp(640.0, 920.0);

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: Center(
        child: Container(
          width: phoneW,
          height: phoneH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: const Color(0xFF2A2D36), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _Wallpaper(),
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
                  onOpenSwitcher: () => setState(() => _showAppSwitcher = true),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const DynamicIsland(),
                    const SizedBox(height: 2),
                    OsisStatusBar(battery: engine.progress.batteryPercent),
                  ],
                ),
              ),
              if (_showControlCenter)
                ControlCenter(
                  onClose: () => setState(() => _showControlCenter = false),
                ),
              Positioned(
                top: 0,
                right: 0,
                width: 120,
                height: 40,
                child: GestureDetector(
                  onVerticalDragUpdate: (d) {
                    if (d.delta.dy > 6) {
                      setState(() => _showControlCenter = true);
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
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
                      width: 128,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
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
}

class _Wallpaper extends StatelessWidget {
  const _Wallpaper();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final key = (engine.caseData?.osState['wallpaper'] as String?) ?? 'dusk_harbor';
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B5876),
                Color(0xFF4E4376),
                Color(0xFF1A1A2E),
              ],
            ),
          ),
        ),
        GameAssetImage(
          assetPath: GameImages.wallpaper(key),
          fallback: const SizedBox.shrink(),
        ),
        Container(color: Colors.black.withValues(alpha: 0.18)),
      ],
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
          const SizedBox(height: 54),
          Expanded(child: buildApp(appId, onClose)),
        ],
      ),
    );
  }
}
