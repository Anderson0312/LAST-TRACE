import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';
import '../../main.dart';
import '../apps/app_catalog.dart';
import '../apps/apple_sf.dart';
import 'liquid_glass.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _showPin = false;
  String _pin = '';
  String? _error;

  void _digit(String d) {
    HapticFeedback.lightImpact();
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) _submit();
  }

  void _submit() {
    final engine = context.read<GameEngine>();
    final ok = engine.tryPin(_pin);
    if (ok) {
      HapticFeedback.mediumImpact();
      autosave(context);
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _error = 'Tente de novo';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(now);
    final date = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);

    return GestureDetector(
      onVerticalDragUpdate: (d) {
        if (d.delta.dy < -8) setState(() => _showPin = true);
      },
      onTap: () => setState(() => _showPin = true),
      child: Container(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 72, 22, 36),
              child: Column(
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 84,
                      fontWeight: FontWeight.w200,
                      height: 1.02,
                      letterSpacing: -2.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...engine.notifications.take(3).map(
                        (n) => _NotifCard(
                          app: n.appId,
                          title: n.title,
                          body: n.body,
                        ),
                      ),
                  const Spacer(),
                  if (!_showPin)
                    Text(
                      'Toque ou deslize para desbloquear',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                  if (!_showPin) ...[
                    const SizedBox(height: 22),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundIcon(icon: AppleSymbol.flashlight),
                        _RoundIcon(icon: AppleSymbol.camera),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            if (_showPin)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.42),
                  child: Column(
                    children: [
                      const SizedBox(height: 110),
                      const Text(
                        'Digite o código',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (engine.c.lockHint.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            engine.c.lockHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final filled = i < _pin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled ? Colors.white : Colors.transparent,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.75),
                                width: 1.4,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: OsisTheme.danger),
                        ),
                      ],
                      const Spacer(),
                      _PinPad(
                        onDigit: _digit,
                        onDelete: () {
                          if (_pin.isEmpty) return;
                          setState(
                            () => _pin = _pin.substring(0, _pin.length - 1),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _showPin = false;
                          _pin = '';
                        }),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final String app;
  final String title;
  final String body;
  const _NotifCard({
    required this.app,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LiquidGlass(
        radius: 20,
        blur: 24,
        opacity: 0.20,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppCatalog.displayName(app).toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              body,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  const _RoundIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      radius: 26,
      blur: 18,
      opacity: 0.16,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  const _PinPad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              if (k.isEmpty) return const SizedBox(width: 76, height: 76);
              return InkWell(
                customBorder: const CircleBorder(),
                onTap: () => k == '⌫' ? onDelete() : onDigit(k),
                child: Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: k == '⌫'
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    k,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
