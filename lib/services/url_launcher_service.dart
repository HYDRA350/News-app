import 'package:url_launcher/url_launcher.dart';

/// Service untuk menangani peluncuran tautan artikel ke aplikasi browser eksternal.
///
/// Bertanggung jawab untuk:
/// - Memvalidasi format URL sebelum dieksekusi (skema http/https dan host valid).
/// - Menjalankan [launchUrl] dengan mode [LaunchMode.externalApplication].
/// - Menangani kegagalan peluncuran atau exception secara aman tanpa membuat aplikasi crash.
/// - Memungkinkan injeksi fungsi peluncur [launchUrlFn] untuk kemudahan pengujian terisolasi.
class UrlLauncherService {
  final Future<bool> Function(Uri url, {LaunchMode mode}) launchUrlFn;

  const UrlLauncherService({
    this.launchUrlFn = launchUrl,
  });

  /// Memeriksa apakah [urlString] merupakan URL web yang valid dan dapat dibuka.
  bool isValidUrl(String? urlString) {
    if (urlString == null) return false;
    final trimmed = urlString.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;

    // Pastikan skema adalah http atau https dan memiliki host yang valid
    final scheme = uri.scheme.toLowerCase();
    return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
  }

  /// Membuka tautan artikel pada browser eksternal pengguna.
  ///
  /// Mengembalikan `true` jika tautan berhasil dibuka, atau `false` jika:
  /// - URL kosong / tidak valid.
  /// - Browser eksternal gagal meluncurkan tautan.
  /// - Terjadi exception saat proses peluncuran.
  Future<bool> openArticleUrl(String? urlString) async {
    if (!isValidUrl(urlString)) {
      return false;
    }

    try {
      final uri = Uri.parse(urlString!.trim());
      return await launchUrlFn(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Cegah exception dari platform channel membuat aplikasi crash
      return false;
    }
  }
}
