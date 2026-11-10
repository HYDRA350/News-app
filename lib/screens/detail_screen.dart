import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../services/url_launcher_service.dart';
import '../theme/app_theme.dart';

/// Halaman Detail Berita (Article Detail Screen) NewsScope.
///
/// Mengikuti referensi Stitch `detail_berita.html`:
/// - Top bar editorial dengan tombol kembali, judul layar, dan tombol bagikan (placeholder).
/// - Top action toolbar: label kategori, pengubah ukuran teks visual, TTS visual, dan tombol bookmark visual.
/// - Judul berita editorial (Headline) & deskripsi ringkasan.
/// - Byline editorial box: inisial avatar penulis, nama penulis, nama sumber berita, dan tanggal publikasi.
/// - Cover image artikel dengan rasio konsisten (16:10) dan penanganan placeholder jika gambar null atau gagal dimuat.
/// - Isi berita (content) atau cuplikan berita.
/// - Tombol "Baca Selengkapnya" (dinonaktifkan secara rapi pada tahap Front End).
class DetailScreen extends StatefulWidget {
  final Article article;
  final UrlLauncherService urlLauncherService;

  const DetailScreen({
    super.key,
    required this.article,
    this.urlLauncherService = const UrlLauncherService(),
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Skala ukuran font untuk pembaca (fitur visual sesuai desain Stitch)
  double _fontScale = 1.0;

  void _cycleFontScale() {
    setState(() {
      if (_fontScale == 1.0) {
        _fontScale = 1.15;
      } else if (_fontScale == 1.15) {
        _fontScale = 1.3;
      } else {
        _fontScale = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppTheme.space2Xl),
          children: [
            // 1. Reading progress bar visual (merah sekunder di bagian atas)
            Container(
              height: 3.0,
              width: double.infinity,
              color: AppTheme.surfaceContainer,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.35, // Progress visual indikator
                child: Container(color: AppTheme.secondary),
              ),
            ),

            // 2. Action Toolbar: Kategori & Tombol Utilitas (Font, TTS, Bookmark)
            _buildActionToolbar(article),

            // 3. Konten Utama Artikel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spaceSm),

                  // Judul Berita Utama (Headline)
                  Text(
                    article.title,
                    style: AppTheme.headlineLg.copyWith(
                      fontSize: 24.0 * _fontScale,
                      height: 1.25,
                    ),
                  ),

                  // Deskripsi Ringkasan (jika tersedia)
                  if (article.description != null && article.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      article.description!,
                      style: AppTheme.bodyMd.copyWith(
                        fontSize: 15.0 * _fontScale,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppTheme.spaceMd),

                  // 4. Byline & Editorial Metadata Box
                  _buildBylineBox(article),

                  const SizedBox(height: AppTheme.spaceLg),

                  // 5. Gambar Sampul Berita (Lead Photo)
                  _buildCoverImage(article),

                  const SizedBox(height: AppTheme.spaceLg),

                  // 6. Isi Berita (Content)
                  _buildArticleBody(article),

                  const SizedBox(height: AppTheme.spaceLg),

                  // 7. Tombol Baca Selengkapnya (dinonaktifkan pada tahap Front End)
                  _buildReadMoreButton(article),
                ],
              ),
            ),
          ],
        ),
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
      title: const Text(
        'Detail Berita',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur berbagi akan tersedia pada pembaruan mendatang.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Bagikan',
        ),
        const SizedBox(width: AppTheme.spaceSm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppTheme.outlineVariant,
          height: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionToolbar(Article article) {
    final categoryText = (article.category != null && article.category!.trim().isNotEmpty)
        ? article.category!.toUpperCase()
        : (article.sourceName != null && article.sourceName!.trim().isNotEmpty)
            ? article.sourceName!.toUpperCase()
            : 'BERITA';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.gutter,
        vertical: AppTheme.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Badge Kategori
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                categoryText,
                style: AppTheme.labelSm.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),

          // Tombol Utilitas Pembaca
          Row(
            children: [
              // Pengubah ukuran teks visual
              InkWell(
                onTap: _cycleFontScale,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Center(
                    child: Text(
                      'AA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Tombol Bookmark Terhubung ke BookmarkProvider
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProvider, child) {
                  final isBookmarked = bookmarkProvider.isBookmarked(article);
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: isBookmarked ? AppTheme.secondary : AppTheme.onSurface,
                      ),
                      onPressed: () {
                        bookmarkProvider.toggleBookmark(article);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked
                                  ? 'Artikel dihapus dari simpanan.'
                                  : 'Artikel berhasil disimpan ke bookmark.',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: isBookmarked ? 'Hapus Simpanan' : 'Simpan Artikel',
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBylineBox(Article article) {
    final authorName = (article.author != null && article.author!.trim().isNotEmpty)
        ? article.author!
        : 'Redaksi NewsScope';

    final sourceName = (article.sourceName != null && article.sourceName!.trim().isNotEmpty)
        ? article.sourceName!
        : 'NewsScope';

    final dateText = _formatPublishedDate(article.publishedAt);

    // Ambil inisial penulis untuk avatar
    final initials = _getInitials(authorName);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppTheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oleh $authorName',
                      style: AppTheme.labelLg.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sourceName,
                      style: AppTheme.labelSm.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          const Divider(height: 1, thickness: 0.5, color: AppTheme.outlineVariant),
          const SizedBox(height: AppTheme.spaceSm),
          Wrap(
            spacing: AppTheme.spaceMd,
            runSpacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    dateText,
                    style: AppTheme.labelSm.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Waktu baca: 3 menit',
                    style: AppTheme.labelSm.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(Article article) {
    final imageUrl = article.urlToImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: (imageUrl == null || imageUrl.trim().isEmpty)
                ? _buildImagePlaceholder()
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppTheme.surfaceContainer,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Foto liputan dan dokumentasi jurnalisme NewsScope.',
          style: AppTheme.bodySm.copyWith(
            fontStyle: FontStyle.italic,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.surfaceContainer,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: AppTheme.outline,
            ),
            SizedBox(height: 6),
            Text(
              'Foto berita tidak tersedia',
              style: TextStyle(fontSize: 12, color: AppTheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleBody(Article article) {
    final content = (article.content != null && article.content!.trim().isNotEmpty)
        ? article.content!
        : (article.description != null && article.description!.trim().isNotEmpty)
            ? article.description!
            : 'Belum ada isi artikel lengkap yang dapat ditampilkan untuk berita ini.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: AppTheme.bodyLg.copyWith(
            fontSize: 17.0 * _fontScale,
            height: 1.7,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        // Kutipan editorial visual khas Stitch
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: const Border(
              left: BorderSide(color: AppTheme.secondary, width: 4.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“Kredibilitas jurnalisme bermula dari akurasi fakta dan keberpihakan pada kepentingan publik.”',
                style: AppTheme.headlineSm.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 15 * _fontScale,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '— Pedoman Redaksi NewsScope',
                style: AppTheme.labelSm.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadMoreButton(Article article) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppTheme.spaceMd),
      child: OutlinedButton.icon(
        onPressed: () => _handleOpenArticle(article.url),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: const Text('Baca Selengkapnya'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOpenArticle(String? url) async {
    if (!widget.urlLauncherService.isValidUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan artikel tidak tersedia atau tidak valid.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await widget.urlLauncherService.openArticleUrl(url);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka tautan artikel. Silakan coba beberapa saat lagi.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatPublishedDate(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) {
      return 'Hari ini';
    }
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'NS';
  }
}

