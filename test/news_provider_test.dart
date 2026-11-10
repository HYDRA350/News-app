import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/services/news_exception.dart';
import 'package:news_app/services/news_service.dart';

/// Mock service buatan khusus untuk pengujian terisolasi unit testing provider.
class FakeNewsService implements NewsService {
  final List<Article> mockArticles;
  final bool shouldThrow;
  final bool shouldThrowNewsException;

  FakeNewsService({
    this.mockArticles = const [],
    this.shouldThrow = false,
    this.shouldThrowNewsException = false,
  });

  @override
  Future<List<Article>> getArticles({String? category, String? query}) async {
    if (shouldThrowNewsException) {
      throw const NewsException('API key tidak valid atau kuota habis.');
    }
    if (shouldThrow) {
      throw Exception('Simulasi gagal memuat jaringan');
    }
    return mockArticles;
  }
}

void main() {
  group('NewsProvider Unit Tests', () {
    test('State awal provider adalah NewsStatus.initial', () {
      final service = FakeNewsService();
      final provider = NewsProvider(newsService: service);

      expect(provider.status, equals(NewsStatus.initial));
      expect(provider.articles, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('Memuat artikel dengan sukses mengubah status menjadi success', () async {
      final sampleArticles = [
        const Article(
          title: 'Judul Berita Uji',
          sourceName: 'NewsScope',
          category: 'Teknologi',
        ),
      ];

      final service = FakeNewsService(mockArticles: sampleArticles);
      final provider = NewsProvider(newsService: service);

      final future = provider.fetchNews();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.status, equals(NewsStatus.success));
      expect(provider.isSuccess, isTrue);
      expect(provider.articles.length, equals(1));
      expect(provider.articles.first.title, equals('Judul Berita Uji'));
    });

    test('Hasil kosong mengubah status menjadi NewsStatus.empty', () async {
      final service = FakeNewsService(mockArticles: []);
      final provider = NewsProvider(newsService: service);

      await provider.fetchNews();

      expect(provider.status, equals(NewsStatus.empty));
      expect(provider.isEmpty, isTrue);
      expect(provider.articles, isEmpty);
    });

    test('Menangani NewsException dengan menyimpan pesan error ramah pengguna', () async {
      final service = FakeNewsService(shouldThrowNewsException: true);
      final provider = NewsProvider(newsService: service);

      await provider.fetchNews();

      expect(provider.status, equals(NewsStatus.error));
      expect(provider.isError, isTrue);
      expect(provider.articles, isEmpty);
      expect(provider.errorMessage, equals('API key tidak valid atau kuota habis.'));
    });

    test('Kegagalan generic exception mengubah status menjadi NewsStatus.error', () async {
      final service = FakeNewsService(shouldThrow: true);
      final provider = NewsProvider(newsService: service);

      await provider.fetchNews();

      expect(provider.status, equals(NewsStatus.error));
      expect(provider.isError, isTrue);
      expect(provider.articles, isEmpty);
      expect(provider.errorMessage, contains('Simulasi gagal memuat jaringan'));
    });

    test('Method refresh memanggil kembali fetchNews setelah error', () async {
      var callCount = 0;
      final sampleArticles = [
        const Article(title: 'Berita Refresh Berhasil'),
      ];

      final dynamicService = _DynamicTestService(onCall: () {
        callCount++;
        if (callCount == 1) {
          throw const NewsException('Error pertama');
        }
        return sampleArticles;
      });

      final provider = NewsProvider(newsService: dynamicService);

      // Panggilan pertama gagal
      await provider.fetchNews();
      expect(provider.isError, isTrue);
      expect(provider.errorMessage, equals('Error pertama'));

      // Panggilan kedua via refresh berhasil
      await provider.refresh();
      expect(provider.isSuccess, isTrue);
      expect(provider.articles.length, equals(1));
      expect(provider.articles.first.title, equals('Berita Refresh Berhasil'));
    });
  });
}

class _DynamicTestService implements NewsService {
  final List<Article> Function() onCall;

  _DynamicTestService({required this.onCall});

  @override
  Future<List<Article>> getArticles({String? category, String? query}) async {
    return onCall();
  }
}
