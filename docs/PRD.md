
# PRD — News App Flutter

**Dokumen:** Product Requirements Document  
**Versi:** 2.0  
**Status:** Spesifikasi tahap Front End (Mock Data)  
**Platform:** Android / perangkat yang didukung Flutter  
**Bahasa UI:** Bahasa Indonesia

---

## 1. Ringkasan Produk

News App adalah aplikasi Flutter untuk membaca berita. Proyek ini merupakan proyek pembelajaran yang berfokus pada pembuatan antarmuka, pengelolaan state, pemodelan data, dan persiapan integrasi REST API.

Versi yang dikerjakan berdasarkan dokumen ini adalah **tahap front end menggunakan data contoh lokal (mock data)**. Aplikasi memiliki tiga layar utama: Beranda, Detail Artikel, dan Favorit.

Pada tahap ini, aplikasi belum melakukan request ke NewsAPI.org. Struktur kode harus menyediakan satu titik sambung berupa abstraksi `NewsService`, sehingga implementasi data dapat diganti dari `MockNewsService` ke `ApiNewsService` pada tahap integrasi berikutnya tanpa mengubah widget UI.

### Prinsip utama

1. Memenuhi scope dan learning objectives dari panduan tugas.
2. Mengutamakan kode yang mudah dibaca dan dipelajari siswa.
3. Memisahkan UI, model, service, dan state management.
4. Tidak menambah fitur atau package di luar scope PRD.
5. Menyelesaikan proyek secara bertahap, satu langkah PRD setiap kali.

---

## 2. Tujuan Pembelajaran

Setelah menyelesaikan proyek dan tahap integrasi API berikutnya, siswa diharapkan mampu:

1. Melakukan network call ke REST API menggunakan package `http`.
2. Menerapkan asynchronous programming dengan `Future`, `async`, dan `await`.
3. Menangani state jaringan: loading, sukses, error, dan kosong.
4. Mem-parsing JSON menjadi model Dart yang dapat digunakan UI.

### Pembagian tahap

| Learning objective | Tahap front end dalam PRD ini | Tahap integrasi API berikutnya |
|---|---|---|
| Network call | Menyiapkan abstraksi `NewsService`; belum melakukan request jaringan | Siswa mengimplementasikan request ke NewsAPI.org dengan `http` |
| Asynchronous | Mock service mengembalikan `Future` dengan jeda buatan | Jeda buatan diganti proses request jaringan |
| State jaringan | UI mendukung loading, sukses, error, dan kosong melalui mock service | State dihubungkan ke hasil request nyata |
| JSON parsing | `Article.fromJson` diuji dengan JSON contoh berformat NewsAPI.org | Parsing diuji terhadap respons asli dan field yang mungkin kosong |

---

## 3. Pengguna Sasaran

### Pengguna aplikasi

Pembaca umum yang ingin:
- Melihat daftar berita.
- Mencari artikel berdasarkan kata kunci.
- Memfilter berita berdasarkan kategori.
- Membuka detail artikel.
- Menyimpan dan melihat artikel favorit.

### Pengguna dokumen

Siswa yang telah mengenal dasar Dart dan Flutter, seperti widget, `StatelessWidget`, `StatefulWidget`, dan navigasi sederhana, serta sedang mempelajari pengelolaan data dan integrasi server.

---

## 4. Batasan Scope

### Termasuk dalam versi 1

- Tiga layar: Beranda, Detail Artikel, dan Favorit.
- Data artikel dari file JSON lokal.
- Daftar artikel dengan gambar, judul, sumber, dan waktu terbit.
- Pull-to-refresh untuk memuat ulang daftar mock.
- Pencarian dan filter kategori.
- Detail artikel.
- Bookmark/favorit yang dikelola melalui Provider dan disimpan di memori.
- State loading, error, empty, dan success.
- Simulasi kondisi service melalui konfigurasi `MockNewsService`.
- Tema terpusat dan komponen artikel yang dapat digunakan ulang.

### Tidak termasuk dalam versi 1

