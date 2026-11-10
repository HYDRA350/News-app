import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/services/mock_news_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNewsService service;

  setUp(() {
    // Gunakan simulatedDelay Duration.zero pada unit testing agar pengujian berjalan instan
    service = MockNewsService(
      simulatedDelay: Duration.zero,
      mode: MockServiceMode.success,
    );
  });

  group('MockNewsService Tests', () {
    test('Berhasil memuat seluruh artikel dalam mode sukses', () async {
      final articles = await service.getArticles();

      expect(articles, isNotEmpty);
      expect(articles.length, equals(10));
      expect(articles.first.title.isNotEmpty, isTrue);
    });

    test('Memfilter artikel berdasarkan kategori spesifik', () async {
      final businessArticles = await service.getArticles(category: 'Bisnis');
      expect(businessArticles.length, equals(2));
      for (final article in businessArticles) {
        expect(article.category?.toLowerCase(), equals('bisnis'));
      }

      final techArticles = await service.getArticles(category: 'Teknologi');
      expect(techArticles.length, equals(2));
      for (final article in techArticles) {
        expect(article.category?.toLowerCase(), equals('teknologi'));
      }
    });

    test('Kategori "Semua" mengembalikan seluruh artikel', () async {
      final allArticles = await service.getArticles(category: 'Semua');
      expect(allArticles.length, equals(10));
    });

    test('Mencari artikel berdasarkan kata kunci pada judul', () async {
      final results = await service.getArticles(query: 'energi bersih');
      expect(results.length, equals(1));
      expect(results.first.title, contains('Energi Bersih'));
    });

    test('Mencari artikel berdasarkan kata kunci pada deskripsi', () async {
      // Kata 'manufaktur' ada di deskripsi berita IHSG dan 5G
      final results = await service.getArticles(query: 'manufaktur');
      expect(results.length, equals(2));
      for (final article in results) {
        final matchesTitle = article.title.toLowerCase().contains('manufaktur');
        final matchesDesc = article.description?.toLowerCase().contains('manufaktur') ?? false;
        expect(matchesTitle || matchesDesc, isTrue);
      }
    });

    test('Mengembalikan list kosong jika kata kunci pencarian tidak ditemukan', () async {
      final results = await service.getArticles(query: 'katakuncitidakadamungkin999');
      expect(results, isEmpty);
    });

    test('Kombinasi pencarian dan kategori bekerja bersamaan', () async {
      // Kategori Teknologi yang memiliki kata 'Bandung'
      final results = await service.getArticles(category: 'Teknologi', query: 'Bandung');
      expect(results.length, equals(1));
      expect(results.first.category, equals('Teknologi'));
      expect(results.first.title, contains('Bandung'));

      // Kategori Bisnis dengan kata 'Bandung' seharusnya kosong
      final emptyResults = await service.getArticles(category: 'Bisnis', query: 'Bandung');
      expect(emptyResults, isEmpty);
    });

    test('Simulasi mode empty mengembalikan daftar kosong', () async {
      service.mode = MockServiceMode.empty;
      final results = await service.getArticles();
      expect(results, isEmpty);
    });

    test('Simulasi mode error melempar exception', () async {
      service.mode = MockServiceMode.error;
      expect(() => service.getArticles(), throwsA(isA<Exception>()));
    });

    test('Melempar exception ketika asset file tidak ditemukan', () async {
      final invalidPathService = MockNewsService(
        assetPath: 'assets/mock/file_tidak_ada.json',
        simulatedDelay: Duration.zero,
      );

      expect(() => invalidPathService.getArticles(), throwsA(isA<Exception>()));
    });
  });
}

