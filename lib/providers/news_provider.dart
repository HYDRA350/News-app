import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_exception.dart';
import '../services/news_service.dart';

/// Enum yang merepresentasikan status pemuatan data berita.
enum NewsStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

/// Provider pengelola state berita untuk aplikasi.
///
/// Bertanggung jawab untuk:
/// - Mengambil artikel berita dari abstraksi [NewsService].
/// - Menyimpan daftar artikel saat ini.
/// - Mengelola kategori aktif ([selectedCategory]) dan kata kunci pencarian ([searchQuery]).
/// - Menyediakan status terpusat ([NewsStatus.loading], [NewsStatus.success],
///   [NewsStatus.empty], [NewsStatus.error]).
/// - Menyediakan pesan kesalahan yang ramah pengguna.
/// - Menangani pemuatan ulang (*refresh* / *retry*) tanpa membiarkan aplikasi crash.
class NewsProvider extends ChangeNotifier {
  final NewsService _newsService;

  NewsStatus _status = NewsStatus.initial;
  List<Article> _articles = const [];
  String? _errorMessage;

  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  NewsProvider({required NewsService newsService})
      // ignore: prefer_initializing_formals
      : _newsService = newsService;

  // ==========================================
  // GETTERS
  // ==========================================
  NewsStatus get status => _status;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  bool get isLoading => _status == NewsStatus.loading;
  bool get isSuccess => _status == NewsStatus.success;
  bool get isEmpty => _status == NewsStatus.empty;
  bool get isError => _status == NewsStatus.error;

  /// Memuat daftar artikel berita dari service dengan kategori dan pencarian saat ini.
  Future<void> fetchNews({
    String? category,
    String? query,
  }) async {
    if (category != null) {
      _selectedCategory = category;
    }
    if (query != null) {
      _searchQuery = query;
    }

    _status = NewsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _newsService.getArticles(
        category: _selectedCategory,
        query: _searchQuery,
      );

      _articles = results;
      if (results.isEmpty) {
        _status = NewsStatus.empty;
      } else {
        _status = NewsStatus.success;
      }
    } on NewsException catch (e) {
      _status = NewsStatus.error;
      _articles = const [];
      _errorMessage = e.message;
    } catch (e) {
      _status = NewsStatus.error;
      _articles = const [];
      _errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Terjadi kesalahan saat memuat berita. Silakan coba lagi.';
    } finally {
      notifyListeners();
    }
  }

  /// Mengatur kategori aktif dan memperbarui daftar berita.
  Future<void> setCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await fetchNews();
  }

  /// Mengatur kata kunci pencarian dan memperbarui daftar berita.
  Future<void> setSearchQuery(String query) async {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    await fetchNews();
  }

  /// Membersihkan kata kunci pencarian dan mengembalikan berita berdasarkan kategori aktif.
  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    await fetchNews();
  }

  /// Memuat ulang data berita saat ini (digunakan untuk Pull-to-Refresh & tombol Coba Lagi).
  Future<void> refresh() async {
    await fetchNews();
  }
}
