class Genre {
  final String id;
  final String title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Genre({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description};
  }
}

class GenreResponse {
  final List<Genre> data;

  GenreResponse({required this.data});

  factory GenreResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return GenreResponse(
      data: dataList.map((item) => Genre.fromJson(item)).toList(),
    );
  }
}
