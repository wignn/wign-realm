import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/novel.dart';
import '../../services/novel_service.dart';
import '../../widgets/novel_card.dart';
import '../../widgets/skeletons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NovelService _novelService = NovelService();

  List<Novel> _novels = [];
  List<Novel> _popularNovels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _novelService.fetchNovels(page: 1);
      setState(() {
        _novels = response.data;
        _popularNovels = response.data.where((n) => n.popular).take(5).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load novels';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppTheme.background,
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icons/image.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Wign Realm'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Popular Section
                  if (_popularNovels.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Popular Now',
                      Icons.local_fire_department,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularNovels.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final novel = _popularNovels[index];
                          return SizedBox(
                            width: 130,
                            child: NovelCard(
                              novel: novel,
                              onTap: () => _navigateToDetail(novel),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                  ],

                  if (_loading)
                    const NovelGridSkeleton(count: 6)
                  else if (_error != null)
                    _buildErrorWidget()
                  else if (_novels.isEmpty)
                    _buildEmptyWidget()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _novels.length,
                      itemBuilder: (context, index) {
                        final novel = _novels[index];
                        return NovelCard(
                          novel: novel,
                          onTap: () => _navigateToDetail(novel),
                        );
                      },
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/novels'),
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 48,
            color: AppTheme.textMuted,
          ),
          SizedBox(height: 16),
          Text('No novels available'),
        ],
      ),
    );
  }

  void _navigateToDetail(Novel novel) {
    Navigator.pushNamed(context, '/novel', arguments: novel.id);
  }
}
