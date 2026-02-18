import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';
import '../../models/genre.dart';
import '../../services/novel_service.dart';
import '../../services/bookmark_service.dart';

class NovelDetailScreen extends StatefulWidget {
  final String novelId;

  const NovelDetailScreen({super.key, required this.novelId});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  final NovelService _novelService = NovelService();
  final BookmarkService _bookmarkService = BookmarkService();

  Novel? _novel;
  List<Chapter> _chapters = [];
  List<Genre> _genres = [];
  bool _loading = true;
  bool _isDescriptionExpanded = false;
  bool _isBookmarked = false;
  bool _bookmarkLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final novel = await _novelService.fetchNovelById(widget.novelId);
      final chapters = await _novelService.fetchChapters(widget.novelId);
      final genres = await _novelService.fetchNovelGenres(widget.novelId);
      final bookmarkStatus = await _bookmarkService.checkBookmark(
        widget.novelId,
      );

      setState(() {
        _novel = novel;
        _chapters = chapters.data
          ..sort((a, b) => a.chapterNum.compareTo(b.chapterNum));
        _genres = genres;
        _isBookmarked = bookmarkStatus.isBookmarked;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkLoading) return;

    setState(() => _bookmarkLoading = true);

    try {
      final result = await _bookmarkService.toggleBookmark(widget.novelId);
      setState(() {
        _isBookmarked = result.isBookmarked;
        _bookmarkLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isBookmarked
                  ? 'Added to bookmarks'
                  : 'Removed from bookmarks',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _bookmarkLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to update bookmark',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_novel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Novel not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.background,
            actions: [
              // Bookmark Button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: _toggleBookmark,
                  icon: _bookmarkLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        )
                      : Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: _isBookmarked
                              ? AppTheme.primary
                              : Colors.white,
                        ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _novel!.cover,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.background.withOpacity(0.8),
                          AppTheme.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _novel!.cover,
                          width: 100,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _novel!.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _novel!.author,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildBadge(
                                  _novel!.status,
                                  _getStatusColor(_novel!.status),
                                ),
                                _buildBadge(
                                  _novel!.language,
                                  AppTheme.surfaceLight,
                                ),
                                if (_novel!.popular)
                                  _buildBadge('Popular', AppTheme.warning),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Genres
                  if (_genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _genres
                          .map(
                            (g) => Chip(
                              label: Text(
                                g.title,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.primary.withOpacity(
                                0.1,
                              ),
                              side: BorderSide(
                                color: AppTheme.primary.withOpacity(0.3),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(
                      () => _isDescriptionExpanded = !_isDescriptionExpanded,
                    ),
                    child: Text(
                      _novel!.description,
                      maxLines: _isDescriptionExpanded ? null : 4,
                      overflow: _isDescriptionExpanded
                          ? null
                          : TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ),
                  if (_novel!.description.length > 200)
                    TextButton(
                      onPressed: () => setState(
                        () => _isDescriptionExpanded = !_isDescriptionExpanded,
                      ),
                      child: Text(
                        _isDescriptionExpanded ? 'Show Less' : 'Read More',
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Chapters Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Chapters (${_chapters.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Chapters Grid
                  if (_chapters.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No chapters available yet'),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = _chapters[index];
                        return _buildChapterTile(chapter);
                      },
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // Start Reading Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _chapters.isNotEmpty
                ? () => _openChapter(_chapters.first)
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text('Start Reading'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildChapterTile(Chapter chapter) {
    return GestureDetector(
      onTap: () => _openChapter(chapter),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${chapter.chapterNum}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Ch.',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return AppTheme.success;
      case 'completed':
        return AppTheme.primary;
      default:
        return AppTheme.textMuted;
    }
  }

  void _openChapter(Chapter chapter) {
    Navigator.pushNamed(
      context,
      '/reader',
      arguments: {
        'chapterId': chapter.id,
        'novelId': widget.novelId,
        'novelTitle': _novel?.title ?? '',
      },
    );
  }
}
