import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';

enum GlassCardStyle { standard, liquid, spotlight }

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppGlass.radiusLarge,
    this.style = GlassCardStyle.standard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final GlassCardStyle style;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final (sigma, overlayColor, borderColor) = switch ((style, brightness)) {
      (GlassCardStyle.liquid, Brightness.light) => (
        AppGlass.blurMedium,
        Colors.white.withValues(alpha: 0.60),
        Colors.white.withValues(alpha: 0.40),
      ),
      (GlassCardStyle.liquid, Brightness.dark) => (
        AppGlass.blurMedium,
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.15),
      ),
      (GlassCardStyle.spotlight, Brightness.light) => (
        AppGlass.blurMedium,
        Colors.white.withValues(alpha: 0.55),
        Colors.white.withValues(alpha: 0.35),
      ),
      (GlassCardStyle.spotlight, Brightness.dark) => (
        AppGlass.blurMedium,
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.18),
      ),
      (_, Brightness.light) => (
        AppGlass.blurMedium,
        Colors.white.withValues(alpha: 0.55),
        Colors.white.withValues(alpha: 0.35),
      ),
      (_, Brightness.dark) => (
        AppGlass.blurMedium,
        Colors.white.withValues(alpha: 0.06),
        Colors.white.withValues(alpha: 0.12),
      ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: brightness == Brightness.dark ? 0.25 : 0.08,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
