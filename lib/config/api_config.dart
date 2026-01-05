class ApiConfig {
  static const String baseUrl = String.fromEnvironment("BASE_URL", defaultValue: 'http://localhost:4001');
  static const String apiKey = String.fromEnvironment("API_KEY", defaultValue: '');
  // Replace with actual API key

  // Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String updateProfile = '/api/auth/profile';
  static const String changePassword = '/api/auth/password';

  static const String books = '/api/books';
  static String book(String id) => '/api/book/$id';
  static String bookGenres(String id) => '/api/book/$id/genres';

  static const String genres = '/api/genres';
  static String genre(String id) => '/api/genre/$id';

  static const String chapters = '/api/chapters';
  static String chaptersByBook(String bookId) => '/api/chapters/book/$bookId';
  static String chapter(String id) => '/api/chapter/$id';

  static const String bookmark = '/api/bookmark';
  static const String bookmarks = '/api/bookmarks';
  static String checkBookmark(String bookId) => '/api/bookmark/check/$bookId';
  static String bookmarkByBook(String bookId) => '/api/bookmark/book/$bookId';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
