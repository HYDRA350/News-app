import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

/// Halaman Berita Tersimpan (Bookmark Screen) NewsScope.
///
/// Mengikuti referensi Stitch `berita_tersimpan.html`:
/// - Header editorial dengan jumlah koleksi artikel tersimpan.
/// - Menampilkan daftar artikel yang disimpan di memori melalui [BookmarkProvider].
/// - Menggunakan [ArticleCard] yang konsisten dengan ikon status tersimpan.
/// - Menekan kartu membuka [DetailScreen].
/// - Menekan ikon bookmark langsung menghapus artikel dari daftar.
/// - Menampilkan [EmptyStateView] ketika belum ada artikel yang disimpan.
class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          final bookmarks = bookmarkProvider.bookmarkedArticles;

          if (bookmarks.isEmpty) {
            return const EmptyStateView(
              title: 'Belum Ada Berita Tersimpan',
              message:
                  'Tandai artikel menarik dengan ikon bookmark di Beranda atau Detail untuk membacanya kembali di sini.',
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppTheme.space2Xl),
            children: [
              // Header ringkasan koleksi artikel tersimpan
              _buildHeaderSection(bookmarks.length),

              // Daftar artikel tersimpan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spaceSm),
                  itemBuilder: (context, index) {
                    final article = bookmarks[index];
                    return ArticleCard(
                      article: article,
                      isBookmarked: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(article: article),
                          ),
                        );
                      },
                      onBookmarkTap: () {
                        bookmarkProvider.removeBookmark(article);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Artikel dihapus dari simpanan.'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'Urungkan',
                              textColor: AppTheme.secondary,
                              onPressed: () {
                                bookmarkProvider.addBookmark(article);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 24),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Kembali',
      ),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.asset(
              'assets/images/newsscope_logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 30,
                height: 30,
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
                      fontSize: 12,
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
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'BOOKMARK',
                style: AppTheme.labelSm.copyWith(
                  letterSpacing: 1.0,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppTheme.outlineVariant,
          height: 0.5,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(int totalArticles) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.gutter,
        vertical: AppTheme.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done_outlined, size: 16, color: AppTheme.secondary),
              const SizedBox(width: 6),
              Text(
                'ARSIP MEMORI AKTIF',
                style: AppTheme.labelSm.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Berita Tersimpan',
            style: AppTheme.headlineMd,
          ),
          const SizedBox(height: 4),
          Text(
            'Koleksi $totalArticles artikel yang Anda simpan untuk dibaca kembali kapan saja.',
            style: AppTheme.bodySm,
          ),
        ],
      ),
    );
  }
}
