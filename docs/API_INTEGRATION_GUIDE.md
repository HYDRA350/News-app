# API Integration Guide --- NewsAPI.org

Dokumen ini merupakan panduan tahap kedua proyek News App: mengganti
sumber data mock dengan data dari NewsAPI.org. Ikuti panduan guru dan
sesuaikan nama/tipe dengan implementasi proyek yang sudah ada.

## Prasyarat

Sebelum memulai: - Tahap Front End selesai dan kriteria keberhasilan PRD
sudah terpenuhi menggunakan mock data. - Setiap siswa menggunakan API
key miliknya sendiri. - `AGENTS.md` sudah diperbarui sesuai aturan
integrasi API.

Paket gratis NewsAPI Developer memiliki batas 100 request per hari,
berita tertunda 24 jam, dan hanya untuk pengembangan/pengujian. CORS
hanya aktif untuk localhost; Flutter Web yang di-deploy ke domain lain
dapat terblokir. Aplikasi pada HP atau emulator tidak terdampak oleh
batasan CORS tersebut.

## Tahap A --- Mengambil dan Mengamankan API Key

1.  Buat akun di https://newsapi.org dan verifikasi email.
2.  Salin API key dari halaman akun. Jangan membagikan key kepada siapa
    pun.
3.  Uji key dari terminal sebelum mengubah kode Flutter:

``` bash
curl -H "X-Api-Key: GANTI_DENGAN_KEYMU" \
  "https://newsapi.org/v2/top-headlines?country=id&pageSize=3"
```

4.  Periksa JSON hasilnya. Respons memiliki `status`, `totalResults`,
    dan daftar `articles`. Setiap artikel dapat memiliki `source`,
    `author`, `title`, `description`, `url`, `urlToImage`,
    `publishedAt`, dan `content`.
5.  Buat `env.json` di folder utama proyek:

``` json
{
  "NEWS_API_KEY": "GANTI_DENGAN_KEYMU"
}
```

6.  Tambahkan baris berikut ke `.gitignore`:

``` gitignore
env.json
```

7.  Buat `env.example.json` di folder utama. File ini boleh masuk Git
    karena hanya berisi placeholder:

``` json
{
  "NEWS_API_KEY": "YOUR_NEWS_API_KEY"
}
```

8.  Jalankan aplikasi dengan:

``` bash
flutter run --dart-define-from-file=env.json
```

Pastikan konfigurasi Run/Debug IDE juga meneruskan define tersebut jika
menjalankan aplikasi dari tombol Run.

## Tahap B --- Membuat ApiNewsService

### 1. Tambahkan package HTTP

``` bash
flutter pub add http
```

### 2. Izin internet Android

Periksa `android/app/src/main/AndroidManifest.xml`. Tambahkan permission
berikut di dalam tag `<manifest>` dan di luar tag `<application>` jika
belum ada:

``` xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 3. Buat NewsException

Buat `lib/services/news_exception.dart`:

``` dart
class NewsException implements Exception {
  const NewsException(this.message);

  final String message;
}
```

### 4. Buat ApiNewsService

Buat `lib/services/api_news_service.dart`. Sesuaikan nama method,
parameter, dan tipe dengan `NewsService` yang sudah ada:

``` dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';
import 'news_exception.dart';
import 'news_service.dart';

class ApiNewsService implements NewsService {
  static const _apiKey = String.fromEnvironment('NEWS_API_KEY');

  @override
  Future<List<Article>> fetchArticles({
    String? query,
    String? category,
  }) async {
    if (_apiKey.isEmpty) {
      throw const NewsException(
        'API key belum diisi. Jalankan dengan --dart-define-from-file=env.json',
      );
    }

    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'pageSize': '20',
      if (category != null) 'category': category,
      if (query != null && query.isNotEmpty) 'q': query,
    });

    final response = await http
        .get(uri, headers: {'X-Api-Key': _apiKey})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw NewsException(_pesanError(response.statusCode));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['articles'] as List<dynamic>? ?? [];

    return items
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _pesanError(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid. Periksa parameter yang dikirim.';
      case 401:
        return 'API key salah atau tidak terkirim.';
      case 429:
        return 'Terlalu banyak permintaan atau kuota harian habis. Coba lagi nanti.';
      default:
        return 'Server bermasalah (kode $statusCode). Coba lagi nanti.';
    }
  }
}
```

Catatan: - Kode di atas adalah contoh acuan. Sesuaikan dengan kontrak
`NewsService` dan model `Article` di proyek. - Pastikan parsing JSON dan
penanganan timeout/error sesuai struktur proyek. - Jangan menaruh API
key di URL, source code, atau log.

## Tahap C --- Menghubungkan API ke Aplikasi

### 1. Ganti implementasi service

Cari tempat `NewsProvider` dibuat (umumnya di `main.dart`). Ganti
implementasi service yang diinjeksi:

``` dart
// Sebelum
final NewsService newsService = MockNewsService();

