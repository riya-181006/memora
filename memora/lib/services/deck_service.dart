import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/deck_model.dart';

class DeckService {
  DeckService._();

  static final DeckService instance = DeckService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<DeckModel>> getDecks() async {
    final data = await _api.get(ApiConstants.decks);
    final list = data is List ? data : (data['decks'] as List? ?? []);
    return list
        .map((e) => DeckModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<DeckModel> createDeck(
      String title, {
        String description = '',
      }) async {
    final data = await _api.post(
      ApiConstants.decks,
      body: {'title': title, 'description': description},
    );
    return _parseOne(data);
  }

  Future<DeckModel> updateDeck(
      String id, {
        required String title,
        String description = '',
      }) async {
    final data = await _api.put(
      ApiConstants.deckById(id),
      body: {'title': title, 'description': description},
    );
    return _parseOne(data);
  }

  Future<void> deleteDeck(String id) async {
    await _api.delete(ApiConstants.deckById(id));
  }

  DeckModel _parseOne(dynamic data) {
    final json = (data is Map && data['deck'] is Map) ? data['deck'] : data;
    return DeckModel.fromJson(Map<String, dynamic>.from(json as Map));
  }
}