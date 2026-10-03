import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/card_model.dart';
import 'generate_service.dart';

class CardService {
  CardService._();

  static final CardService instance = CardService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<CardModel>> getCards(String deckId) async {
    final data = await _api.get(ApiConstants.cardsByDeck(deckId));
    return _parseList(data);
  }

  Future<List<CardModel>> getDueCards() async {
    final data = await _api.get(ApiConstants.dueCards);
    return _parseList(data);
  }

  Future<CardModel> createCard({
    required String deckId,
    required String question,
    required String answer,
  }) async {
    final data = await _api.post(
      ApiConstants.cards,
      body: {'deckId': deckId, 'question': question, 'answer': answer},
    );
    return _parseOne(data);
  }

  Future<List<CardModel>> createMany(
      String deckId,
      List<GeneratedCard> cards,
      ) {
    return Future.wait(
      cards.map(
            (c) => createCard(
          deckId: deckId,
          question: c.question,
          answer: c.answer,
        ),
      ),
    );
  }

  Future<CardModel> updateCard(
      String id, {
        required String question,
        required String answer,
      }) async {
    final data = await _api.put(
      ApiConstants.cardById(id),
      body: {'question': question, 'answer': answer},
    );
    return _parseOne(data);
  }

  Future<void> deleteCard(String id) async {
    await _api.delete(ApiConstants.cardById(id));
  }

  Future<CardModel> reviewCard(String id, int quality) async {
    final data = await _api.post(
      ApiConstants.reviewCard(id),
      body: {'quality': quality},
    );
    return _parseOne(data);
  }

  List<CardModel> _parseList(dynamic data) {
    final list = data is List ? data : (data['cards'] as List? ?? []);
    return list
        .map((e) => CardModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  CardModel _parseOne(dynamic data) {
    final json = (data is Map && data['card'] is Map) ? data['card'] : data;
    return CardModel.fromJson(Map<String, dynamic>.from(json as Map));
  }
}