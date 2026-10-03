import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/review_provider.dart';
import '../../widgets/flash_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

class ReviewScreen extends StatefulWidget {
  final String? deckId;

  const ReviewScreen({super.key, this.deckId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReviewProvider>().loadSession(deckId: widget.deckId);
      }
    });
  }

  Widget _body(ReviewProvider r) {
    if (r.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (r.error != null && r.current == null && !r.isFinished) {
      return _Message(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load cards',
        body: r.error!,
        buttonLabel: 'Try again',
        onPressed: () => r.loadSession(deckId: widget.deckId),
      );
    }

    if (r.isEmpty) {
      return _Message(
        icon: Icons.check_circle_outline_rounded,
        title: 'All caught up',
        body: 'No cards are due right now. Come back later.',
        buttonLabel: 'Back',
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    if (r.isFinished) {
      return _Message(
        icon: Icons.celebration_rounded,
        title: 'Session complete',
        body: 'You reviewed ${r.total} cards. Nice work.',
        buttonLabel: 'Done',
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    final card = r.current;
    if (card == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: r.progress,
            minHeight: 6,
            backgroundColor: AppColors.glassFill,
            borderRadius: const BorderRadius.all(Radius.circular(3)),
          ),
          const SizedBox(height: 8),
          Text(
            '${r.completed} / ${r.total}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: FlashCard(
                  key: ValueKey(card.id),
                  question: card.question,
                  answer: card.answer,
                  showAnswer: r.showAnswer,
                  onTap: r.flip,
                ),
              ),
            ),
          ),
          if (r.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                r.error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          if (!r.showAnswer)
            PrimaryButton(label: 'Show answer', onPressed: r.flip)
          else
            Row(
              children: [
                _RateButton(
                  label: 'Again',
                  color: AppColors.error,
                  onTap: r.isSubmitting
                      ? null
                      : () => r.rate(ReviewProvider.again),
                ),
                _RateButton(
                  label: 'Hard',
                  color: AppColors.accent,
                  onTap: r.isSubmitting
                      ? null
                      : () => r.rate(ReviewProvider.hard),
                ),
                _RateButton(
                  label: 'Good',
                  color: AppColors.success,
                  onTap: r.isSubmitting
                      ? null
                      : () => r.rate(ReviewProvider.good),
                ),
                _RateButton(
                  label: 'Easy',
                  color: AppColors.secondary,
                  onTap: r.isSubmitting
                      ? null
                      : () => r.rate(ReviewProvider.easy),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: SafeArea(
        child: Consumer<ReviewProvider>(
          builder: (context, r, _) => _body(r),
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _RateButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: buttonLabel, onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}