import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';

void main() {
  group('BookmarkProvider Unit Tests', () {
    late BookmarkProvider provider;

    setUp(() {
      provider = BookmarkProvider();
    });

    test('Daftar bookmark awalnya kosong', () {
      expect(provider.bookmarkedArticles, isEmpty);
      expect(provider.count, equals(0));
      expect(provider.isEmpty, isTrue);
    });

    test('Menambah artikel menambahkan ke daftar bookmark', () {
      const article = Article(title: 'Berita Penting 1', url: 'https://example.com/1');

      provider.addBookmark(article);

      expect(provider.count, equals(1));
      expect(provider.isBookmarked(article), isTrue);
      expect(provider.bookmarkedArticles.first.title, equals('Berita Penting 1'));
    });

    test('Menambahkan artikel yang sama dua kali tidak menciptakan duplikat', () {
      const article1 = Article(title: 'Berita Sama', url: 'https://example.com/same');
      const article2 = Article(title: 'Berita Sama', url: 'https://example.com/same');

      provider.addBookmark(article1);
      provider.addBookmark(article2);

      expect(provider.count, equals(1));
    });

    test('Menghapus artikel berhasil menghilangkannya dari bookmark', () {
      const article = Article(title: 'Berita Dihapus', url: 'https://example.com/del');

      provider.addBookmark(article);
      expect(provider.isBookmarked(article), isTrue);

      provider.removeBookmark(article);
      expect(provider.count, equals(0));
      expect(provider.isBookmarked(article), isFalse);
    });

    test('toggleBookmark mengubah status secara bolak-balik', () {
      const article = Article(title: 'Berita Toggle', url: 'https://example.com/toggle');

      // 1. Simpan
      provider.toggleBookmark(article);
      expect(provider.isBookmarked(article), isTrue);
      expect(provider.count, equals(1));

      // 2. Hapus
      provider.toggleBookmark(article);
      expect(provider.isBookmarked(article), isFalse);
      expect(provider.count, equals(0));
    });

    test('isBookmarked mengembalikan hasil yang benar berdasarkan judul atau url', () {
      const articleA = Article(title: 'Judul A', url: 'https://example.com/a');
      const articleB = Article(title: 'Judul B', url: 'https://example.com/b');

      provider.addBookmark(articleA);

      expect(provider.isBookmarked(articleA), isTrue);
      expect(provider.isBookmarked(articleB), isFalse);
    });
  });
}

