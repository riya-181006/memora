import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/primary_button.dart';
import 'generated_cards_screen.dart';

class EditTextScreen extends StatefulWidget {
  final String initialText;

  const EditTextScreen({super.key, required this.initialText});

  @override
  State<EditTextScreen> createState() => _EditTextScreenState();
}

class _EditTextScreenState extends State<EditTextScreen> {
  late final TextEditingController _controller;
  int _count = 10;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final text = _controller.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (text.length < 30) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add a bit more text (30+ characters).')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final provider = context.read<DeckProvider>();
    final ok = await provider.generateFromText(text, count: _count);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GeneratedCardsScreen()),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not make flashcards.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = context.watch<DeckProvider>().isGenerating;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit text')),
      body: LoadingOverlay(
        isLoading: isGenerating,
        message: 'Making flashcards…',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: GlassCard(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Paste or type your notes here',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Cards',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    for (final n in [5, 10, 15])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$n'),
                          selected: _count == n,
                          onSelected: (_) => setState(() => _count = n),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _count == n
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Generate flashcards',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _generate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}