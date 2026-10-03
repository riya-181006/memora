import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x4DEC4899),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: isLoading ? null : onPressed,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}