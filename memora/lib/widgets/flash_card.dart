import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FlashCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool showAnswer;
  final VoidCallback? onTap;

  const FlashCard({
    super.key,
    required this.question,
    required this.answer,
    required this.showAnswer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: showAnswer ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          final isBack = value > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * math.pi),
            child: isBack
                ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(math.pi),
              child: _Face(
                label: 'Answer',
                text: answer,
                highlight: true,
              ),
            )
                : _Face(
              label: 'Question',
              text: question,
              hint: 'Tap to flip',
            ),
          );
        },
      ),
    );
  }
}

class _Face extends StatelessWidget {
  final String label;
  final String text;
  final String? hint;
  final bool highlight;

  const _Face({
    required this.label,
    required this.text,
    this.hint,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: highlight ? AppColors.glassFillStrong : AppColors.glassFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlight ? AppColors.accent : AppColors.glassBorder,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.accent : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 24),
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}