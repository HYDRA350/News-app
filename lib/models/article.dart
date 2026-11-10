/// Model data untuk artikel berita.
///
/// Struktur data dirancang selaras dengan format respons artikel NewsAPI.org.
/// Sesuai PRD Bagian 7.2:
/// - [title] merupakan informasi utama yang wajib (non-nullable).
/// - Field lainnya bersifat opsional (nullable) untuk menangani kemungkinan data
///   tidak lengkap dari API atau sumber berita tanpa membuat aplikasi crash.
/// - Field [category] adalah metadata lokal opsional untuk mendukung filter kategori
///   pada data mock, tanpa mewajibkan keberadaannya pada parser API kelak.
class Article {
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  /// Metadata kategori opsional (misal: "Bisnis", "Teknologi", "Olahraga", dsb.)
  final String? category;

  const Article({
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  /// Mengubah Map JSON menjadi instance [Article].
  ///
  /// Mampu menangani:
  /// - Struktur bersarang `source.name` secara aman.
  /// - Field opsional yang bernilai `null` atau tidak ada dalam JSON.
  /// - Field `title` wajib memiliki nilai (jika null/kosong diganti fallback atau throw).
  factory Article.fromJson(Map<String, dynamic> json) {
    // 1. Ekstraksi objek nested 'source' secara aman
    String? parsedSourceName;
    final sourceData = json['source'];
    if (sourceData is Map<String, dynamic>) {
      parsedSourceName = sourceData['name'] as String?;
    } else if (json['sourceName'] is String) {
      // Fallback jika format flat digunakan
      parsedSourceName = json['sourceName'] as String?;
    }

    // 2. Ekstraksi 'title' yang wajib ada
    final rawTitle = json['title'] as String?;
    if (rawTitle == null || rawTitle.trim().isEmpty) {
      throw const FormatException('Artikel wajib memiliki judul (title) yang valid.');
    }

    // 3. Ekstraksi field opsional lainnya dengan aman
    return Article(
      sourceName: parsedSourceName,
      author: json['author'] as String?,
      title: rawTitle,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String?,
    );
  }

  /// Konversi instance [Article] menjadi Map (berguna untuk serialisasi atau pengujian).
  Map<String, dynamic> toJson() {
    return {
      'source': {
        'id': null,
        'name': sourceName,
      },
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      if (category != null) 'category': category,
    };
  }
}

