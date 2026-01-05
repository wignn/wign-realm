import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../models/chapter.dart';
import '../../services/novel_service.dart';
import '../../services/storage_service.dart';

class ReaderScreen extends StatefulWidget {
  final String chapterId;
  final String novelId;
  final String novelTitle;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    required this.novelId,
    required this.novelTitle,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final NovelService _novelService = NovelService();
  final StorageService _storage = StorageService();
  final ScrollController _scrollController = ScrollController();

  Chapter? _chapter;
  List<Chapter> _allChapters = [];
  bool _loading = true;
  bool _showControls = true;

  // Reader settings
  double _fontSize = 18.0;
  String _theme = 'dark'; // dark, light, sepia

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadChapter();
    _loadAllChapters();
  }

  Future<void> _loadSettings() async {
    _fontSize = await _storage.getReaderFontSize();
    _theme = await _storage.getReaderTheme();
    setState(() {});
  }

  Future<void> _loadChapter() async {
    setState(() => _loading = true);
    try {
      final chapter = await _novelService.fetchChapterById(widget.chapterId);
      setState(() {
        _chapter = chapter;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadAllChapters() async {
    try {
      final response = await _novelService.fetchChapters(widget.novelId);
      setState(() {
        _allChapters = response.data
          ..sort((a, b) => a.chapterNum.compareTo(b.chapterNum));
      });
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _theme == 'light'
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bgColor,
        body: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            children: [
              // Content
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : _chapter == null
                  ? const Center(child: Text('Chapter not found'))
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: 100,
                        bottom: 120,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chapter Title
                          Text(
                            'Chapter ${_chapter!.chapterNum}',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _chapter!.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Content
                          SelectableText(
                            _cleanHtml(_chapter!.content),
                            style: TextStyle(
                              fontSize: _fontSize,
                              height: 1.8,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

              // Top Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 8,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [bgColor, bgColor.withOpacity(0)],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.novelTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            if (_chapter != null)
                              Text(
                                'Chapter ${_chapter!.chapterNum}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: textColor),
                        onPressed: _showSettingsSheet,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [bgColor, bgColor.withOpacity(0)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _hasPrev ? _goToPrev : null,
                        icon: const Icon(Icons.chevron_left, size: 20),
                        label: const Text('Prev'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surface,
                          foregroundColor: textColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _hasNext ? _goToNext : null,
                        icon: const Text('Next'),
                        label: const Icon(Icons.chevron_right, size: 20),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reader Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Font Size
              Row(
                children: [
                  const Text('Font Size'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_fontSize > 14) {
                        setModalState(() => _fontSize -= 2);
                        setState(() {});
                        _storage.saveReaderFontSize(_fontSize);
                      }
                    },
                  ),
                  Text('${_fontSize.toInt()}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_fontSize < 28) {
                        setModalState(() => _fontSize += 2);
                        setState(() {});
                        _storage.saveReaderFontSize(_fontSize);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Theme
              const Text('Theme'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildThemeOption(
                    'dark',
                    'Dark',
                    Colors.grey[900]!,
                    setModalState,
                  ),
                  const SizedBox(width: 12),
                  _buildThemeOption(
                    'light',
                    'Light',
                    Colors.white,
                    setModalState,
                  ),
                  const SizedBox(width: 12),
                  _buildThemeOption(
                    'sepia',
                    'Sepia',
                    const Color(0xFFF4ECD8),
                    setModalState,
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String theme,
    String label,
    Color color,
    StateSetter setModalState,
  ) {
    final isSelected = _theme == theme;
    return GestureDetector(
      onTap: () {
        setModalState(() => _theme = theme);
        setState(() {});
        _storage.saveReaderTheme(theme);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: theme == 'light'
                ? Colors.black
                : (theme == 'sepia' ? Colors.brown : Colors.white),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_theme) {
      case 'light':
        return Colors.white;
      case 'sepia':
        return const Color(0xFFF4ECD8);
      default:
        return AppTheme.background;
    }
  }

  Color _getTextColor() {
    switch (_theme) {
      case 'light':
        return Colors.black87;
      case 'sepia':
        return Colors.brown[800]!;
      default:
        return AppTheme.textPrimary;
    }
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  bool get _hasPrev {
    if (_chapter == null || _allChapters.isEmpty) return false;
    return _allChapters.any((c) => c.chapterNum < _chapter!.chapterNum);
  }

  bool get _hasNext {
    if (_chapter == null || _allChapters.isEmpty) return false;
    return _allChapters.any((c) => c.chapterNum > _chapter!.chapterNum);
  }

  void _goToPrev() {
    final prev = _allChapters
        .where((c) => c.chapterNum < _chapter!.chapterNum)
        .reduce((a, b) => a.chapterNum > b.chapterNum ? a : b);
    _navigateToChapter(prev);
  }

  void _goToNext() {
    final next = _allChapters
        .where((c) => c.chapterNum > _chapter!.chapterNum)
        .reduce((a, b) => a.chapterNum < b.chapterNum ? a : b);
    _navigateToChapter(next);
  }

  void _navigateToChapter(Chapter chapter) {
    Navigator.pushReplacementNamed(
      context,
      '/reader',
      arguments: {
        'chapterId': chapter.id,
        'novelId': widget.novelId,
        'novelTitle': widget.novelTitle,
      },
    );
  }
}
