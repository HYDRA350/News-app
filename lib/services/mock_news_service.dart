import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article.dart';
import 'news_service.dart';

/// Pilihan mode simulasi untuk pengujian state pada [MockNewsService].
enum MockServiceMode {
  /// Mengembalikan data normal dari JSON.
  success,

  /// Mensimulasikan hasil kosong (daftar kosong).
  empty,

  /// Mensimulasikan kegagalan / error jaringan.
  error,
}

/// Implementasi [NewsService] menggunakan file JSON lokal `assets/mock/articles.json`.
///
/// Layanan ini dilengkapi:
/// 1. Pembacaan asynchronous melalui `rootBundle`.
/// 2. Parsing JSON yang aman menggunakan `Article.fromJson`.
/// 3. Filter kategori dan pencarian kata kunci di memori.
/// 4. Jeda buatan (simulated latency) dan konfigurasi mode (sukses/kosong/error)
///    untuk keperluan pengujian state UI (FR-07).
class MockNewsService implements NewsService {
  final String assetPath;
  final Duration simulatedDelay;
  MockServiceMode mode;

  MockNewsService({
    this.assetPath = 'assets/mock/articles.json',
    this.simulatedDelay = const Duration(seconds: 1),
    this.mode = MockServiceMode.success,
  });

  @override
  Future<List<Article>> getArticles({
    String? category,
    String? query,
  }) async {
    // 1. Berikan jeda buatan untuk menyimulasikan proses asinkronus (network call)
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    // 2. Tangani simulasi error untuk pengujian error state
    if (mode == MockServiceMode.error) {
      throw Exception('Gagal memuat berita: Terjadi kesalahan pada simulasi layanan.');
    }

    // 3. Tangani simulasi empty untuk pengujian empty state
    if (mode == MockServiceMode.empty) {
      return <Article>[];
    }

    // 4. Muat berkas JSON dari asset bundle
    final String jsonString;
    try {
      jsonString = await rootBundle.loadString(assetPath);
    } catch (e) {
      throw Exception('Gagal membaca file mock data di path $assetPath: $e');
    }

    // 5. Dekode JSON dan konversi ke List<Article>
    final dynamic decodedData;
    try {
      decodedData = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('Format JSON tidak valid pada $assetPath: $e');
    }

    final List<dynamic> rawArticles;
    if (decodedData is Map<String, dynamic> && decodedData['articles'] is List) {
      rawArticles = decodedData['articles'] as List<dynamic>;
    } else if (decodedData is List) {
      rawArticles = decodedData;
    } else {
      throw const FormatException('Struktur JSON tidak memuat daftar artikel yang valid.');
    }

    List<Article> articles = rawArticles
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        .toList();

    // 6. Terapkan filter kategori jika disediakan dan bukan 'Semua'
    if (category != null && category.trim().isNotEmpty && category.trim().toLowerCase() != 'semua') {
      final normalizedCategory = category.trim().toLowerCase();
      articles = articles.where((article) {
        final articleCat = article.category?.toLowerCase() ?? '';
        return articleCat == normalizedCategory;
      }).toList();
    }

    // 7. Terapkan pencarian kata kunci pada judul atau deskripsi jika disediakan
    if (query != null && query.trim().isNotEmpty) {
      final normalizedQuery = query.trim().toLowerCase();
      articles = articles.where((article) {
        final titleMatch = article.title.toLowerCase().contains(normalizedQuery);
        final descMatch = article.description?.toLowerCase().contains(normalizedQuery) ?? false;
        return titleMatch || descMatch;
      }).toList();
    }

    return articles;
  }
}

