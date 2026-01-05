import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/novel.dart';
import '../../models/genre.dart';
import '../../services/novel_service.dart';
import '../../widgets/novel_card.dart';
import '../../widgets/skeletons.dart';

class NovelsScreen extends StatefulWidget {
  const NovelsScreen({super.key});

  @override
  State<NovelsScreen> createState() => _NovelsScreenState();
}

class _NovelsScreenState extends State<NovelsScreen> {
  final NovelService _novelService = NovelService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Novel> _novels = [];
  List<Genre> _genres = [];
  List<String> _selectedGenres = [];
  bool _loading = true;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  String _sortBy = 'newest';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadNovels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _novelService.fetchAllGenres();
      setState(() => _genres = genres);
    } catch (e) {
      debugPrint('Failed to load genres: $e');
    }
  }

  Future<void> _loadNovels({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _novelService.fetchNovels(
        page: page,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        genres: _selectedGenres.isNotEmpty ? _selectedGenres.join(',') : null,
        sort: _sortBy,
      );

      setState(() {
        _novels = response.data;
        _currentPage = response.page;
        _totalPages = response.totalPages;
        _totalItems = response.totalItems;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load novels';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _currentPage = 1;
      _loadNovels(page: 1);
    });
  }

  void _toggleGenre(String genreTitle) {
    setState(() {
      if (_selectedGenres.contains(genreTitle)) {
        _selectedGenres.remove(genreTitle);
      } else {
        _selectedGenres.add(genreTitle);
      }
    });
    _currentPage = 1;
    _loadNovels(page: 1);
  }

  void _clearGenres() {
    setState(() => _selectedGenres.clear());
    _currentPage = 1;
    _loadNovels(page: 1);
  }

  void _onSortChanged(String? value) {
    if (value != null && value != _sortBy) {
      setState(() => _sortBy = value);
      _currentPage = 1;
      _loadNovels(page: 1);
    }
  }

  void _onPageChanged(int page) {
    _loadNovels(page: page);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _navigateToDetail(Novel novel) {
    Navigator.pushNamed(context, '/novel', arguments: novel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadNovels(page: _currentPage),
        color: AppTheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppTheme.background,
              title: const Text('Browse Novels'),
            ),

            // Search & Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search & Sort Row
                    Row(
                      children: [
                        // Search Bar
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search novels...',
                                hintStyle: TextStyle(color: AppTheme.textMuted),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.textMuted,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Sort Dropdown
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              onChanged: _onSortChanged,
                              dropdownColor: AppTheme.card,
                              borderRadius: BorderRadius.circular(12),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppTheme.textMuted,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'newest',
                                  child: Text(
                                    'Newest',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'oldest',
                                  child: Text(
                                    'Oldest',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'popular',
                                  child: Text(
                                    'Popular',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'alphabetical',
                                  child: Text(
                                    'A - Z',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Genre Filter
                    if (_genres.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter by Genre',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (_selectedGenres.isNotEmpty)
                            GestureDetector(
                              onTap: _clearGenres,
                              child: Text(
                                'Clear all (${_selectedGenres.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _genres.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final genre = _genres[index];
                            final isSelected = _selectedGenres.contains(
                              genre.title.toLowerCase(),
                            );
                            return GestureDetector(
                              onTap: () =>
                                  _toggleGenre(genre.title.toLowerCase()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Text(
                                  genre.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Results Info
                    if (!_loading && _error == null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _totalItems > 0
                            ? 'Showing ${_novels.length} of $_totalItems novels${_searchController.text.isNotEmpty ? ' for "${_searchController.text}"' : ''}'
                            : 'No novels found',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Content
            if (_loading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                sliver: SliverToBoxAdapter(child: NovelGridSkeleton(count: 6)),
              )
            else if (_error != null)
              SliverFillRemaining(child: _buildErrorState())
            else if (_novels.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else ...[
              // Novels Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => NovelCard(
                      novel: _novels[index],
                      onTap: () => _navigateToDetail(_novels[index]),
                    ),
                    childCount: _novels.length,
                  ),
                ),
              ),

              // Pagination
              if (_totalPages > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: _buildPagination(),
                  ),
                ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.library_books_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Novels Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedGenres.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'No novels available at the moment',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Failed to load novels',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _loadNovels(page: _currentPage),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        IconButton(
          onPressed: _currentPage > 1
              ? () => _onPageChanged(_currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage > 1
                ? AppTheme.surface
                : AppTheme.surface.withOpacity(0.5),
            foregroundColor: _currentPage > 1
                ? AppTheme.textPrimary
                : AppTheme.textMuted,
          ),
        ),
        const SizedBox(width: 12),

        // Page Numbers
        ...List.generate(_totalPages > 5 ? 5 : _totalPages, (index) {
          int pageNum;
          if (_totalPages <= 5) {
            pageNum = index + 1;
          } else if (_currentPage <= 3) {
            pageNum = index + 1;
          } else if (_currentPage >= _totalPages - 2) {
            pageNum = _totalPages - 4 + index;
          } else {
            pageNum = _currentPage - 2 + index;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _onPageChanged(pageNum),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentPage == pageNum
                      ? AppTheme.primary
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pageNum',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _currentPage == pageNum
                        ? Colors.white
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 12),

        // Next Button
        IconButton(
          onPressed: _currentPage < _totalPages
              ? () => _onPageChanged(_currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage < _totalPages
                ? AppTheme.surface
                : AppTheme.surface.withOpacity(0.5),
            foregroundColor: _currentPage < _totalPages
                ? AppTheme.textPrimary
                : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
