import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/card_model.dart';
import '../../models/deck_model.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../review/review_screen.dart';
import 'card_edit_screen.dart';

class DeckDetailScreen extends StatefulWidget {
  final DeckModel deck;

  const DeckDetailScreen({super.key, required this.deck});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DeckProvider>().loadCards(widget.deck.id);
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addCard() async {
    final draft = await Navigator.of(context).push<CardDraft>(
      MaterialPageRoute(
        builder: (_) => const CardEditScreen(title: 'New card'),
      ),
    );
    if (draft == null || !mounted) return;

    final provider = context.read<DeckProvider>();
    final ok = await provider.addCard(
      deckId: widget.deck.id,
      question: draft.question,
      answer: draft.answer,
    );
    if (!ok && mounted) _snack(provider.error ?? 'Could not add the card.');
  }

  Future<void> _editCard(CardModel card) async {
    final draft = await Navigator.of(context).push<CardDraft>(
      MaterialPageRoute(
        builder: (_) => CardEditScreen(
          title: 'Edit card',
          question: card.question,
          answer: card.answer,
        ),
      ),
    );
    if (draft == null || !mounted) return;

    final provider = context.read<DeckProvider>();
    final ok = await provider.updateCard(
      card.id,
      question: draft.question,
      answer: draft.answer,
    );
    if (!ok && mounted) _snack(provider.error ?? 'Could not update the card.');
  }

  Future<void> _deleteCard(CardModel card) async {
    final provider = context.read<DeckProvider>();
    final ok = await provider.deleteCard(card.id, widget.deck.id);
    if (!ok && mounted) _snack(provider.error ?? 'Could not delete the card.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeckProvider>();
    final cards = provider.cards;

    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add card'),
      ),
      body: SafeArea(
        child: provider.isCardsLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            if (cards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PrimaryButton(
                  label: 'Review this deck',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ReviewScreen(deckId: widget.deck.id),
                    ),
                  ),
                ),
              ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            if (cards.isEmpty && provider.error == null)
              const GlassCard(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No cards yet. Tap "Add card" or scan some notes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            for (final card in cards)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.answer,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          if (card.isDue)
                            const Text(
                              'Due',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _editCard(card),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () => _deleteCard(card),
                            icon: const Icon(Icons.delete_outline_rounded),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}