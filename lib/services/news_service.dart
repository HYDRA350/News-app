import '../models/article.dart';

/// Abstraksi kontrak untuk layanan pengambilan berita.
///
/// Antarmuka ini memisahkan UI dan Provider dari sumber data konkret,
/// sehingga memudahkan pergantian antara [MockNewsService] (tahap 1)
/// dan [ApiNewsService] (tahap 2) tanpa mengubah kode UI.
abstract class NewsService {
  /// Mengambil daftar artikel berita.
  ///
  /// Mendukung parameter opsional:
  /// - [category]: memfilter artikel berdasarkan nama kategori (misal: "Bisnis", "Teknologi", dsb.).
  /// - [query]: mencari artikel berdasarkan kecocokan kata kunci pada judul atau deskripsi.
  Future<List<Article>> getArticles({
    String? category,
    String? query,
  });
}

