import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Provides ambient colored light orbs behind content so that
/// BackdropFilter (glassmorphism) has something to blur against.
/// Without this, glass cards on a flat black background look opaque.
class GlassBackground extends StatelessWidget {
  final Widget child;

  /// Preset orb layouts for different screen types.
  final GlassBackgroundStyle style;

  const GlassBackground({
    super.key,
    required this.child,
    this.style = GlassBackgroundStyle.standard,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0E0A), // warm tint at top
                  AppColors.background,
                  Color(0xFF0A0A0C), // cool tint at bottom
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Ambient light orbs
        ..._buildOrbs(context),
        // Actual content
        Positioned.fill(child: child),
      ],
    );
  }

  List<Widget> _buildOrbs(BuildContext context) {
    final size = MediaQuery.of(context).size;
    switch (style) {
      case GlassBackgroundStyle.auth:
        return [
          // Large gold orb — top center
          _Orb(
            top: -size.height * 0.08,
            left: size.width * 0.1,
            width: size.width * 0.8,
            height: size.height * 0.35,
            color: AppColors.primary,
            opacity: 0.07,
          ),
          // Subtle blue-ish accent — bottom left
          _Orb(
            bottom: size.height * 0.05,
            left: -size.width * 0.2,
            width: size.width * 0.6,
            height: size.height * 0.25,
            color: const Color(0xFF3B82F6),
            opacity: 0.03,
          ),
          // Small gold accent — right side
          _Orb(
            top: size.height * 0.55,
            right: -size.width * 0.1,
            width: size.width * 0.45,
            height: size.height * 0.2,
            color: AppColors.primary,
            opacity: 0.04,
          ),
        ];

      case GlassBackgroundStyle.standard:
        return [
          // Top-left gold glow
          _Orb(
            top: -size.height * 0.05,
            left: -size.width * 0.15,
            width: size.width * 0.65,
            height: size.height * 0.25,
            color: AppColors.primary,
            opacity: 0.05,
          ),
          // Bottom-right subtle accent
          _Orb(
            bottom: size.height * 0.1,
            right: -size.width * 0.1,
            width: size.width * 0.5,
            height: size.height * 0.2,
            color: AppColors.primary,
            opacity: 0.03,
          ),
        ];

      case GlassBackgroundStyle.minimal:
        return [
          // Single subtle top glow
          _Orb(
            top: -size.height * 0.1,
            left: size.width * 0.15,
            width: size.width * 0.7,
            height: size.height * 0.2,
            color: AppColors.primary,
            opacity: 0.04,
          ),
        ];
    }
  }
}

enum GlassBackgroundStyle {
  auth,     // Hero screens (login, onboarding) — more dramatic
  standard, // Main app screens (dashboard, lists)
  minimal,  // Detail/settings screens — subtler
}

class _Orb extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double width;
  final double height;
  final Color color;
  final double opacity;

  const _Orb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(width),
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
