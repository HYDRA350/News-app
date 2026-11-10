import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';

/// Halaman Beranda (Home Screen) NewsScope.
///
/// Mengikuti referensi Stitch `beranda.html`:
/// - Header editorial dengan logo dan navigasi ke Berita Tersimpan.
/// - Editorial masthead sub-bar (tanggal dinamis • Edisi Pagi).
/// - Quick search bar interaktif dengan kemampuan pencarian real-time & clear text.
/// - Breaking News card & Sorotan Utama (hanya tampil jika tidak sedang dalam mode pencarian).
/// - Chip navigasi kategori interaktif ("Semua", "Bisnis", "Olahraga", "Teknologi", "Hiburan", "Kesehatan").
/// - Berita Terkini yang terhubung langsung ke [NewsProvider] dan [BookmarkProvider].
/// - Penanganan state loading, empty (termasuk empty search), dan error + retry.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'Semua',
    'Bisnis',
    'Olahraga',
    'Teknologi',
    'Hiburan',
    'Kesehatan',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsProvider>();
      if (provider.status == NewsStatus.initial) {
        provider.fetchNews();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          // Tangani loading state di awal
          if (newsProvider.isLoading && newsProvider.articles.isEmpty) {
            return const LoadingStateView();
          }

          // Tangani error state
          if (newsProvider.isError && newsProvider.articles.isEmpty) {
            return ErrorStateView(
              message: newsProvider.errorMessage,
              onRetry: () => newsProvider.refresh(),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => newsProvider.refresh(),
            child: _buildContent(newsProvider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.asset(
              'assets/images/newsscope_logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Center(
                  child: Text(
                    'NS',
                    style: TextStyle(
                      color: AppTheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'NewsScope',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'BERANDA',
                style: AppTheme.labelSm.copyWith(
                  letterSpacing: 1.2,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_outline, size: 22),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BookmarkScreen()),
            );
          },
          tooltip: 'Berita Tersimpan',
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppTheme.gutter),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: const Icon(
              Icons.person,
              size: 18,
              color: AppTheme.onPrimary,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppTheme.outlineVariant, height: 0.5),
      ),
    );
  }

  Widget _buildContent(NewsProvider newsProvider) {
    final articles = newsProvider.articles;
    final isSearching = newsProvider.searchQuery.isNotEmpty;

    final breakingArticle = (!isSearching && articles.isNotEmpty)
        ? articles.first
        : null;
    final featuredArticle = (!isSearching && articles.length > 1)
        ? articles[1]
        : null;
    final latestArticles = isSearching
        ? articles
        : (articles.length > 2 ? articles.sublist(2) : const <Article>[]);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppTheme.space2Xl),
      children: [
        // 1. Editorial Sub-Bar & Quick Search Bar Interaktif
        _buildEditorialSubBar(newsProvider),

        // 2. Kategori horizontal chip navigation (Interaktif)
        _buildCategoryChips(newsProvider),

        // Tampilkan Empty State jika hasil pencarian / filter kosong
        if (newsProvider.isEmpty || articles.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.space2Xl),
            child: EmptyStateView(
              title: isSearching
                  ? 'Berita Tidak Ditemukan'
                  : 'Belum Ada Berita',
              message: isSearching
                  ? 'Tidak ditemukan berita dengan kata kunci "${newsProvider.searchQuery}". Silakan coba kata kunci lain atau hapus pencarian.'
                  : 'Saat ini belum ada artikel pada kategori ${newsProvider.selectedCategory}.',
              onRefresh: isSearching
                  ? () {
                      _searchController.clear();
                      newsProvider.clearSearch();
                    }
                  : () => newsProvider.refresh(),
            ),
          )
        else ...[
          // 3. Breaking News Card (Hanya saat tidak sedang search)
          if (breakingArticle != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.gutter,
                vertical: AppTheme.spaceSm,
              ),
              child: _buildBreakingNewsCard(breakingArticle),
            ),

          // 4. Sorotan Utama (Featured News, hanya saat tidak search)
          if (featuredArticle != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.gutter,
                vertical: AppTheme.spaceSm,
              ),
              child: _buildFeaturedSection(featuredArticle),
            ),

          // 5. Berita Terkini Header
          if (latestArticles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.gutter,
                vertical: AppTheme.spaceSm,
              ),
              child: _buildLatestNewsHeader(
                isSearching ? 'Hasil Pencarian' : 'Berita Terkini',
              ),
            ),

          // 6. Daftar kartu berita
          if (latestArticles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
              child: Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: latestArticles.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppTheme.spaceSm),
                    itemBuilder: (context, index) {
                      final article = latestArticles[index];
                      final isBookmarked = bookmarkProvider.isBookmarked(
                        article,
                      );
                      return ArticleCard(
                        article: article,
                        isBookmarked: isBookmarked,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(article: article),
                            ),
                          );
                        },
                        onBookmarkTap: () {
                          bookmarkProvider.toggleBookmark(article);
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  /// Format tanggal ke dalam bahasa Indonesia (contoh: "Selasa, 10 November 2026").
  String _formatCurrentDate([DateTime? date]) {
    final dt = date ?? DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = days[(dt.weekday - 1).clamp(0, 6)];
    final monthName = months[(dt.month - 1).clamp(0, 11)];

    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  Widget _buildEditorialSubBar(NewsProvider newsProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.gutter,
        vertical: AppTheme.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrentDate(),
                    style: AppTheme.labelMd.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Breaking News',
                    style: AppTheme.bodySm.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'EDISI PAGI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          // Search box interaktif
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.outlineVariant, width: 0.5),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                newsProvider.setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari berita, tokoh, atau peristiwa...',
                hintStyle: AppTheme.bodySm.copyWith(color: AppTheme.outline),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppTheme.outline,
                ),
                suffixIcon: newsProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: AppTheme.outline,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          newsProvider.clearSearch();
                        },
                        tooltip: 'Hapus Pencarian',
                      )
                    : const Icon(
                        Icons.mic_none,
                        size: 18,
                        color: AppTheme.outline,
                      ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(NewsProvider newsProvider) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.gutter,
          vertical: 6,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.spaceSm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected =
              newsProvider.selectedCategory.toLowerCase() ==
              category.toLowerCase();

          return InkWell(
            onTap: () {
              newsProvider.setCategory(category);
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppTheme.onPrimary
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreakingNewsCard(Article article) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(article: article),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.onSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'BREAKING NEWS',
                        style: TextStyle(
                          color: AppTheme.onSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<BookmarkProvider>(
                  builder: (context, bookmarkProvider, child) {
                    final isBookmarked = bookmarkProvider.isBookmarked(article);
                    return InkWell(
                      onTap: () {
                        bookmarkProvider.toggleBookmark(article);
                      },
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: isBookmarked
                              ? AppTheme.secondary
                              : AppTheme.onPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: AppTheme.headlineSm.copyWith(
                          color: AppTheme.onPrimary,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${article.category ?? "Ekonomi"} • Oleh ${article.author ?? "Redaksi Utama"}',
                        style: const TextStyle(
                          color: AppTheme.onPrimaryContainer,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                if (article.urlToImage != null &&
                    article.urlToImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Image.network(
                      article.urlToImage!,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 76,
                        height: 76,
                        color: AppTheme.surfaceContainerHigh,
                        child: const Icon(Icons.image, color: Colors.white54),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            const Text('Sorotan Utama', style: AppTheme.headlineSm),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailScreen(article: article),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.outlineVariant, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.urlToImage != null &&
                    article.urlToImage!.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      article.urlToImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.surfaceContainer,
                        child: const Center(
                          child: Icon(Icons.image, color: AppTheme.outline),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category != null)
                        Text(
                          article.category!.toUpperCase(),
                          style: AppTheme.labelSm.copyWith(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        style: AppTheme.headlineSm.copyWith(fontSize: 18),
                      ),
                      if (article.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          article.description!,
                          style: AppTheme.bodySm,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppTheme.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            article.sourceName ?? 'NewsScope',
                            style: AppTheme.labelSm,
                          ),
                          Consumer<BookmarkProvider>(
                            builder: (context, bookmarkProvider, child) {
                              final isBookmarked = bookmarkProvider
                                  .isBookmarked(article);
                              return InkWell(
                                onTap: () {
                                  bookmarkProvider.toggleBookmark(article);
                                },
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 20,
                                    color: isBookmarked
                                        ? AppTheme.secondary
                                        : AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestNewsHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.onSurface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Text(title, style: AppTheme.headlineSm),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Urutkan: Terbaru',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppTheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