- Request sungguhan ke NewsAPI.org.
- Pengelolaan API key.
- Login, registrasi, atau profil pengguna.
- Membuat, mengubah, atau menghapus berita.
- Penyimpanan bookmark permanen.
- Backend sendiri, Firebase, Supabase, atau json-server.
- Notifikasi, caching, dan mode offline khusus.
- Berbagi artikel ke aplikasi lain.
- Fitur atau layar tambahan yang tidak disebutkan dalam PRD.

Jika ada permintaan fitur di luar daftar scope, agent harus menjelaskan bahwa fitur tersebut di luar PRD dan meminta persetujuan sebelum mengubah dokumen atau kode.

---

## 5. Platform dan Teknologi

| Teknologi | Penggunaan |
|---|---|
| Flutter SDK | Framework aplikasi |
| Dart | Bahasa pemrograman |
| Provider | State management |
| JSON lokal | Sumber data contoh |
| Git dan GitHub | Version control dan pengumpulan tugas |

**Batas package:** pada tahap front end, package tambahan yang diizinkan hanya `provider` selain package bawaan Flutter/Dart. Package `http` baru ditambahkan pada tahap integrasi API yang dikerjakan kemudian.

---

## 6. Informasi Arsitektur

### 6.1 Prinsip dependensi

- Widget UI membaca state melalui Provider.
- Provider berkomunikasi dengan abstraksi `NewsService`.
- `MockNewsService` mengimplementasikan `NewsService` dan membaca data contoh.
- UI dan Provider tidak boleh bergantung langsung pada implementasi `MockNewsService`.
- Pada tahap integrasi API, implementasi `ApiNewsService` dapat menggantikan mock service melalui dependency injection tanpa mengubah widget UI.

Alur data:

```text
JSON lokal
   ↓
MockNewsService ── implements ── NewsService
                                  ↑
                                  │
                             NewsProvider
                                  ↓
                              Provider
                                  ↓
                             UI Screens
```

Bookmark memiliki alur state tersendiri:

```text
Beranda / Detail
      ↓
BookmarkProvider
      ↓
Daftar artikel favorit di memori
      ↓
Layar Favorit
```

### 6.2 Struktur folder yang disarankan

```text
lib/
├── main.dart
├── models/
│   └── article.dart
├── services/
│   ├── news_service.dart
│   └── mock_news_service.dart
├── providers/
│   ├── news_provider.dart
│   └── bookmark_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   └── bookmark_screen.dart
├── widgets/
│   ├── article_card.dart
│   └── state_views.dart
└── theme/
    └── app_theme.dart

assets/
└── mock/
    └── articles.json
```

`api_news_service.dart` dapat ditambahkan siswa pada tahap integrasi API, bukan dibuat sebagai implementasi request nyata pada tahap front end ini.

### 6.3 Tanggung jawab komponen

| Komponen | Tanggung jawab |
|---|---|
| `Article` | Menyimpan data artikel dan melakukan parsing JSON |
| `NewsService` | Mendefinisikan kontrak pengambilan artikel |
| `MockNewsService` | Membaca JSON lokal, memberi jeda buatan, dan mensimulasikan hasil |
| `NewsProvider` | Mengelola daftar artikel, filter, status, refresh, dan retry |
| `BookmarkProvider` | Menambah, menghapus, dan memeriksa bookmark di memori |
| `HomeScreen` | Menampilkan pencarian, kategori, daftar artikel, dan state |
| `DetailScreen` | Menampilkan informasi lengkap artikel |
| `BookmarkScreen` | Menampilkan artikel yang disimpan |
| `ArticleCard` | Komponen kartu artikel yang dipakai ulang |
| `StateViews` | Komponen tampilan loading, error, dan empty |
| `AppTheme` | Menyediakan tema, warna, tipografi, dan ukuran visual |

---

## 7. Model Data

### 7.1 Bentuk data artikel

Data contoh mengikuti struktur objek artikel dari NewsAPI.org:

```json
{
  "source": {
    "id": null,
    "name": "Contoh Sumber"
  },
  "author": "Nama Penulis",
  "title": "Judul berita contoh",
  "description": "Ringkasan berita contoh.",
  "url": "https://example.com/article",
  "urlToImage": "https://example.com/image.jpg",
  "publishedAt": "2026-10-13T08:00:00Z",
  "content": "Isi atau cuplikan berita contoh."
}
```

