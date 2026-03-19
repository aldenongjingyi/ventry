import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final bool showHighlight;
  final bool showGlow;
  final List<BoxShadow>? glow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.blur = 12,
    this.borderColor,
    this.showHighlight = true,
    this.showGlow = false,
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glow ?? (showGlow ? AppColors.subtleGlow : null),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: showHighlight
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x14FFFFFF), // white 8% — top-left highlight
                        Color(0x0AFFFFFF), // white 4% — middle
                        Color(0x08FFFFFF), // white 3% — bottom-right
                      ],
                      stops: [0.0, 0.4, 1.0],
                    )
                  : null,
              color: showHighlight ? null : AppColors.glass,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? const Color(0x20FFFFFF), // white 12%
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
