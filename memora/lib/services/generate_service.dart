import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class GeneratedCard {
  final String question;
  final String answer;

  const GeneratedCard({required this.question, required this.answer});

  factory GeneratedCard.fromJson(Map<String, dynamic> json) {
    return GeneratedCard(
      question: (json['question'] ?? '').toString().trim(),
      answer: (json['answer'] ?? '').toString().trim(),
    );
  }
}

class GenerateService {
  GenerateService._();

  static final GenerateService instance = GenerateService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<GeneratedCard>> generateCards(
      String text, {
        int count = 10,
      }) async {
    final data = await _api.post(
      ApiConstants.generate,
      body: {'text': text, 'count': count},
      timeout: const Duration(seconds: 90),
    );
    final list = data is List ? data : (data['cards'] as List? ?? []);
    return list
        .map((e) => GeneratedCard.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((c) => c.question.isNotEmpty && c.answer.isNotEmpty)
        .toList();
  }
}