File mock dapat berupa array artikel atau objek respons NewsAPI.org yang memiliki `status`, `totalResults`, dan `articles`. Bentuk yang dipilih harus konsisten dengan implementasi parser.

### 7.2 Field model

Model `Article` minimal memiliki:
- `sourceName`
- `author`
- `title`
- `description`
- `url`
- `urlToImage`
- `publishedAt`
- `content`

Semua field boleh kosong atau `null` kecuali `title`. Parser harus menangani struktur `source.name` yang bersarang.

Ketentuan parsing:
- `Article.fromJson` menjadi satu tempat untuk mengubah JSON menjadi objek `Article`.
- Field yang tidak tersedia tidak boleh menyebabkan aplikasi crash.
- `title` tetap menjadi field wajib; jika data mock tidak memiliki judul yang valid, data tersebut harus diperbaiki atau ditangani secara eksplisit, bukan diam-diam menghasilkan objek artikel yang tidak valid.
- Jangan menaruh logika parsing JSON di widget.

---

## 8. Persyaratan Fungsional

### FR-01 — Daftar berita (Beranda)

Beranda menampilkan daftar artikel dari `NewsService`.

Setiap kartu artikel menampilkan:
- Gambar artikel.
- Judul.
- Nama sumber.
- Waktu/tanggal terbit.
- Aksi bookmark.

Perilaku:
1. Saat layar pertama kali dibuka, aplikasi meminta artikel melalui `NewsProvider`.
2. Selama proses berlangsung, tampilkan state loading.
3. Jika berhasil dan data tersedia, tampilkan daftar artikel.
4. Jika berhasil tetapi tidak ada artikel, tampilkan state empty.
5. Jika terjadi kegagalan, tampilkan state error dan tombol coba lagi.
6. Pengguna dapat menarik daftar ke bawah untuk menjalankan refresh.
7. Menekan kartu membuka layar Detail Artikel.

### FR-02 — Pencarian

Beranda menyediakan kolom pencarian.

Perilaku:
- Pencarian menyaring data mock yang telah dimuat.
- Pencarian dilakukan berdasarkan judul dan, jika tersedia, deskripsi artikel.
- Pencarian tidak memerlukan request jaringan.
- Pencarian yang tidak menemukan hasil menampilkan empty state yang menjelaskan bahwa berita tidak ditemukan.
- Menghapus kata kunci mengembalikan daftar sesuai kategori yang sedang dipilih.

### FR-03 — Filter kategori

Beranda menyediakan chip kategori, minimal:
- Semua
- Bisnis
- Olahraga
- Teknologi
- Hiburan
- Kesehatan

Kategori merupakan filter lokal untuk data contoh. Data mock harus memiliki informasi kategori yang konsisten agar filter dapat diuji. Bila kategori belum tersedia pada format artikel NewsAPI.org, kategori boleh disimpan sebagai metadata tambahan khusus mock; metadata tersebut tidak boleh membuat parser respons API kelak menjadi bergantung pada field nonstandar.

Perilaku:
- Hanya satu kategori aktif pada satu waktu.
- `Semua` menampilkan seluruh artikel.
- Pencarian dan kategori dapat digunakan bersamaan.
- Mengganti kategori tidak menghapus kata kunci pencarian.

### FR-04 — Detail artikel

Detail Artikel menampilkan:
- Gambar utama.
- Judul.
- Penulis jika tersedia.
- Nama sumber.
- Tanggal/waktu terbit.
- Deskripsi jika tersedia.
- Konten/cuplikannya jika tersedia.
- Tombol bookmark.

Tombol **Baca selengkapnya** ditampilkan jika URL artikel tersedia. Pada tahap front end, aksi membuka URL belum diimplementasikan karena integrasi eksternal berada di luar scope. Tombol dapat ditampilkan sebagai elemen nonaktif dengan keterangan yang jelas, atau tidak ditampilkan; pilih satu pendekatan dan gunakan secara konsisten. Jangan menambahkan package untuk membuka URL pada tahap ini.

Jika gambar tidak tersedia atau gagal dimuat, tampilkan placeholder. Jika field opsional kosong, sembunyikan bagian tersebut atau tampilkan fallback yang wajar; jangan menampilkan teks `null`.

