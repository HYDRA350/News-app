import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/services/api_news_service.dart';
import 'package:news_app/services/news_exception.dart';

/// Implementasi mock http.Client sederhana untuk pengujian unit tanpa request nyata.
class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('ApiNewsService Unit Tests', () {
    const testApiKey = 'valid_test_api_key_123';

    test(
      'Melemparkan NewsException jika API key belum diatur/kosong',
      () async {
        final service = ApiNewsService(
          apiKey: '',
          client: MockHttpClient((req) async => http.Response('{}', 200)),
        );

        expect(
          () => service.getArticles(),
          throwsA(
            isA<NewsException>().having(
              (e) => e.message,
              'message',
              contains('API key belum diatur'),
            ),
          ),
        );
      },
    );

    test(
      'Mengirim API key melalui header X-Api-Key dan URL query yang benar',
      () async {
        late http.BaseRequest capturedRequest;

        final mockClient = MockHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'status': 'ok',
              'totalResults': 1,
              'articles': [
                {
                  'source': {'id': null, 'name': 'CNN'},
                  'title': 'Test Article Headline',
                  'description': 'Test article description',
                  'url': 'https://example.com/test',
                  'publishedAt': '2025-02-25T10:00:00Z',
                },
              ],
            }),
            200,
          );
        });

        final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

        final articles = await service.getArticles(
          category: 'Bisnis',
          query: 'IHSG',
        );

        // Verifikasi header
        expect(capturedRequest.headers['X-Api-Key'], equals(testApiKey));

        // Verifikasi URI tidak memuat apiKey di query params
        final uri = capturedRequest.url;
        expect(uri.queryParameters.containsKey('apiKey'), isFalse);
        expect(uri.queryParameters['country'], equals('us'));
        expect(
          uri.queryParameters['category'],
          equals('business'),
        ); // Terpetakan dari 'Bisnis'
        expect(uri.queryParameters['q'], equals('IHSG'));

        // Verifikasi parsing hasil
        expect(articles.length, equals(1));
        expect(articles.first.title, equals('Test Article Headline'));
        expect(articles.first.sourceName, equals('CNN'));
      },
    );

    test(
      'Memastikan default parameter country adalah "us"',
      () async {
        late http.BaseRequest capturedRequest;

        final mockClient = MockHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'status': 'ok', 'articles': []}),
            200,
          );
        });

        final service = ApiNewsService(apiKey: testApiKey, client: mockClient);
        await service.getArticles();

        expect(capturedRequest.url.queryParameters['country'], equals('us'));
        expect(capturedRequest.url.queryParameters['pageSize'], equals('20'));
      },
    );

    test(
      'Kategori "Semua" tidak mengirim parameter category ke endpoint',
      () async {
        late http.BaseRequest capturedRequest;

        final mockClient = MockHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'status': 'ok', 'articles': []}),
            200,
          );
        });

        final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

        await service.getArticles(category: 'Semua');

        expect(
          capturedRequest.url.queryParameters.containsKey('category'),
          isFalse,
        );
      },
    );

    test(
      'Mengembalikan list kosong saat API mengembalikan 0 artikel',
      () async {
        final mockClient = MockHttpClient((request) async {
          return http.Response(
            jsonEncode({'status': 'ok', 'totalResults': 0, 'articles': []}),
            200,
          );
        });

        final service = ApiNewsService(apiKey: testApiKey, client: mockClient);
        final articles = await service.getArticles();

        expect(articles, isEmpty);
      },
    );

    test(
      'Menangani HTTP 400 Bad Request dengan NewsException yang sesuai',
      () async {
        final mockClient = MockHttpClient((request) async {
          return http.Response(
            '{"status": "error", "message": "parameterInvalid"}',
            400,
          );
        });

        final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

        expect(
          () => service.getArticles(),
          throwsA(
            isA<NewsException>().having(
              (e) => e.message,
              'message',
              contains('tidak valid'),
            ),
          ),
        );
      },
    );

    test('Menangani HTTP 401 Unauthorized (API key salah)', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response(
          '{"status": "error", "message": "apiKeyInvalid"}',
          401,
        );
      });

      final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

      expect(
        () => service.getArticles(),
        throwsA(
          isA<NewsException>().having(
            (e) => e.message,
            'message',
            contains('API key tidak valid'),
          ),
        ),
      );
    });

    test('Menangani HTTP 429 Too Many Requests (kuota habis)', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response(
          '{"status": "error", "message": "rateLimited"}',
          429,
        );
      });

      final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

      expect(
        () => service.getArticles(),
        throwsA(
          isA<NewsException>().having(
            (e) => e.message,
            'message',
            contains('Batas kuota harian'),
          ),
        ),
      );
    });

    test(
      'Menangani kegagalan jaringan / SocketException dengan pesan ramah',
      () async {
        final mockClient = MockHttpClient((request) async {
          throw const SocketException('Failed host lookup');
        });

        final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

        expect(
          () => service.getArticles(),
          throwsA(
            isA<NewsException>().having(
              (e) => e.message,
              'message',
              contains('Tidak ada koneksi internet'),
            ),
          ),
        );
      },
    );

    test('Menangani format JSON rusak dari server', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('bukan_json_valid_502_bad_gateway', 200);
      });

      final service = ApiNewsService(apiKey: testApiKey, client: mockClient);

      expect(
        () => service.getArticles(),
        throwsA(
          isA<NewsException>().having(
            (e) => e.message,
            'message',
            contains('Format respons dari server tidak valid'),
          ),
        ),
      );
    });
  });
}
