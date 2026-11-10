import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/services/news_service.dart';

class MockTestNewsService implements NewsService {
  final List<Article> sampleArticles = const [
    Article(
      title: 'Regulasi Energi Bersih Nasional',
      description: 'Pemerintah dorong bauran energi baru terbarukan',
      category: 'Bisnis',
    ),
    Article(
      title: 'IHSG Ditutup Menguat',
      description: 'Saham perbankan melonjak tajam',
      category: 'Bisnis',
    ),
    Article(
      title: 'Kereta Cepat Otonom IKN',
      description: 'Uji dinamis hemat energi 34%',
      category: 'Teknologi',
    ),
    Article(
      title: 'Timnas Sepak Bola Juara',
      description: 'Kemenangan kualifikasi di GBK',
      category: 'Olahraga',
    ),
  ];

  @override
  Future<List<Article>> getArticles({String? category, String? query}) async {
    var results = sampleArticles;

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'semua') {
      results = results.where((a) => a.category?.toLowerCase() == category.toLowerCase()).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((a) {
        final inTitle = a.title.toLowerCase().contains(q);
        final inDesc = a.description?.toLowerCase().contains(q) ?? false;
        return inTitle || inDesc;
      }).toList();
    }

    return results;
  }
}

void main() {
  group('NewsProvider Search and Category Tests', () {
    late NewsProvider provider;

    setUp(() {
      provider = NewsProvider(newsService: MockTestNewsService());
    });

    test('Initial category adalah "Semua" dan query pencarian kosong', () {
      expect(provider.selectedCategory, equals('Semua'));
      expect(provider.searchQuery, isEmpty);
    });

    test('Mengganti kategori memfilter artikel', () async {
      await provider.setCategory('Bisnis');

      expect(provider.selectedCategory, equals('Bisnis'));
      expect(provider.articles.length, equals(2));
      for (final a in provider.articles) {
        expect(a.category, equals('Bisnis'));
      }
    });

    test('Pencarian kata kunci menyaring berdasarkan judul dan deskripsi', () async {
      await provider.setSearchQuery('IHSG');
      expect(provider.articles.length, equals(1));
      expect(provider.articles.first.title, contains('IHSG'));

      // Mencari di deskripsi
      await provider.setSearchQuery('GBK');
      expect(provider.articles.length, equals(1));
      expect(provider.articles.first.title, contains('Timnas'));
    });

    test('Kombinasi pencarian dan kategori bekerja bersama', () async {
      await provider.setCategory('Bisnis');
      await provider.setSearchQuery('Energi');

      expect(provider.selectedCategory, equals('Bisnis'));
      expect(provider.searchQuery, equals('Energi'));
      expect(provider.articles.length, equals(1));
      expect(provider.articles.first.title, contains('Energi Bersih'));

      // Mencari kata kunci Teknologi saat kategori Bisnis aktif menghasilkan empty
      await provider.setSearchQuery('Otonom');
      expect(provider.articles, isEmpty);
      expect(provider.isEmpty, isTrue);
    });

    test('Membersihkan pencarian mempertahankan kategori aktif', () async {
      await provider.setCategory('Bisnis');
      await provider.setSearchQuery('Energi');
      expect(provider.articles.length, equals(1));

      await provider.clearSearch();
      expect(provider.searchQuery, isEmpty);
      expect(provider.selectedCategory, equals('Bisnis'));
      expect(provider.articles.length, equals(2));
    });
  });
}

