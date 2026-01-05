class Novel {
  final String id;
  final String title;
  final String author;
  final String cover;
  final String description;
  final String? asset;
  final String status;
  final String language;
  final int? releaseDate;
  final bool popular;
  final DateTime createdAt;
  final DateTime updatedAt;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.description,
    this.asset,
    required this.status,
    required this.language,
    this.releaseDate,
    required this.popular,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      cover: json['cover'] ?? '',
      description: json['description'] ?? '',
      asset: json['asset'],
      status: json['status'] ?? 'Ongoing',
      language: json['language'] ?? 'Korean',
      releaseDate: json['release_date'],
      popular: json['popular'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover': cover,
      'description': description,
      'asset': asset,
      'status': status,
      'language': language,
      'release_date': releaseDate,
      'popular': popular,
    };
  }
}

class NovelResponse {
  final List<Novel> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  NovelResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory NovelResponse.fromJson(Map<String, dynamic> json) {
    return NovelResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => Novel.fromJson(item))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
