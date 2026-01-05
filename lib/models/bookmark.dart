/// Bookmark model for storing bookmark data

/// Bookmark model for storing bookmark data
class Bookmark {
  final String id;
  final String bookId;
  final DateTime createdAt;

  Bookmark({required this.id, required this.bookId, required this.createdAt});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Book summary for bookmark list
class BookSummary {
  final String id;
  final String title;
  final String cover;
  final String author;
  final String description;

  BookSummary({
    required this.id,
    required this.title,
    required this.cover,
    required this.author,
    required this.description,
  });

  factory BookSummary.fromJson(Map<String, dynamic> json) {
    return BookSummary(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// Bookmark with embedded book data
class BookmarkWithBook {
  final String id;
  final String bookId;
  final DateTime createdAt;
  final BookSummary book;

  BookmarkWithBook({
    required this.id,
    required this.bookId,
    required this.createdAt,
    required this.book,
  });

  factory BookmarkWithBook.fromJson(Map<String, dynamic> json) {
    return BookmarkWithBook(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      book: BookSummary.fromJson(json['book'] ?? {}),
    );
  }
}

/// Bookmark status for check endpoint
class BookmarkStatus {
  final bool isBookmarked;
  final String? bookmarkId;

  BookmarkStatus({required this.isBookmarked, this.bookmarkId});

  factory BookmarkStatus.fromJson(Map<String, dynamic> json) {
    return BookmarkStatus(
      isBookmarked: json['is_bookmarked'] ?? false,
      bookmarkId: json['bookmark_id'],
    );
  }
}
