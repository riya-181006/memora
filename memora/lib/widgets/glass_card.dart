import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.blur = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: AppColors.glassFill,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
        ),
        const Positioned(
          top: -80,
          left: -60,
          child: _Blob(color: AppColors.blobPink, size: 240),
        ),
        const Positioned(
          bottom: -100,
          right: -80,
          child: _Blob(color: AppColors.blobOrange, size: 280),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}