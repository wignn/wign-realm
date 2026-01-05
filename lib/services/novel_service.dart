import '../config/api_config.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/genre.dart';
import 'api_service.dart';

class NovelService {
  final ApiService _api = ApiService();

  // Fetch novels with pagination and filters
  Future<NovelResponse> fetchNovels({
    int page = 1,
    String? search,
    String? genres,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{'page': page};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (genres != null && genres.isNotEmpty) {
      queryParams['genres'] = genres;
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await _api.get(
      ApiConfig.books,
      queryParameters: queryParams,
    );
    return NovelResponse.fromJson(response.data);
  }

  // Fetch single novel by ID
  Future<Novel> fetchNovelById(String id) async {
    final response = await _api.get(ApiConfig.book(id));
    final data = response.data['data'] ?? response.data;
    return Novel.fromJson(data);
  }

  // Fetch genres for a novel
  Future<List<Genre>> fetchNovelGenres(String novelId) async {
    final response = await _api.get(ApiConfig.bookGenres(novelId));
    final genreResponse = GenreResponse.fromJson(response.data);
    return genreResponse.data;
  }

  // Fetch all genres
  Future<List<Genre>> fetchAllGenres() async {
    final response = await _api.get(ApiConfig.genres);
    final genreResponse = GenreResponse.fromJson(response.data);
    return genreResponse.data;
  }

  // Fetch chapters for a novel
  Future<ChapterResponse> fetchChapters(String novelId, {int page = 1}) async {
    final response = await _api.get(
      ApiConfig.chaptersByBook(novelId),
      queryParameters: {'page': page, 'page_size': 100},
    );
    return ChapterResponse.fromJson(response.data);
  }

  // Fetch single chapter
  Future<Chapter> fetchChapterById(String id) async {
    final response = await _api.get(ApiConfig.chapter(id));
    final data = response.data['data'] ?? response.data;
    return Chapter.fromJson(data);
  }
}
