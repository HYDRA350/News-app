import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/bookmark_screen.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/screens/home_screen.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';

class TestMockNewsService implements NewsService {
  final List<Article> mockArticles;
  final bool shouldThrow;

  TestMockNewsService({this.mockArticles = const [], this.shouldThrow = false});

  @override
  Future<List<Article>> getArticles({String? category, String? query}) async {
    if (shouldThrow) {
      throw Exception('Gagal memuat berita');
    }
    var list = mockArticles;
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'semua') {
      list = list
          .where((a) => a.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((a) {
        final inTitle = a.title.toLowerCase().contains(q);
        final inDesc = a.description?.toLowerCase().contains(q) ?? false;
        return inTitle || inDesc;
      }).toList();
    }
    return list;
  }
}

Widget createHomeScreenWithProviders({
  required NewsService service,
  BookmarkProvider? bookmarkProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NewsProvider>(
        create: (_) => NewsProvider(newsService: service),
      ),
      ChangeNotifierProvider<BookmarkProvider>.value(
        value: bookmarkProvider ?? BookmarkProvider(),
      ),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen()),
  );
}

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('Menampilkan judul NewsScope dan header Beranda', (
      tester,
    ) async {
      final service = TestMockNewsService(
        mockArticles: [
          const Article(title: 'Berita 1', sourceName: 'Sumber 1'),
        ],
      );

      await tester.pumpWidget(createHomeScreenWithProviders(service: service));
      await tester.pumpAndSettle();

      expect(find.text('NewsScope'), findsWidgets);
      expect(find.text('BERANDA'), findsOneWidget);
      expect(find.text('Breaking News'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets(
      'Menampilkan Breaking News, Sorotan Utama, dan Berita Terkini saat data lengkap',
      (tester) async {
        final sampleArticles = [
          const Article(title: 'Breaking News Utama', category: 'Ekonomi'),
          const Article(
            title: 'Sorotan Utama Teknologi',
            category: 'Teknologi',
          ),
          const Article(title: 'Berita Terkini Pertama', category: 'Bisnis'),
        ];

        final service = TestMockNewsService(mockArticles: sampleArticles);

        await tester.pumpWidget(
          createHomeScreenWithProviders(service: service),
        );
        await tester.pumpAndSettle();

        expect(find.text('BREAKING NEWS'), findsOneWidget);
        expect(find.text('Breaking News Utama'), findsOneWidget);
        expect(find.text('Sorotan Utama'), findsOneWidget);
        expect(find.text('Sorotan Utama Teknologi'), findsOneWidget);
        expect(find.text('Berita Terkini'), findsOneWidget);
        expect(find.text('Berita Terkini Pertama'), findsOneWidget);
      },
    );

    testWidgets(
      'Pencarian artikel menyaring hasil dan menampilkan empty jika tidak cocok',
      (tester) async {
        final sampleArticles = [
          const Article(title: 'Pemerintah Energi Baru', category: 'Bisnis'),
          const Article(title: 'Robotik Manufaktur', category: 'Teknologi'),
        ];

        final service = TestMockNewsService(mockArticles: sampleArticles);

        await tester.pumpWidget(
          createHomeScreenWithProviders(service: service),
        );
        await tester.pumpAndSettle();

        // Masukkan kata kunci pencarian
        await tester.enterText(find.byType(TextField), 'Robotik');
        await tester.pumpAndSettle();

        expect(find.text('Robotik Manufaktur'), findsOneWidget);
        expect(find.text('Pemerintah Energi Baru'), findsNothing);

        // Cari kata kunci yang tidak ada
        await tester.enterText(find.byType(TextField), 'TidakAdaKunciIni');
        await tester.pumpAndSettle();

        expect(find.text('Berita Tidak Ditemukan'), findsOneWidget);
        expect(
          find.textContaining(
            'Tidak ditemukan berita dengan kata kunci "TidakAdaKunciIni"',
          ),
          findsOneWidget,
        );

        // Clear search via suffix icon button
        await tester.tap(find.byTooltip('Hapus Pencarian'));
        await tester.pumpAndSettle();

        expect(find.text('Pemerintah Energi Baru'), findsOneWidget);
      },
    );

    testWidgets(
      'Filter chip kategori menyaring artikel sesuai kategori yang ditekan',
      (tester) async {
        final sampleArticles = [
          const Article(title: 'Berita Bisnis A', category: 'Bisnis'),
          const Article(title: 'Berita Olahraga B', category: 'Olahraga'),
        ];

        final service = TestMockNewsService(mockArticles: sampleArticles);

        await tester.pumpWidget(
          createHomeScreenWithProviders(service: service),
        );
        await tester.pumpAndSettle();

        expect(find.text('Berita Bisnis A'), findsOneWidget);
        expect(find.text('Berita Olahraga B'), findsOneWidget);

        // Tap chip Olahraga
        await tester.tap(find.text('Olahraga'));
        await tester.pumpAndSettle();

        expect(find.text('Berita Olahraga B'), findsOneWidget);
        expect(find.text('Berita Bisnis A'), findsNothing);
      },
    );

    testWidgets('Navigasi dari kartu berita Beranda membuka DetailScreen', (
      tester,
    ) async {
      final sampleArticles = [
        const Article(title: 'Breaking News Utama'),
        const Article(title: 'Sorotan Utama'),
        const Article(
          title: 'Berita Terkini Buka Detail',
          content: 'Isi lengkap artikel berita terkini berhasil dibuka.',
        ),
      ];

      final service = TestMockNewsService(mockArticles: sampleArticles);

      await tester.pumpWidget(createHomeScreenWithProviders(service: service));
      await tester.pumpAndSettle();

      // Tap kartu berita terkini
      await tester.tap(find.text('Berita Terkini Buka Detail'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.text('Berita Terkini Buka Detail'), findsOneWidget);
      expect(
        find.textContaining(
          'Isi lengkap artikel berita terkini berhasil dibuka.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Sinkronisasi bookmark antara Beranda dan BookmarkScreen', (
      tester,
    ) async {
      final sampleArticles = [
        const Article(title: 'Breaking News Utama'),
        const Article(title: 'Sorotan Utama'),
        const Article(title: 'Berita Favorit Saya'),
      ];

      final service = TestMockNewsService(mockArticles: sampleArticles);
      final bookmarkProvider = BookmarkProvider();

      await tester.pumpWidget(
        createHomeScreenWithProviders(
          service: service,
          bookmarkProvider: bookmarkProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tombol bookmark pada kartu artikel terkini
      final cardBookmarkFinder = find.descendant(
        of: find.byType(ArticleCard),
        matching: find.byIcon(Icons.bookmark_border),
      );
      await tester.ensureVisible(cardBookmarkFinder);
      await tester.pumpAndSettle();

      await tester.tap(cardBookmarkFinder);
      await tester.pumpAndSettle();

      expect(bookmarkProvider.count, equals(1));
      expect(bookmarkProvider.isBookmarked(sampleArticles[2]), isTrue);

      // Buka BookmarkScreen dari AppBar
      await tester.tap(find.byTooltip('Berita Tersimpan'));
      await tester.pumpAndSettle();

      expect(find.byType(BookmarkScreen), findsOneWidget);
      expect(find.text('Berita Favorit Saya'), findsOneWidget);
    });

    testWidgets('Menampilkan ErrorStateView saat terjadi kegagalan pemuatan', (
      tester,
    ) async {
      final service = TestMockNewsService(shouldThrow: true);

      await tester.pumpWidget(createHomeScreenWithProviders(service: service));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('Menampilkan EmptyStateView saat data artikel kosong', (
      tester,
    ) async {
      final service = TestMockNewsService(mockArticles: []);

      await tester.pumpWidget(createHomeScreenWithProviders(service: service));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('Belum Ada Berita'), findsOneWidget);
    });
  });
}
