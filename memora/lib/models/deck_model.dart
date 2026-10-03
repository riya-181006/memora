class DeckModel {
  final String id;
  final String title;
  final String description;
  final int cardCount;
  final int dueCount;
  final DateTime? createdAt;

  const DeckModel({
    required this.id,
    required this.title,
    this.description = '',
    this.cardCount = 0,
    this.dueCount = 0,
    this.createdAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      cardCount: (json['cardCount'] as num?)?.toInt() ?? 0,
      dueCount: (json['dueCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')
          ?.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  DeckModel copyWith({
    String? title,
    String? description,
    int? cardCount,
    int? dueCount,
  }) {
    return DeckModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      cardCount: cardCount ?? this.cardCount,
      dueCount: dueCount ?? this.dueCount,
      createdAt: createdAt,
    );
  }
}