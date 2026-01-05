import '../config/api_config.dart';
import '../models/bookmark.dart';
import 'api_service.dart';

/// Service for bookmark-related API calls
class BookmarkService {
  final ApiService _api = ApiService();

  /// Get all bookmarks for current user
  Future<List<BookmarkWithBook>> getBookmarks() async {
    final response = await _api.get(ApiConfig.bookmarks);
    final List<dynamic> data = response.data is List ? response.data : [];
    return data.map((json) => BookmarkWithBook.fromJson(json)).toList();
  }

  /// Add a book to bookmarks
  Future<Bookmark> addBookmark(String bookId) async {
    final response = await _api.post(
      ApiConfig.bookmark,
      data: {'book_id': bookId},
    );
    return Bookmark.fromJson(response.data);
  }

  /// Remove a bookmark by ID
  Future<void> removeBookmark(String bookmarkId) async {
    await _api.delete('${ApiConfig.bookmark}/$bookmarkId');
  }

  /// Remove a bookmark by book ID
  Future<void> removeBookmarkByBook(String bookId) async {
    await _api.delete(ApiConfig.bookmarkByBook(bookId));
  }

  /// Check if a book is bookmarked
  Future<BookmarkStatus> checkBookmark(String bookId) async {
    try {
      final response = await _api.get(ApiConfig.checkBookmark(bookId));
      return BookmarkStatus.fromJson(response.data);
    } catch (e) {
      // If error (e.g., not authenticated), return not bookmarked
      return BookmarkStatus(isBookmarked: false, bookmarkId: null);
    }
  }

  /// Toggle bookmark status for a book
  Future<({bool isBookmarked, String? bookmarkId})> toggleBookmark(
    String bookId,
  ) async {
    final status = await checkBookmark(bookId);

    if (status.isBookmarked && status.bookmarkId != null) {
      await removeBookmark(status.bookmarkId!);
      return (isBookmarked: false, bookmarkId: null);
    } else {
      final bookmark = await addBookmark(bookId);
      return (isBookmarked: true, bookmarkId: bookmark.id);
    }
  }
}
