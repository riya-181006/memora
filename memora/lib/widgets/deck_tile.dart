import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/deck_model.dart';
import 'glass_card.dart';

class DeckTile extends StatelessWidget {
  final DeckModel deck;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DeckTile({
    super.key,
    required this.deck,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cardsLabel = deck.cardCount == 1 ? 'card' : 'cards';

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.style_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (deck.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    deck.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${deck.cardCount} $cardsLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (deck.dueCount > 0) _DueBadge(count: deck.dueCount),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Delete deck',
            ),
        ],
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  final int count;

  const _DueBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFB86C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent),
      ),
      child: Text(
        '$count due',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}