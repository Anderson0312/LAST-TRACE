import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';

/// Dynamic Island + status bar na mesma linha, como no iPhone 17 / iOS 26.
class IphoneStatusOverlay extends StatelessWidget {
  final int battery;
  final bool showTime;

  const IphoneStatusOverlay({
    super.key,
    required this.battery,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 20, 0),
      child: SizedBox(
        height: 38,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 52,
                  child: showTime
                      ? Text(
                          '$hh:$mm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            height: 1,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const Spacer(),
                _SignalCluster(battery: battery),
              ],
            ),
            const DynamicIsland(),
          ],
        ),
      ),
    );
  }
}

class DynamicIsland extends StatelessWidget {
  const DynamicIsland({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final expanded = engine.islandState != IslandState.idle;
    final label = engine.islandLabel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      width: expanded ? 228 : 124,
      height: expanded ? 36 : 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: expanded
          ? Row(
              children: [
                _lenses(),
                const SizedBox(width: 8),
                _dot(engine.islandState),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _lenses(),
              ),
            ),
    );
  }

  Widget _lenses() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1C22),
            border: Border.all(color: const Color(0xFF2E3340), width: 0.8),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF12141A),
          ),
        ),
      ],
    );
  }

  Widget _dot(IslandState s) {
    Color c = OsisTheme.accent;
    if (s == IslandState.call) c = OsisTheme.success;
    if (s == IslandState.unknownActivity) c = OsisTheme.danger;
    if (s == IslandState.timer) c = const Color(0xFFFFB020);
    if (s == IslandState.lowBattery) c = OsisTheme.danger;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

class _SignalCluster extends StatelessWidget {
  final int battery;
  const _SignalCluster({required this.battery});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.signal_cellular_alt, size: 15, color: Colors.white),
        const SizedBox(width: 5),
        const Icon(Icons.wifi, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        _Battery(percent: battery),
      ],
    );
  }
}

class _Battery extends StatelessWidget {
  final int percent;
  const _Battery({required this.percent});

  @override
  Widget build(BuildContext context) {
    final low = percent <= 20;
    final color = low ? OsisTheme.danger : Colors.white;
    return Row(
      children: [
        Container(
          width: 27,
          height: 13,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(1.4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (percent / 100).clamp(0.08, 1),
                heightFactor: 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 1.5),
        Container(
          width: 1.6,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

/// Mantido para exports antigos.
class OsisStatusBar extends StatelessWidget {
  final int battery;
  const OsisStatusBar({super.key, required this.battery});

  @override
  Widget build(BuildContext context) {
    return IphoneStatusOverlay(battery: battery);
  }
}
