import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';

class DynamicIsland extends StatelessWidget {
  const DynamicIsland({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final expanded = engine.islandState != IslandState.idle;
    final label = engine.islandLabel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      width: expanded ? 220 : 126,
      height: expanded ? 36 : 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: expanded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(engine.islandState),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _dot(IslandState s) {
    Color c = OsisTheme.accent;
    if (s == IslandState.call) c = OsisTheme.success;
    if (s == IslandState.unknownActivity) c = OsisTheme.danger;
    if (s == IslandState.timer) c = const Color(0xFFFFB020);
    if (s == IslandState.lowBattery) c = OsisTheme.danger;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

class OsisStatusBar extends StatelessWidget {
  final int battery;
  const OsisStatusBar({super.key, required this.battery});

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
      child: Row(
        children: [
          Text(
            '$hh:$mm',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          const Icon(Icons.wifi, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text('$battery', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
