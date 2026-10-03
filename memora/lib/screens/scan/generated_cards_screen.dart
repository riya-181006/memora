import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/primary_button.dart';
import '../deck/card_edit_screen.dart';

class GeneratedCardsScreen extends StatefulWidget {
  const GeneratedCardsScreen({super.key});

  @override
  State<GeneratedCardsScreen> createState() => _GeneratedCardsScreenState();
}

class _GeneratedCardsScreenState extends State<GeneratedCardsScreen> {
  final _newDeck = TextEditingController();
  String? _deckId;

  @override
  void dispose() {
    _newDeck.dispose();
    super.dispose();
  }

  Future<void> _edit(int index) async {
    final provider = context.read<DeckProvider>();
    final card = provider.generated[index];

    final draft = await Navigator.of(context).push<CardDraft>(
      MaterialPageRoute(
        builder: (_) => CardEditScreen(
          title: 'Edit card',
          question: card.question,
          answer: card.answer,
        ),
      ),
    );

    if (draft != null) {
      provider.editGenerated(index, draft.question, draft.answer);
    }
  }

  Future<void> _save() async {
    final provider = context.read<DeckProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    String? deckId = _deckId;
    final newName = _newDeck.text.trim();

    if (newName.isNotEmpty) {
      final deck = await provider.createDeck(newName);
      if (deck == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Could not create the deck.')),
        );
        return;
      }
      deckId = deck.id;
    }

    if (deckId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Pick a deck or enter a new deck name.')),
      );
      return;
    }

    final ok = await provider.saveGenerated(deckId);

    if (ok) {
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(content: Text('Flashcards saved')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not save the cards.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeckProvider>();
    final decks = provider.decks;
    final cards = provider.generated;

    if (_deckId == null || !decks.any((d) => d.id == _deckId)) {
      _deckId = decks.isEmpty ? null : decks.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: Text('${cards.length} cards')),
      body: LoadingOverlay(
        isLoading: provider.isSaving,
        message: 'Saving cards…',
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: cards.isEmpty
                    ? const Center(
                  child: Text(
                    'No cards left. Go back and generate again.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final card = cards[i];
                    return GlassCard(
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _edit(i),
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                onPressed: () =>
                                    provider.removeGenerated(i),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                ),
                                tooltip: 'Remove',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: GlassCard(
                  child: Column(
                    children: [
                      if (decks.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: _deckId,
                          dropdownColor: AppColors.bgMid,
                          decoration: const InputDecoration(
                            labelText: 'Save to deck',
                          ),
                          items: [
                            for (final d in decks)
                              DropdownMenuItem(value: d.id, child: Text(d.title)),
                          ],
                          onChanged: (v) => setState(() => _deckId = v),
                        ),
                      if (decks.isNotEmpty) const SizedBox(height: 12),
                      TextField(
                        controller: _newDeck,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText:
                          decks.isEmpty ? 'New deck name' : 'Or new deck name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Save flashcards',
                        icon: Icons.check_rounded,
                        onPressed: cards.isEmpty ? null : _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}