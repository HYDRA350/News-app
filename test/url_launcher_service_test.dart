import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/services/url_launcher_service.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  group('UrlLauncherService Unit Tests', () {
    test('isValidUrl memvalidasi URL web http dan https dengan benar', () {
      const service = UrlLauncherService();

      expect(service.isValidUrl('https://newsapi.org/article-1'), isTrue);
      expect(service.isValidUrl('http://example.com/news'), isTrue);
      expect(service.isValidUrl('  https://nusantarapost.id/berita  '), isTrue);

      // URL tidak valid atau skema non-web
      expect(service.isValidUrl(null), isFalse);
      expect(service.isValidUrl(''), isFalse);
      expect(service.isValidUrl('   '), isFalse);
      expect(service.isValidUrl('bukan-sebuah-url'), isFalse);
      expect(service.isValidUrl('ftp://files.example.com'), isFalse);
      expect(service.isValidUrl('http://'), isFalse);
    });

    test('openArticleUrl berhasil membuka URL valid dengan mode externalApplication', () async {
      Uri? capturedUri;
      LaunchMode? capturedMode;

      final service = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          capturedUri = uri;
          capturedMode = mode;
          return true;
        },
      );

      final result = await service.openArticleUrl('https://example.com/berita-terkini');

      expect(result, isTrue);
      expect(capturedUri, equals(Uri.parse('https://example.com/berita-terkini')));
      expect(capturedMode, equals(LaunchMode.externalApplication));
    });

    test('openArticleUrl mengembalikan false tanpa meluncurkan browser jika URL tidak valid', () async {
      var wasCalled = false;

      final service = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          wasCalled = true;
          return true;
        },
      );

      final resultEmpty = await service.openArticleUrl('');
      final resultNull = await service.openArticleUrl(null);
      final resultInvalid = await service.openArticleUrl('invalid-url-string');

      expect(resultEmpty, isFalse);
      expect(resultNull, isFalse);
      expect(resultInvalid, isFalse);
      expect(wasCalled, isFalse);
    });

    test('openArticleUrl mengembalikan false jika launchUrlFn mengembalikan false', () async {
      final service = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          return false;
        },
      );

      final result = await service.openArticleUrl('https://example.com/gagal-dibuka');
      expect(result, isFalse);
    });

    test('openArticleUrl aman dari crash saat launchUrlFn melempar exception', () async {
      final service = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          throw Exception('Platform channel error');
        },
      );

      final result = await service.openArticleUrl('https://example.com/error-platform');
      expect(result, isFalse);
    });
  });
}

