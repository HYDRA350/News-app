import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kumpulan widget tampilan untuk berbagai state pemuatan data:
/// - Loading state ([LoadingStateView])
/// - Error state dengan tombol coba lagi ([ErrorStateView])
/// - Empty state ketika tidak ada data ([EmptyStateView])
///
/// Seluruh tampilan mengikuti sistem desain `AppTheme` dan referensi Stitch.

/// Tampilan state saat proses memuat data sedang berlangsung.
class LoadingStateView extends StatelessWidget {
  final String message;

  const LoadingStateView({
    super.key,
    this.message = 'Memuat berita NewsScope...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.gutter),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              message,
              style: AppTheme.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan state saat terjadi kegagalan pemuatan data dengan tombol 'Coba Lagi'.
class ErrorStateView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            const Text(
              'Gagal Memuat Berita',
              style: AppTheme.headlineSm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              message ?? 'Terjadi gangguan jaringan atau kendala teknis. Silakan coba kembali.',
              style: AppTheme.bodySm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLg,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan state saat data berhasil diambil namun kosong.
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRefresh;

  const EmptyStateView({
    super.key,
    this.title = 'Belum Ada Berita',
    this.message = 'Saat ini belum ada artikel yang dapat ditampilkan. Silakan periksa kembali nanti.',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.newspaper_outlined,
                size: 32,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              title,
              style: AppTheme.headlineSm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              message,
              style: AppTheme.bodySm,
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: AppTheme.spaceLg),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Muat Ulang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

