class CardModel {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final int repetitions;
  final int interval;
  final double easeFactor;
  final DateTime nextReview;

  const CardModel({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.repetitions = 0,
    this.interval = 0,
    this.easeFactor = 2.5,
    required this.nextReview,
  });

  bool get isDue => !nextReview.isAfter(DateTime.now());

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      deckId: (json['deckId'] ?? json['deck'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      nextReview: DateTime.tryParse(json['nextReview']?.toString() ?? '')
          ?.toLocal() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'question': question,
      'answer': answer,
    };
  }

  CardModel copyWith({
    String? question,
    String? answer,
    int? repetitions,
    int? interval,
    double? easeFactor,
    DateTime? nextReview,
  }) {
    return CardModel(
      id: id,
      deckId: deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      repetitions: repetitions ?? this.repetitions,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReview: nextReview ?? this.nextReview,
    );
  }
}