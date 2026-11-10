import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/bookmark_screen.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/state_views.dart';

Widget createBookmarkScreenWithProvider(BookmarkProvider provider) {
  return ChangeNotifierProvider<BookmarkProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const BookmarkScreen(),
    ),
  );
}

void main() {
  group('BookmarkScreen Widget Tests', () {
    testWidgets('Menampilkan EmptyStateView ketika belum ada artikel tersimpan', (tester) async {
      final provider = BookmarkProvider();

      await tester.pumpWidget(createBookmarkScreenWithProvider(provider));

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('Belum Ada Berita Tersimpan'), findsOneWidget);
      expect(find.textContaining('Tandai artikel menarik dengan ikon bookmark'), findsOneWidget);
    });

    testWidgets('Menampilkan daftar artikel tersimpan saat bookmark tidak kosong', (tester) async {
      final provider = BookmarkProvider();
      provider.addBookmark(
        const Article(
          title: 'Berita Favorit Pertama',
          sourceName: 'NewsScope',
          category: 'Teknologi',
        ),
      );

      await tester.pumpWidget(createBookmarkScreenWithProvider(provider));

      expect(find.byType(EmptyStateView), findsNothing);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('NewsScope')),
        findsOneWidget,
      );
      expect(find.text('BOOKMARK'), findsOneWidget);
      expect(find.text('Berita Tersimpan'), findsOneWidget);
      expect(find.text('Berita Favorit Pertama'), findsOneWidget);
      expect(find.text('TEKNOLOGI'), findsOneWidget);
    });

    testWidgets('Menekan tombol bookmark pada kartu menghapus artikel dari daftar', (tester) async {
      final provider = BookmarkProvider();
      const article = Article(title: 'Berita Akan Dihapus');
      provider.addBookmark(article);

      await tester.pumpWidget(createBookmarkScreenWithProvider(provider));
      expect(find.text('Berita Akan Dihapus'), findsOneWidget);

      // Tap ikon bookmark
      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      // Sekarang kosong
      expect(find.text('Berita Akan Dihapus'), findsNothing);
      expect(find.text('Belum Ada Berita Tersimpan'), findsOneWidget);
      expect(find.text('Artikel dihapus dari simpanan.'), findsOneWidget);
    });

    testWidgets('Menekan kartu artikel tersimpan membuka DetailScreen', (tester) async {
      final provider = BookmarkProvider();
      const article = Article(
        title: 'Berita Buka Detail',
        content: 'Isi lengkap berita tersimpan.',
      );
      provider.addBookmark(article);

      await tester.pumpWidget(createBookmarkScreenWithProvider(provider));

      await tester.tap(find.text('Berita Buka Detail'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.textContaining('Isi lengkap berita tersimpan.'), findsOneWidget);
    });
  });
}

