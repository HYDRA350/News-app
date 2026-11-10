import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/services/url_launcher_service.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

Widget createDetailScreenWithProvider({
  required Article article,
  BookmarkProvider? bookmarkProvider,
  UrlLauncherService? urlLauncherService,
}) {
  return ChangeNotifierProvider<BookmarkProvider>.value(
    value: bookmarkProvider ?? BookmarkProvider(),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: DetailScreen(
        article: article,
        urlLauncherService: urlLauncherService ?? const UrlLauncherService(),
      ),
    ),
  );
}

void main() {
  group('DetailScreen Widget Tests', () {
    testWidgets('Menampilkan judul, sumber, penulis, dan konten dengan benar', (tester) async {
      const sampleArticle = Article(
        title: 'Uji Coba Kereta Cepat Otonom Tahap II Dimulai',
        sourceName: 'NewsScope',
        author: 'Raditya Pratama',
        description: 'Efisiensi energi melonjak 34 persen di ibu kota baru.',
        content: 'Kementerian Perhubungan resmi memulai fase kedua uji dinamis sistem transportasi cepat otonom.',
        publishedAt: '2025-02-25T08:30:00Z',
        category: 'Teknologi',
      );

      await tester.pumpWidget(createDetailScreenWithProvider(article: sampleArticle));

      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.text('Uji Coba Kereta Cepat Otonom Tahap II Dimulai'), findsOneWidget);
      expect(find.text('Efisiensi energi melonjak 34 persen di ibu kota baru.'), findsOneWidget);
      expect(find.text('Oleh Raditya Pratama'), findsOneWidget);
      expect(find.text('NewsScope'), findsOneWidget);
      expect(find.text('TEKNOLOGI'), findsOneWidget);
      expect(find.textContaining('Kementerian Perhubungan resmi memulai fase kedua'), findsOneWidget);
    });

    testWidgets('Aman dari null values dan menampilkan placeholder yang wajar', (tester) async {
      const minimalArticle = Article(
        title: 'Judul Berita Minimalis',
        sourceName: null,
        author: null,
        description: null,
        content: null,
        urlToImage: null,
        publishedAt: null,
        category: null,
      );

      await tester.pumpWidget(createDetailScreenWithProvider(article: minimalArticle));

      // Tidak crash dan menampilkan judul wajib
      expect(find.text('Judul Berita Minimalis'), findsOneWidget);
      // Fallback author dan source default
      expect(find.text('Oleh Redaksi NewsScope'), findsOneWidget);
      expect(find.text('NewsScope'), findsOneWidget);
      // Placeholder gambar muncul
      expect(find.text('Foto berita tidak tersedia'), findsOneWidget);
    });

    testWidgets('Tombol bookmark di DetailScreen berfungsi toggle bookmark', (tester) async {
      final bookmarkProvider = BookmarkProvider();
      const sampleArticle = Article(
        title: 'Artikel Uji Bookmark Detail',
        sourceName: 'NewsScope',
      );

      await tester.pumpWidget(createDetailScreenWithProvider(
        article: sampleArticle,
        bookmarkProvider: bookmarkProvider,
      ));

      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

      // Simpan artikel
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pumpAndSettle();

      expect(bookmarkProvider.isBookmarked(sampleArticle), isTrue);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // Hapus artikel
      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('Tombol kembali memicu Navigator.pop', (tester) async {
      const sampleArticle = Article(title: 'Judul Navigasi');

      await tester.pumpWidget(
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DetailScreen(article: sampleArticle),
                        ),
                      );
                    },
                    child: const Text('Buka Detail'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Buka detail
      await tester.tap(find.text('Buka Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Berita'), findsOneWidget);

      // Tekan tombol kembali
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      // Kembali ke halaman awal
      expect(find.text('Buka Detail'), findsOneWidget);
      expect(find.text('Detail Berita'), findsNothing);
    });

    testWidgets('Menekan tombol Baca Selengkapnya dengan URL valid memicu URL launcher', (tester) async {
      String? launchedUrl;
      final mockLauncher = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          launchedUrl = uri.toString();
          return true;
        },
      );

      const sampleArticle = Article(
        title: 'Artikel Tautan Valid',
        url: 'https://newsapi.org/berita/artikel-1',
      );

      await tester.pumpWidget(createDetailScreenWithProvider(
        article: sampleArticle,
        urlLauncherService: mockLauncher,
      ));

      // Scroll hingga tombol terlihat
      final readMoreFinder = find.text('Baca Selengkapnya');
      await tester.ensureVisible(readMoreFinder);
      await tester.pumpAndSettle();

      await tester.tap(readMoreFinder);
      await tester.pumpAndSettle();

      expect(launchedUrl, equals('https://newsapi.org/berita/artikel-1'));
    });

    testWidgets('Menekan tombol Baca Selengkapnya saat URL null/kosong menampilkan SnackBar peringatan', (tester) async {
      var wasCalled = false;
      final mockLauncher = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          wasCalled = true;
          return true;
        },
      );

      const sampleArticle = Article(
        title: 'Artikel Tanpa URL',
        url: null,
      );

      await tester.pumpWidget(createDetailScreenWithProvider(
        article: sampleArticle,
        urlLauncherService: mockLauncher,
      ));

      final readMoreFinder = find.text('Baca Selengkapnya');
      await tester.ensureVisible(readMoreFinder);
      await tester.pumpAndSettle();

      await tester.tap(readMoreFinder);
      await tester.pumpAndSettle();

      expect(wasCalled, isFalse);
      expect(find.text('Tautan artikel tidak tersedia atau tidak valid.'), findsOneWidget);
    });

    testWidgets('Menekan tombol Baca Selengkapnya saat peluncuran gagal menampilkan SnackBar error', (tester) async {
      final mockLauncher = UrlLauncherService(
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          return false;
        },
      );

      const sampleArticle = Article(
        title: 'Artikel Peluncuran Gagal',
        url: 'https://newsapi.org/gagal',
      );

      await tester.pumpWidget(createDetailScreenWithProvider(
        article: sampleArticle,
        urlLauncherService: mockLauncher,
      ));

      final readMoreFinder = find.text('Baca Selengkapnya');
      await tester.ensureVisible(readMoreFinder);
      await tester.pumpAndSettle();

      await tester.tap(readMoreFinder);
      await tester.pumpAndSettle();

      expect(find.text('Gagal membuka tautan artikel. Silakan coba beberapa saat lagi.'), findsOneWidget);
    });
  });
}
