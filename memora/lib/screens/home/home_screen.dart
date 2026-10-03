import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/deck_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/deck_tile.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../deck/deck_detail_screen.dart';
import '../review/review_screen.dart';
import '../scan/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DeckProvider>().loadDecks();
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) context.read<DeckProvider>().loadDecks();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createDeck() async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        title: const Text('New deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty || !mounted) return;

    final provider = context.read<DeckProvider>();
    final deck = await provider.createDeck(title);
    if (deck == null && mounted) {
      _snack(provider.error ?? 'Could not create the deck.');
    }
  }

  Future<void> _deleteDeck(DeckModel deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        title: Text('Delete "${deck.title}"?'),
        content: const Text('All flashcards in this deck will be deleted too.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<DeckProvider>();
    final ok = await provider.deleteDeck(deck.id);
    if (!ok && mounted) {
      _snack(provider.error ?? 'Could not delete the deck.');
    }
  }

  Future<void> _logout() async {
    context.read<DeckProvider>().reset();
    context.read<ReviewProvider>().reset();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final decks = context.watch<DeckProvider>();

    final fullName = (auth.user?.name ?? '').trim();
    final firstName = fullName.isEmpty ? 'there' : fullName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your decks'),
        actions: [
          IconButton(
            onPressed: _createDeck,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New deck',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const ScanScreen()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.document_scanner_rounded),
        label: const Text('Scan notes'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: decks.loadDecks,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $firstName',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      decks.totalDue == 0
                          ? 'No cards due right now.'
                          : '${decks.totalDue} cards are waiting for you.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    if (decks.totalDue > 0) ...[
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Review due cards',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => _open(const ReviewScreen()),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (decks.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    decks.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              if (decks.isLoading && decks.decks.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (decks.decks.isEmpty && decks.error == null)
                const GlassCard(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 40,
                        color: AppColors.accent,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No decks yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scan your notes or tap + to create a deck.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                for (final deck in decks.decks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DeckTile(
                      deck: deck,
                      onTap: () => _open(DeckDetailScreen(deck: deck)),
                      onDelete: () => _deleteDeck(deck),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}