// Sesudah
final NewsService newsService = ApiNewsService();
```

Pertahankan abstraksi `NewsService`; UI tidak perlu mengetahui
implementasi service yang digunakan.

### 2. Pastikan NewsProvider menangani error

Sesuaikan dengan enum/status yang sudah ada. Contoh pola:

``` dart
Future<void> loadArticles() async {
  _status = NewsStatus.loading;
  _errorMessage = null;
  notifyListeners();

  try {
    _articles = await _service.fetchArticles();
    _status = _articles.isEmpty ? NewsStatus.empty : NewsStatus.success;
  } on NewsException catch (e) {
    _errorMessage = e.message;
    _status = NewsStatus.error;
  } catch (_) {
    _errorMessage = 'Gagal terhubung. Periksa koneksi internetmu.';
    _status = NewsStatus.error;
  }

  notifyListeners();
}
```

Pastikan `NewsProvider` tetap menangani error pada refresh dan retry.
Jangan menampilkan hasil kosong sebagai error.

### 3. Aktifkan tombol Baca Selengkapnya

Tambahkan package:

``` bash
flutter pub add url_launcher
```

Di file detail screen, gunakan `url_launcher` untuk membuka URL artikel
pada aplikasi eksternal. Pola contoh dari panduan:

``` dart
import 'package:url_launcher/url_launcher.dart';

Future<void> bukaArtikel(BuildContext context, String url) async {
  final berhasil = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );

  if (!berhasil && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak bisa membuka tautan artikel.')),
    );
  }
}
```

Pada aksi tombol, periksa URL terlebih dahulu:

``` dart
if (article.url != null && article.url!.isNotEmpty) {
  bukaArtikel(context, article.url!);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Tautan artikel tidak tersedia.')),
  );
}
```

Sesuaikan lokasi fungsi dan cara pemanggilan dengan struktur widget
proyek. Hindari mengubah bagian UI lain yang tidak diperlukan.

### 4. Jalankan aplikasi

``` bash
flutter run --dart-define-from-file=env.json
```

Bandingkan hasil aplikasi dengan versi mock data. Perubahan sumber data
seharusnya tidak memerlukan perombakan UI.

## Tahap D --- Pengujian

Uji dan catat hasil skenario berikut:

  ------------------------------------------------------------------------
  Skenario                Cara menguji            Hasil yang diharapkan
  ----------------------- ----------------------- ------------------------
  Sukses                  Jalankan dengan API key Loading, lalu daftar
                          benar                   berita tampil

  API key kosong          Jalankan tanpa define   Pesan bahwa API key
                          dari `env.json`         belum diisi

  API key salah           Gunakan key tidak valid Pesan API key salah
                                                  (HTTP 401)

  Tanpa internet          Matikan koneksi lalu    Pesan gagal terhubung;
                          muat ulang              aplikasi tidak crash

  Hasil kosong            Cari kata acak seperti  Empty state, bukan error
                          `zzzqxj`                

  Field kosong            Temukan artikel tanpa   Placeholder/pengganti;
                          gambar/penulis          tidak crash
  ------------------------------------------------------------------------

Setelah koneksi dipulihkan, tombol coba lagi seharusnya dapat memuat
berita kembali.

## Penutupan dan Git

Sebelum commit: 1. Jalankan `flutter analyze`. 2. Periksa `git status`.
3. Pastikan `env.json` tidak muncul sebagai file yang akan di-commit. 4.
Pastikan `env.example.json` hanya berisi placeholder. 5. Jangan pernah
commit API key asli. 6. Lakukan commit hanya setelah pengguna meminta
atau menyetujui commit.

## Catatan untuk Agent

Kerjakan satu sub-tahap dalam satu instruksi. Jangan otomatis
mengerjakan seluruh Tahap A sampai D sekaligus. Periksa proyek terlebih
dahulu, sesuaikan contoh dengan kode yang sudah ada, jelaskan perubahan
kepada siswa, dan berhenti menunggu instruksi berikutnya.
