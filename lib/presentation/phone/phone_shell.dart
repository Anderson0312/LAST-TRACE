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

/// Chassis de iPhone 17 — o celular É o jogo.
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
    final framed = size.width > 520;
    const aspect = 402 / 874;
    var phoneW = framed ? 402.0 : size.width.clamp(320.0, 430.0);
    var phoneH = framed ? 874.0 : size.height.clamp(640.0, 940.0);
    if (framed) {
      final maxH = size.height - 28;
      final maxW = size.width - 36;
      if (phoneH > maxH) {
        phoneH = maxH;
        phoneW = phoneH * aspect;
      }
      if (phoneW > maxW) {
        phoneW = maxW;
        phoneH = phoneW / aspect;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: Center(
        child: SizedBox(
          width: phoneW + (framed ? 18 : 0),
          height: phoneH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (framed) ...[
                _SideButton(
                  left: true,
                  top: phoneH * 0.18,
                  height: 28,
                ),
                _SideButton(
                  left: true,
                  top: phoneH * 0.18 + 36,
                  height: 52,
                ),
                _SideButton(
                  left: true,
                  top: phoneH * 0.18 + 96,
                  height: 52,
                ),
                _SideButton(
                  left: false,
                  top: phoneH * 0.22,
                  height: 64,
                ),
                _SideButton(
                  left: false,
                  top: phoneH * 0.22 + 78,
                  height: 36,
                  cameraControl: true,
                ),
              ],
              Padding(
                padding: EdgeInsets.symmetric(horizontal: framed ? 9 : 0),
                child: _TitaniumBody(
                  width: phoneW,
                  height: phoneH,
                  framed: framed,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const _LiveWallpaper(),
                      if (!unlocked)
                        const LockScreen()
                      else if (_showAppSwitcher)
                        AppSwitcher(
                          onClose: () =>
                              setState(() => _showAppSwitcher = false),
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
                          onClose: () =>
                              setState(() => _showControlCenter = false),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitaniumBody extends StatelessWidget {
  final double width;
  final double height;
  final bool framed;
  final Widget child;

  const _TitaniumBody({
    required this.width,
    required this.height,
    required this.framed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final outerR = framed ? 56.0 : 48.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerR),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB8BCC4),
            Color(0xFF5C5F66),
            Color(0xFF2A2C31),
            Color(0xFF8A8E96),
          ],
          stops: [0.0, 0.32, 0.68, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: framed ? 0.65 : 0.4),
            blurRadius: framed ? 64 : 28,
            spreadRadius: framed ? 2 : 0,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: EdgeInsets.all(framed ? 3.6 : 2.8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(outerR - 4),
        ),
        padding: const EdgeInsets.all(1.15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerR - 6.2),
          child: child,
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final bool left;
  final double top;
  final double height;
  final bool cameraControl;

  const _SideButton({
    required this.left,
    required this.top,
    required this.height,
    this.cameraControl = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: cameraControl ? 5.5 : 4.2,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: cameraControl
                ? const [Color(0xFF9A9DA6), Color(0xFF4A4D54)]
                : const [Color(0xFFC5C8D0), Color(0xFF6A6D74), Color(0xFF3D4046)],
          ),
        ),
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
