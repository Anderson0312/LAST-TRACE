import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/assets/game_images.dart';
import '../../core/theme/osis_theme.dart';
import '../../data/repositories/case_repository.dart';
import '../../domain/engines/game_engine.dart';
import '../intro/intro_screen.dart';
import '../phone/liquid_glass.dart';
import 'coop_lobby_screen.dart';

/// Escolha: solo ou cooperativo.
class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameAssetImage(
            assetPath: GameImages.wallpaper('mode_select'),
            fallback: const ColoredBox(color: Color(0xFF07090D)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC05070C),
                  Color(0x6605070C),
                  Color(0xE605070C),
                ],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÚLTIMO ACESSO',
                    style: TextStyle(
                      color: OsisTheme.accent,
                      fontSize: 13,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Como você\ninvestiga?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Solo: um celular. Cooperativo: duas perspectivas — e a verdade só aparece quando vocês conectam as pistas.',
                    style: TextStyle(color: Colors.white70, height: 1.45),
                  ),
                  const Spacer(),
                  _ModeCard(
                    title: 'Investigação solo',
                    subtitle: 'Você explora o celular de Marina.',
                    icon: Icons.phone_iphone,
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final repo = context.read<CaseRepository>();
                      final save = context.read<SaveService>();
                      final engine = context.read<GameEngine>();
                      final data = await repo.loadCase('case_001');
                      final saved = await save.load('case_001');
                      engine.loadCase(data, saved: saved);
                      engine.startLiveLoop();
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const IntroScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ModeCard(
                    title: 'Modo cooperativo',
                    subtitle: 'Dois celulares. Duas perspectivas. Uma verdade.',
                    icon: Icons.people_alt_outlined,
                    highlight: true,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CoopLobbyScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        radius: 20,
        blur: 22,
        opacity: highlight ? 0.20 : 0.12,
        tint: highlight ? OsisTheme.accent : Colors.white,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: highlight ? OsisTheme.accent : Colors.white70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
