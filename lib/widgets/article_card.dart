import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

/// Kartu artikel yang dapat dipakai ulang di berbagai halaman.
///
/// Mengikuti spesifikasi visual Stitch:
/// - Tata letak horizontal: Teks judul, kategori, waktu di sisi kiri; Thumbnail gambar di sisi kanan.
/// - Border radius halus (8px), warna container lowest (putih/bersih), dan border tipis.
/// - Indikator placeholder jika gambar null atau gagal dimuat.
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onBookmarkTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.outlineVariant, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten teks artikel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Label kategori (jika tersedia) atau nama sumber
                  if (article.category != null && article.category!.isNotEmpty)
                    Text(
                      article.category!.toUpperCase(),
                      style: AppTheme.labelSm.copyWith(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    )
                  else if (article.sourceName != null && article.sourceName!.isNotEmpty)
                    Text(
                      article.sourceName!.toUpperCase(),
                      style: AppTheme.labelSm.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: AppTheme.spaceXs),

                  // Judul berita
                  Text(
                    article.title,
                    style: AppTheme.headlineSm.copyWith(fontSize: 15.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),

                  // Metadata baris bawah: waktu & sumber
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _buildSubtitle(),
                          style: AppTheme.labelSm.copyWith(
                            color: AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Tombol bookmark (UI placeholder sampai tahap bookmark di Langkah 6)
                      InkWell(
                        onTap: onBookmarkTap,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            size: 18,
                            color: isBookmarked ? AppTheme.primary : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),

            // Thumbnail gambar di sebelah kanan (88x88 px)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: SizedBox(
                width: 88,
                height: 88,
                child: _buildImage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (article.sourceName != null && article.sourceName!.isNotEmpty) {
      parts.add(article.sourceName!);
    }
    if (article.publishedAt != null && article.publishedAt!.isNotEmpty) {
      parts.add(_formatDate(article.publishedAt!));
    }
    return parts.isEmpty ? 'NewsScope' : parts.join(' • ');
  }

  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildImage() {
    final imageUrl = article.urlToImage;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppTheme.surfaceContainer,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.surfaceContainer,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.outline,
          size: 24,
        ),
      ),
    );
  }
}

