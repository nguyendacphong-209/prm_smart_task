import 'package:flutter/material.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';

class AuthScreenContainer extends StatelessWidget {
  const AuthScreenContainer({
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.verified_user_rounded,
    this.headerAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final colors = AppBackground.colors(Theme.of(context).brightness);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -30,
            child: _LiquidOrb(
              size: 190,
              color: colorScheme.primary.withValues(
                alpha: brightness == Brightness.dark ? 0.22 : 0.16,
              ),
              durationMs: 4200,
            ),
          ),
          Positioned(
            top: 140,
            right: -40,
            child: _LiquidOrb(
              size: 170,
              color: colorScheme.secondary.withValues(
                alpha: brightness == Brightness.dark ? 0.18 : 0.14,
              ),
              durationMs: 3600,
            ),
          ),
          Positioned(
            bottom: -70,
            left: 40,
            child: _LiquidOrb(
              size: 210,
              color: colorScheme.tertiary.withValues(
                alpha: brightness == Brightness.dark ? 0.16 : 0.12,
              ),
              durationMs: 5000,
            ),
          ),
          SafeArea(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, childWidget) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: childWidget,
                  ),
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      style: GlassCardStyle.spotlight,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.20),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  colorScheme.primary.withValues(alpha: 0.16),
                              child: Icon(icon, color: colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (headerAction != null) ...[
                            const SizedBox(width: 8),
                            headerAction!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      style: GlassCardStyle.liquid,
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidOrb extends StatelessWidget {
  const _LiquidOrb({
    required this.size,
    required this.color,
    required this.durationMs,
  });

  final double size;
  final Color color;
  final int durationMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.04),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      onEnd: () {},
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