### FR-05 — Bookmark/Favorit

Pengguna dapat menambah atau menghapus bookmark dari kartu di Beranda dan dari Detail Artikel.

Perilaku:
- `BookmarkProvider` menjadi satu-satunya pengelola state bookmark.
- Daftar favorit dapat dibuka melalui layar Favorit.
- Status bookmark pada kartu dan detail harus selalu konsisten.
- Artikel yang sudah menjadi favorit dapat dihapus bookmark-nya.
- Jika tidak ada artikel favorit, tampilkan empty state.
- Data bookmark disimpan di memori dan hilang ketika aplikasi ditutup. Ini merupakan keputusan scope versi 1, bukan bug.

### FR-06 — State tampilan

`NewsProvider` harus mendukung empat status:
- **Loading:** proses pengambilan data sedang berjalan.
- **Success:** data berhasil dimuat dan tersedia.
- **Error:** proses gagal; tampilkan pesan dan aksi coba lagi.
- **Empty:** proses berhasil, tetapi tidak ada artikel untuk ditampilkan.

State hasil filter/pencarian yang kosong perlu dibedakan secara tampilan dari kegagalan pemuatan data.

Tampilan state harus menggunakan komponen yang dapat dipakai ulang dan pesan berbahasa Indonesia.

### FR-07 — Simulasi kondisi service

`MockNewsService` harus menyediakan konfigurasi pengembang untuk mensimulasikan:
- Hasil sukses dengan data.
- Hasil kosong.
- Error.
- Lama jeda buatan yang dapat diatur, dengan nilai awal sekitar 1–2 detik.

Konfigurasi ini hanya untuk pengujian/pengembangan dan bukan menu yang ditampilkan kepada pengguna aplikasi.

---

## 9. Persyaratan UI/UX

### 9.1 Prinsip visual

- Gunakan Material 3.
- Gunakan satu warna utama dan warna netral.
- Palet warna utama ditentukan siswa sebelum implementasi UI dimulai.
- Terapkan dua tingkat tipografi utama: judul dan isi. Ukuran serta bobot dikelola terpusat di `app_theme.dart`.
- Gunakan sistem jarak berbasis kelipatan 8.
- Gunakan satu `ArticleCard` yang konsisten di Beranda dan Favorit.
- Hindari dekorasi berlebihan yang mengurangi keterbacaan berita.
- Prioritaskan keterbacaan judul, hierarki informasi, dan konsistensi komponen.

### 9.2 Design tokens

Semua nilai visual harus berasal dari `lib/theme/app_theme.dart`, termasuk:
- Warna utama, warna latar, permukaan, teks, dan warna status.
- Skala tipografi judul dan isi.
- Radius komponen.
- Spacing berbasis 8.
- Elevation atau border jika digunakan.

Widget tidak boleh mengulang nilai warna, ukuran teks, atau jarak secara hard-coded jika nilai tersebut merupakan bagian dari sistem tema. Nilai khusus yang benar-benar kontekstual harus diberi alasan dan tetap konsisten.

### 9.3 Layout dan responsivitas

- Gunakan layout yang menyesuaikan lebar layar.
- Hindari overflow pada layar kecil.
- Daftar artikel harus dapat di-scroll.
- Gambar menggunakan ukuran dan rasio yang konsisten pada kartu.
- Teks panjang harus ditangani dengan batas baris atau layout yang sesuai.
- Pastikan area tombol bookmark mudah disentuh.
- Gunakan safe area dan padding yang konsisten.

### 9.4 Kondisi visual

- Loading: indikator proses yang jelas.
- Error: pesan singkat berbahasa Indonesia dan tombol coba lagi.
- Empty: ilustrasi/icon sederhana atau teks yang menjelaskan belum ada data.
- Gambar kosong/gagal: placeholder dengan ukuran yang sama agar layout tidak berubah.
- Bookmark aktif dan nonaktif harus memiliki pembeda visual yang jelas.

---

## 10. Navigasi dan Alur Pengguna

Navigasi versi 1 hanya mencakup:
- Beranda.
- Detail Artikel.
- Favorit.

