import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';

class ReviewProvider extends ChangeNotifier {
  static const int again = 1;
  static const int hard = 3;
  static const int good = 4;
  static const int easy = 5;

  final CardService _service = CardService.instance;

  List<CardModel> _queue = [];
  int _index = 0;
  int _total = 0;
  int _completed = 0;

  bool _started = false;
  bool _showAnswer = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  CardModel? get current => _index < _queue.length ? _queue[_index] : null;

  bool get showAnswer => _showAnswer;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  bool get isEmpty => _started && _queue.isEmpty;
  bool get isFinished => _started && _queue.isNotEmpty && _index >= _queue.length;

  int get total => _total;
  int get completed => _completed;
  double get progress => _total == 0 ? 0 : _completed / _total;

  Future<void> loadSession({String? deckId}) async {
    _isLoading = true;
    _error = null;
    _started = false;
    _showAnswer = false;
    _queue = [];
    _index = 0;
    _total = 0;
    _completed = 0;
    notifyListeners();

    try {
      if (deckId == null) {
        _queue = await _service.getDueCards();
      } else {
        final all = await _service.getCards(deckId);
        _queue = all.where((c) => c.isDue).toList();
      }
      _total = _queue.length;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Something went wrong. Try again.';
    }

    _started = _error == null;
    _isLoading = false;
    notifyListeners();
  }

  void flip() {
    if (current == null) return;
    _showAnswer = !_showAnswer;
    notifyListeners();
  }

  Future<bool> rate(int quality) async {
    final card = current;
    if (card == null || _isSubmitting) return false;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _service.reviewCard(card.id, quality);

      if (quality < hard) {
        _queue.add(card);
      } else {
        _completed++;
      }

      _index++;
      _showAnswer = false;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Something went wrong. Try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _queue = [];
    _index = 0;
    _total = 0;
    _completed = 0;
    _started = false;
    _showAnswer = false;
    _error = null;
    notifyListeners();
  }
}