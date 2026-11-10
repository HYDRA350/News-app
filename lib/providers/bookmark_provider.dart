import 'package:flutter/foundation.dart';
import '../models/article.dart';

/// Provider pengelola daftar artikel berita yang disimpan (bookmark) di memori.
///
/// Bertanggung jawab untuk:
/// - Menyimpan daftar artikel yang ditandai sebagai favorit dalam memori (in-memory).
/// - Memeriksa apakah suatu artikel sudah tersimpan ([isBookmarked]).
/// - Menambah ([addBookmark]), menghapus ([removeBookmark]), atau membalik status ([toggleBookmark]).
/// - Mencegah penambahan artikel duplikat (menggunakan perbandingan judul dan URL).
/// - Memberitahu seluruh listener secara reaktif saat ada perubahan status.
class BookmarkProvider extends ChangeNotifier {
  final List<Article> _bookmarkedArticles = [];

  /// Daftar artikel tersimpan saat ini (unmodifiable view agar tidak termutasi sembarangan).
  List<Article> get bookmarkedArticles => List.unmodifiable(_bookmarkedArticles);

  /// Jumlah artikel tersimpan.
  int get count => _bookmarkedArticles.length;

  /// Apakah daftar bookmark masih kosong.
  bool get isEmpty => _bookmarkedArticles.isEmpty;

  /// Memeriksa apakah [article] sudah ada di dalam bookmark.
  bool isBookmarked(Article article) {
    return _bookmarkedArticles.any((item) => _isSameArticle(item, article));
  }

  /// Menambahkan artikel ke dalam bookmark jika belum ada (mencegah duplikat).
  void addBookmark(Article article) {
    if (!isBookmarked(article)) {
      _bookmarkedArticles.insert(0, article);
      notifyListeners();
    }
  }

  /// Menghapus artikel dari bookmark.
  void removeBookmark(Article article) {
    final index = _bookmarkedArticles.indexWhere((item) => _isSameArticle(item, article));
    if (index != -1) {
      _bookmarkedArticles.removeAt(index);
      notifyListeners();
    }
  }

  /// Membalik status bookmark suatu artikel (tambah jika belum ada, hapus jika sudah ada).
  void toggleBookmark(Article article) {
    if (isBookmarked(article)) {
      removeBookmark(article);
    } else {
      addBookmark(article);
    }
  }

  /// Menghapus semua artikel dari bookmark (opsional untuk batch clear).
  void clearBookmarks() {
    if (_bookmarkedArticles.isNotEmpty) {
      _bookmarkedArticles.clear();
      notifyListeners();
    }
  }

  /// Helper untuk membandingkan kesamaan dua artikel berdasarkan url atau judul.
  bool _isSameArticle(Article a, Article b) {
    if (a.url != null && b.url != null && a.url!.isNotEmpty && b.url!.isNotEmpty) {
      return a.url == b.url;
    }
    return a.title == b.title;
  }
}

