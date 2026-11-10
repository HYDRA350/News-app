import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Article Model Parsing Tests', () {
    test('Berhasil mem-parsing JSON lengkap sesuai format NewsAPI', () {
      final jsonMap = {
        'source': {
          'id': 'antara',
          'name': 'Antara News',
        },
        'author': 'Budi Santoso',
        'title': 'Peluncuran Satelit Nusantara Berjalan Sukses',
        'description': 'Satelit komunikasi generasi terbaru berhasil mengorbit.',
        'url': 'https://example.com/satelit',
        'urlToImage': 'https://example.com/satelit.jpg',
        'publishedAt': '2025-02-25T10:00:00Z',
        'content': 'Satelit berhasil dilepaskan pada ketinggian 36.000 km...',
        'category': 'Teknologi',
      };

      final article = Article.fromJson(jsonMap);

      expect(article.title, 'Peluncuran Satelit Nusantara Berjalan Sukses');
      expect(article.sourceName, 'Antara News');
      expect(article.author, 'Budi Santoso');
      expect(article.description, 'Satelit komunikasi generasi terbaru berhasil mengorbit.');
      expect(article.url, 'https://example.com/satelit');
      expect(article.urlToImage, 'https://example.com/satelit.jpg');
      expect(article.publishedAt, '2025-02-25T10:00:00Z');
      expect(article.content, contains('36.000 km'));
      expect(article.category, 'Teknologi');
    });

    test('Berhasil menangani nested source bernilai null atau kosong', () {
      final jsonMap = {
        'source': null,
        'author': null,
        'title': 'Judul Berita Minimalis',
        'description': null,
        'url': null,
        'urlToImage': null,
        'publishedAt': null,
        'content': null,
      };

      final article = Article.fromJson(jsonMap);

      expect(article.title, 'Judul Berita Minimalis');
      expect(article.sourceName, isNull);
      expect(article.author, isNull);
      expect(article.description, isNull);
      expect(article.urlToImage, isNull);
    });

    test('Menangani source dengan id null tetapi memiliki name', () {
      final jsonMap = {
        'source': {
          'id': null,
          'name': 'Harian Kompas',
        },
        'title': 'Rekor Baru Pertumbuhan Ekonomi',
      };

      final article = Article.fromJson(jsonMap);

      expect(article.sourceName, 'Harian Kompas');
      expect(article.title, 'Rekor Baru Pertumbuhan Ekonomi');
    });

    test('Melemparkan FormatException jika title null atau kosong', () {
      final invalidJsonWithoutTitle = {
        'source': {'name': 'Sumber Berita'},
        'description': 'Deskripsi tanpa judul',
      };

      expect(
        () => Article.fromJson(invalidJsonWithoutTitle),
        throwsA(isA<FormatException>()),
      );

      final invalidJsonWithEmptyTitle = {
        'title': '   ',
        'description': 'Deskripsi judul spasi',
      };

      expect(
        () => Article.fromJson(invalidJsonWithEmptyTitle),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson menghasilkan struktur Map yang valid', () {
      const article = Article(
        title: 'Uji toJson',
        sourceName: 'NewsScope',
        author: 'Penulis',
        category: 'Bisnis',
      );

      final map = article.toJson();

      expect(map['title'], 'Uji toJson');
      expect((map['source'] as Map)['name'], 'NewsScope');
      expect(map['author'], 'Penulis');
      expect(map['category'], 'Bisnis');
    });

    test('Mem-parsing seluruh isi file assets/mock/articles.json tanpa error', () async {
      final jsonString = await rootBundle.loadString('assets/mock/articles.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(data['status'], 'ok');
      expect(data['articles'], isA<List>());

      final rawArticles = data['articles'] as List;
      expect(rawArticles, isNotEmpty);

      final articles = rawArticles
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(articles.length, equals(10));
      for (final article in articles) {
        expect(article.title.isNotEmpty, isTrue);
      }
    });
  });
}

