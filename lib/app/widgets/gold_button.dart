import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Primary button — acc (#2B7FFF) background, 10px radius, 13px/w500 white text.
class GoldButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const GoldButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: Material(
        color: AppColors.acc,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : Text(label, style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}