Alur utama:
1. Pengguna membuka aplikasi.
2. Aplikasi memuat daftar berita.
3. Pengguna melihat daftar atau state yang sesuai.
4. Pengguna dapat mencari atau memilih kategori.
5. Pengguna dapat membuka artikel untuk melihat detail.
6. Pengguna dapat menandai atau melepas bookmark.
7. Pengguna membuka Favorit untuk melihat artikel tersimpan.
8. Jika pemuatan gagal, pengguna dapat menekan coba lagi.

Jangan menambahkan login, onboarding, profil, atau layar lain yang tidak tercantum pada scope.

---

## 11. Persyaratan Nonfungsional

- Aplikasi tidak crash ketika field artikel opsional bernilai null.
- Widget UI tidak membaca file JSON secara langsung.
- Tidak ada API key atau kredensial dalam source code.
- Kode mengikuti struktur folder yang ditetapkan.
- Nama class, method, variabel, dan file harus jelas.
- Satu widget memiliki tanggung jawab yang terfokus.
- Komentar singkat berbahasa Indonesia diberikan pada bagian pembelajaran penting: `Future`, `async/await`, `fromJson`, dan Provider.
- Teks yang terlihat oleh pengguna menggunakan bahasa Indonesia.
- Tidak menambahkan package tanpa persetujuan.

---

## 12. Kriteria Penerimaan

Versi front end dinyatakan selesai jika seluruh kriteria berikut terpenuhi:

- [ ] Beranda, Detail Artikel, dan Favorit berjalan menggunakan data mock tanpa crash.
- [ ] Daftar artikel menampilkan gambar/placeholder, judul, sumber, waktu terbit, dan bookmark.
- [ ] Pull-to-refresh memicu pemuatan ulang melalui Provider.
- [ ] Pencarian menyaring artikel berdasarkan kata kunci.
- [ ] Filter kategori bekerja dan dapat digunakan bersama pencarian.
- [ ] Loading, error, success, dan empty dapat diuji melalui konfigurasi `MockNewsService`.
- [ ] Error menyediakan tombol coba lagi.
- [ ] Artikel dengan gambar, deskripsi, penulis, atau sumber kosong tetap tampil rapi.
- [ ] Bookmark dapat ditambah/dihapus dari Beranda dan Detail.
- [ ] Status bookmark konsisten di semua layar.
- [ ] Favorit menampilkan empty state ketika belum ada bookmark.
- [ ] `Article.fromJson` berhasil mem-parsing file JSON contoh.
- [ ] UI hanya bergantung pada abstraksi `NewsService`, bukan `MockNewsService`.
- [ ] Tema visual dikelola di `app_theme.dart`.
- [ ] `flutter analyze` selesai tanpa error.
- [ ] Perubahan telah di-commit dengan pesan yang jelas.

---

## 13. Urutan Pengerjaan Front End

Agent harus mengerjakan **satu langkah saja per permintaan**.

### Langkah 1 — Setup proyek, Provider, Git, dan tema

- Pastikan proyek Flutter valid.
- Tambahkan package `provider`.
- Siapkan struktur folder.
- Siapkan `AppTheme` Material 3 dan design tokens.
- Jangan membuat semua layar sekaligus.

**Selesai jika:** proyek dapat dijalankan, Provider terpasang, struktur folder tersedia, dan tema dapat digunakan.

### Langkah 2 — Model Article dan JSON contoh

- Buat model `Article`.
- Implementasikan `Article.fromJson`.
- Buat `assets/mock/articles.json`.
- Daftarkan asset pada `pubspec.yaml`.
- Uji parsing dan field null.

**Selesai jika:** JSON dapat dibaca dan diparsing menjadi daftar `Article` tanpa error.

### Langkah 3 — NewsService dan MockNewsService

- Buat abstraksi `NewsService`.
- Buat `MockNewsService` yang mengimplementasikan kontrak.
- Tambahkan jeda buatan dan mode sukses/error/empty.
- Jangan membuat request HTTP.

**Selesai jika:** mock service dapat menghasilkan tiga skenario sesuai konfigurasi.

### Langkah 4 — NewsProvider dan Beranda dasar

