/// Custom exception untuk menangani kegagalan atau kendala pada layanan berita.
///
/// Digunakan oleh [ApiNewsService] dan [MockNewsService] untuk menyajikan
/// pesan error yang jelas, ramah pengguna, dan aman (tidak mengekspos kredensial API key).
class NewsException implements Exception {
  final String message;

  const NewsException(this.message);

  @override
  String toString() => message;
}

