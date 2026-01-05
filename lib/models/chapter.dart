class Chapter {
  final String id;
  final String title;
  final String content;
  final int chapterNum;
  final String bookId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.chapterNum,
    required this.bookId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      chapterNum: json['chapter_num'] ?? 0,
      bookId: json['book_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'chapter_num': chapterNum,
      'book_id': bookId,
    };
  }
}

class ChapterResponse {
  final List<Chapter> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  ChapterResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory ChapterResponse.fromJson(Map<String, dynamic> json) {
    return ChapterResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => Chapter.fromJson(item))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
