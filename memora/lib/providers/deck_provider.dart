import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/card_model.dart';
import '../models/deck_model.dart';
import '../services/card_service.dart';
import '../services/deck_service.dart';
import '../services/generate_service.dart';

class DeckProvider extends ChangeNotifier {
  final DeckService _deckService = DeckService.instance;
  final CardService _cardService = CardService.instance;
  final GenerateService _generateService = GenerateService.instance;

  List<DeckModel> _decks = [];
  List<CardModel> _cards = [];
  List<GeneratedCard> _generated = [];

  bool _isLoading = false;
  bool _isCardsLoading = false;
  bool _isGenerating = false;
  bool _isSaving = false;
  String? _error;

  List<DeckModel> get decks => _decks;
  List<CardModel> get cards => _cards;
  List<GeneratedCard> get generated => _generated;

  bool get isLoading => _isLoading;
  bool get isCardsLoading => _isCardsLoading;
  bool get isGenerating => _isGenerating;
  bool get isSaving => _isSaving;
  String? get error => _error;

  int get totalDue => _decks.fold(0, (sum, d) => sum + d.dueCount);

  void reset() {
    _decks = [];
    _cards = [];
    _generated = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> loadDecks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _decks = await _deckService.getDecks();
    } catch (e) {
      _error = _msg(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<DeckModel?> createDeck(String title, {String description = ''}) async {
    try {
      final deck = await _deckService.createDeck(title, description: description);
      _decks = [deck, ..._decks];
      notifyListeners();
      return deck;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateDeck(
      String id, {
        required String title,
        String description = '',
      }) async {
    try {
      final updated = await _deckService.updateDeck(
        id,
        title: title,
        description: description,
      );
      _decks = _decks
          .map((d) => d.id == id
          ? d.copyWith(
        title: updated.title,
        description: updated.description,
      )
          : d)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDeck(String id) async {
    try {
      await _deckService.deleteDeck(id);
      _decks = _decks.where((d) => d.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCards(String deckId) async {
    _isCardsLoading = true;
    _error = null;
    _cards = [];
    notifyListeners();

    try {
      _cards = await _cardService.getCards(deckId);
    } catch (e) {
      _error = _msg(e);
    }

    _isCardsLoading = false;
    notifyListeners();
  }

  Future<bool> addCard({
    required String deckId,
    required String question,
    required String answer,
  }) async {
    try {
      final card = await _cardService.createCard(
        deckId: deckId,
        question: question,
        answer: answer,
      );
      _cards = [card, ..._cards];
      _bumpCount(deckId, 1);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCard(
      String id, {
        required String question,
        required String answer,
      }) async {
    try {
      final updated = await _cardService.updateCard(
        id,
        question: question,
        answer: answer,
      );
      _cards = _cards
          .map((c) => c.id == id
          ? c.copyWith(question: updated.question, answer: updated.answer)
          : c)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCard(String id, String deckId) async {
    try {
      await _cardService.deleteCard(id);
      _cards = _cards.where((c) => c.id != id).toList();
      _bumpCount(deckId, -1);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateFromText(String text, {int count = 10}) async {
    _isGenerating = true;
    _error = null;
    _generated = [];
    notifyListeners();

    try {
      _generated = await _generateService.generateCards(text, count: count);
      if (_generated.isEmpty) {
        _error = 'No flashcards could be made from this text.';
      }
    } catch (e) {
      _error = _msg(e);
    }

    _isGenerating = false;
    notifyListeners();
    return _generated.isNotEmpty;
  }

  void editGenerated(int index, String question, String answer) {
    if (index < 0 || index >= _generated.length) return;
    _generated[index] = GeneratedCard(question: question, answer: answer);
    notifyListeners();
  }

  void removeGenerated(int index) {
    if (index < 0 || index >= _generated.length) return;
    _generated.removeAt(index);
    notifyListeners();
  }

  void clearGenerated() {
    _generated = [];
    notifyListeners();
  }

  Future<bool> saveGenerated(String deckId) async {
    if (_generated.isEmpty) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _cardService.createMany(deckId, _generated);
      _generated = [];
      _isSaving = false;
      await loadDecks();
      return true;
    } catch (e) {
      _error = _msg(e);
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void _bumpCount(String deckId, int delta) {
    _decks = _decks
        .map((d) => d.id == deckId
        ? d.copyWith(cardCount: (d.cardCount + delta).clamp(0, 1 << 30))
        : d)
        .toList();
  }

  String _msg(Object e) {
    return e is ApiException ? e.message : 'Something went wrong. Try again.';
  }
}