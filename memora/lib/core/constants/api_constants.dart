class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.225.124.104:5000/api';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  static const String decks = '/decks';
  static String deckById(String id) => '/decks/$id';

  static const String cards = '/cards';
  static String cardById(String id) => '/cards/$id';
  static String cardsByDeck(String deckId) => '/decks/$deckId/cards';
  static String reviewCard(String id) => '/cards/$id/review';
  static const String dueCards = '/cards/due';

  static const String generate = '/generate';
}