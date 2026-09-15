import 'dart:ui';
import 'package:flutter/material.dart';

/// Superfície estilo iOS 26 Liquid Glass.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final Color? tint;

  const LiquidGlass({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding,
    this.blur = 28,
    this.opacity = 0.18,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final base = tint ?? Colors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withValues(alpha: opacity + 0.10),
                base.withValues(alpha: opacity * 0.45),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 0.6,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