- Buat state loading, success, error, dan empty.
- Hubungkan Provider ke `NewsService`.
- Implementasikan Beranda dasar dan daftar artikel.
- Tambahkan pull-to-refresh dan retry.

**Selesai jika:** Beranda dapat menampilkan daftar dan semua state dapat diuji.

### Langkah 5 — Detail Artikel

- Implementasikan layar detail.
- Tampilkan field artikel dan fallback untuk field opsional.
- Sediakan tombol bookmark yang terhubung ke Provider ketika BookmarkProvider sudah tersedia pada langkah berikutnya; jika belum, jangan membuat state bookmark duplikat.

**Selesai jika:** pengguna dapat membuka detail artikel dan informasi tampil rapi.

### Langkah 6 — BookmarkProvider dan Favorit

- Buat `BookmarkProvider`.
- Hubungkan aksi bookmark dari Beranda dan Detail.
- Buat layar Favorit dan empty state.
- Pastikan status konsisten.

**Selesai jika:** tambah/hapus bookmark bekerja dan daftar Favorit sesuai state Provider.

### Langkah 7 — Pencarian, kategori, dan penyelesaian UI

- Tambahkan pencarian.
- Tambahkan filter kategori.
- Pastikan pencarian dan kategori dapat berjalan bersamaan.
- Rapikan UI/UX dan uji semua state.
- Jalankan `flutter analyze`.

**Selesai jika:** seluruh kriteria penerimaan versi front end terpenuhi.

---

## 14. Tahap Integrasi API (Di Luar PRD Front End)

Tahap ini dilakukan setelah versi front end (mock) selesai secara tuntas:

1. Membuat akun NewsAPI.org dan memperoleh API key pribadi.
2. Menyimpan API key di luar source code yang masuk Git melalui `--dart-define-from-file=env.json` (`String.fromEnvironment('NEWS_API_KEY')`).
3. Menambahkan package `http` dan `url_launcher` pada tahap integrasi.
4. Membuat `NewsException` untuk penanganan error ramah pengguna.
5. Membuat `ApiNewsService` yang mengimplementasikan `NewsService`.
6. Melakukan request ke endpoint `https://newsapi.org/v2/top-headlines` dengan timeout.
7. Mengirim API key melalui header `X-Api-Key` (bukan query parameter).
8. Mem-parsing respons nyata menggunakan `Article.fromJson`, termasuk penanganan field opsional yang kosong/null.
9. Mengganti implementasi mock dengan API service pada titik dependency injection (misalnya `main.dart`).
10. Mengaktifkan tombol "Baca Selengkapnya" dengan `url_launcher`.
11. Menguji kondisi tanpa internet, API key salah/kosong, dan batas kuota.

Rincian panduan langkah teknis dan contoh kode untuk tahap ini terdokumentasi di `docs/API_INTEGRATION_GUIDE.md` dan `docs/PRD_APPEND_API.md`. Tahap ini tidak boleh dikerjakan agent saat menjalankan langkah front end dalam PRD ini.

---

## 15. Git dan Proses Review

- Buat commit awal setelah proyek Flutter dan repository disiapkan.
- Commit setelah setiap langkah PRD selesai.
- Gunakan pesan commit yang menjelaskan perubahan, misalnya `Tambah model Article`.
- Baca dan pahami kode agent sebelum commit.
- Jalankan aplikasi dengan `flutter run` setelah perubahan yang relevan.
- Push perubahan ke GitHub setelah commit.
- Jangan menggabungkan beberapa langkah PRD dalam satu permintaan agent.

---

## 16. Definition of Done

Sebuah langkah dianggap selesai apabila:
1. Hanya scope langkah tersebut yang dikerjakan.
2. Implementasi sesuai PRD dan `AGENTS.md`.
3. Aplikasi tidak memiliki error analisis yang diperkenalkan oleh perubahan.
4. Agent menjelaskan file yang dibuat/diubah dan alasan teknisnya.
5. Agent menyebutkan cara pengujian manual.
6. Agent berhenti dan menunggu instruksi berikutnya.

Proyek front end selesai apabila semua kriteria penerimaan pada Bagian 12 terpenuhi. Integrasi API tetap menjadi tahap pembelajaran terpisah.
