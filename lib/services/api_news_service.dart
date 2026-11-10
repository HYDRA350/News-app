import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/article.dart';
import 'news_exception.dart';
import 'news_service.dart';

/// Implementasi [NewsService] yang mengambil berita langsung dari REST API NewsAPI.org.
///
/// Fitur utama:
/// 1. Mengambil data dari endpoint `https://newsapi.org/v2/top-headlines`.
/// 2. Membaca API key secara aman melalui `String.fromEnvironment('NEWS_API_KEY')`.
/// 3. Mengirim API key melalui header `X-Api-Key` (bukan query parameter).
/// 4. Memetakan kategori aplikasi (Bahasa Indonesia) ke parameter NewsAPI (Bahasa Inggris).
/// 5. Mendukung timeout 10 detik dan injeksi [http.Client] untuk kemudahan pengujian.
/// 6. Mengubah kegagalan jaringan dan status HTTP menjadi pesan [NewsException] yang ramah pengguna.
class ApiNewsService implements NewsService {
  final http.Client _client;
  final String _apiKey;

  /// Default constructor membaca API key dari environment flag compile-time.
  ApiNewsService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? const String.fromEnvironment('NEWS_API_KEY');

  /// Pemetaan kategori aplikasi ke parameter yang didukung oleh NewsAPI.org.
  static const Map<String, String> _categoryMap = {
    'bisnis': 'business',
    'olahraga': 'sports',
    'teknologi': 'technology',
    'hiburan': 'entertainment',
    'kesehatan': 'health',
  };

  @override
  Future<List<Article>> getArticles({String? category, String? query}) async {
    // 1. Validasi keberadaan API key
    if (_apiKey.trim().isEmpty) {
      throw const NewsException(
        'API key belum diatur. Jalankan aplikasi menggunakan --dart-define-from-file=env.json',
      );
    }

    // 2. Susun parameter query secara aman
    final queryParams = <String, String>{'country': 'us', 'pageSize': '20'};

    // Pemetaan kategori
    if (category != null &&
        category.trim().isNotEmpty &&
        category.trim().toLowerCase() != 'semua') {
      final normalizedCat = category.trim().toLowerCase();
      final mappedCategory = _categoryMap[normalizedCat];
      if (mappedCategory != null) {
        queryParams['category'] = mappedCategory;
      }
    }

    // Pemetaan pencarian kata kunci
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }

    final uri = Uri.https('newsapi.org', '/v2/top-headlines', queryParams);

    // 3. Eksekusi HTTP GET request dengan timeout 10 detik
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'X-Api-Key': _apiKey})
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const NewsException(
        'Koneksi waktu habis (timeout). Periksa jaringan internet Anda.',
      );
    } on SocketException {
      throw const NewsException(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on http.ClientException {
      throw const NewsException(
        'Gagal menghubungi server berita. Periksa jaringan Anda.',
      );
    } catch (e) {
      throw NewsException('Terjadi gangguan jaringan: $e');
    }

    // 4. Periksa status code HTTP
    if (response.statusCode != 200) {
      throw NewsException(
        _mapStatusCodeToMessage(response.statusCode, response.body),
      );
    }

    // 5. Dekode dan parsing JSON
    final dynamic decodedData;
    try {
      decodedData = jsonDecode(response.body);
    } catch (_) {
      throw const NewsException('Format respons dari server tidak valid.');
    }

    if (decodedData is! Map<String, dynamic>) {
      throw const NewsException('Struktur respons server tidak sesuai.');
    }

    // Periksa status respons dari payload NewsAPI jika ada
    if (decodedData['status'] == 'error') {
      final message = decodedData['message'] as String?;
      throw NewsException(
        message ?? 'Terjadi kesalahan dari penyedia berita NewsAPI.',
      );
    }

    final rawArticles = decodedData['articles'];
    if (rawArticles is! List) {
      return <Article>[];
    }

    // 6. Konversi ke List<Article> menggunakan Article.fromJson
    final articles = <Article>[];
    for (final item in rawArticles) {
      if (item is Map<String, dynamic>) {
        try {
          articles.add(Article.fromJson(item));
        } catch (_) {
          // Lewatkan artikel yang tidak memiliki field wajib (misal title null)
        }
      }
    }

    return articles;
  }

  /// Memetakan kode status HTTP ke pesan bahasa Indonesia yang ramah pengguna.
  static String _mapStatusCodeToMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return 'Permintaan berita tidak valid. Periksa parameter pencarian Anda.';
      case 401:
        return 'API key tidak valid atau tidak diizinkan. Periksa konfigurasi env.json.';
      case 429:
        return 'Batas kuota harian permintaan berita (100 request) telah tercapai. Coba lagi nanti.';
      case 500:
      case 502:
      case 503:
        return 'Server NewsAPI sedang mengalami gangguan. Silakan coba kembali beberapa saat lagi.';
      default:
        return 'Gagal memuat berita dari server (kode $statusCode). Silakan coba lagi.';
    }
  }
}
