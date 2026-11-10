import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/news_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_news_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NewsApp());
}

/// Root widget aplikasi NewsScope.
///
/// Di sinilah titik komposisi (Dependency Injection) dilakukan:
/// - [NewsProvider] dengan [ApiNewsService] yang disuntikkan untuk mengambil data nyata dari NewsAPI.org.
/// - [BookmarkProvider] sebagai single source of truth untuk state bookmark di memori.
/// Kedua provider didaftarkan menggunakan [MultiProvider] agar dapat diakses dari seluruh screen.
class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsProvider>(
          create: (_) => NewsProvider(
            newsService: ApiNewsService(),
          ),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'NewsScope',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
