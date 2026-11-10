# Tambahan PRD --- Tahap 2: Integrasi NewsAPI.org

> Tambahkan bagian ini ke `docs/PRD.md` yang sudah ada. Jangan menghapus
> atau mengganti persyaratan Front End tahap pertama.

## Status dan prasyarat

Tahap Front End harus selesai dan seluruh kriteria keberhasilan PRD
tahap pertama telah terpenuhi menggunakan mock JSON. Tahap kedua
mengganti sumber data mock dengan data nyata dari NewsAPI.org.

## Tujuan

-   Mengambil berita dari NewsAPI.org melalui HTTP.
-   Mempertahankan UI agar tetap bergantung pada abstraksi
    `NewsService`.
-   Mengganti `MockNewsService` dengan `ApiNewsService` melalui
    dependency injection.
-   Memahami Future, async/await, HTTP request, parsing JSON, dan
    penanganan error jaringan.
-   Membuka tautan artikel melalui `url_launcher`.

## Teknologi tambahan

Package yang diizinkan untuk tahap ini: - `http` - `url_launcher`

Package `provider` tetap digunakan. Jangan menambahkan package lain
tanpa persetujuan.

## Persyaratan fungsional tahap API

**API-01 --- API key** - API key dibaca menggunakan
`String.fromEnvironment('NEWS_API_KEY')`. - Key disimpan secara lokal di
`env.json`. - `env.json` wajib di `.gitignore`. - `env.example.json`
berisi placeholder dan boleh di-commit. - Aplikasi dijalankan
menggunakan `flutter run --dart-define-from-file=env.json`. - Jika key
kosong, tampilkan pesan yang jelas.

**API-02 --- Pengambilan berita** - Gunakan endpoint
`https://newsapi.org/v2/top-headlines`. - Kirim key melalui header
`X-Api-Key`. - Gunakan parameter yang sesuai dengan kebutuhan aplikasi
dan panduan integrasi. - Terapkan timeout request. - Parse daftar
`articles` menggunakan `Article.fromJson`.

**API-03 --- Error** - Buat `NewsException` untuk pesan error yang ramah
pengguna. - Tangani HTTP 400, 401, 429, dan status server lainnya. -
Tangani kegagalan jaringan/timeout dengan pesan umum. - Aplikasi tidak
boleh crash ketika request gagal. - Tombol retry memanggil ulang proses
pemuatan.

**API-04 --- Pergantian sumber data** - `ApiNewsService`
mengimplementasikan `NewsService`. - Ganti implementasi service dari
mock ke API pada titik dependency injection. - UI dan widget tidak boleh
melakukan request HTTP langsung. - Hindari perubahan UI yang tidak
diperlukan.

**API-05 --- Tautan artikel** - Tambahkan `url_launcher`. - Tombol Baca
Selengkapnya membuka `article.url` pada aplikasi eksternal jika URL
tersedia. - Jika URL tidak tersedia atau gagal dibuka, tampilkan pesan
yang sesuai.

## Urutan pengerjaan tahap API

A. Persiapan API key dan keamanan: registrasi, uji key, `env.json`,
`.gitignore`, dan `env.example.json`.

B. Implementasi service: tambah `http`, periksa permission internet
Android, buat `NewsException`, dan buat `ApiNewsService`.

C. Integrasi: ganti dependency mock menjadi API, pastikan Provider
mengelola loading/error/empty/success, dan aktifkan tautan artikel.

D. Pengujian: key benar, key kosong, key salah, tanpa internet/timeout,
hasil kosong, dan field artikel yang tidak tersedia.

Kerjakan satu sub-tahap pada satu waktu. Jangan mengerjakan tahap API
sebelum prasyarat Front End selesai.

## Batasan dan catatan

-   Paket gratis NewsAPI Developer menurut panduan guru dibatasi 100
    request per hari, berita tertunda 24 jam, dan hanya untuk
    pengembangan/pengujian.
-   CORS hanya aktif untuk localhost; Flutter Web yang di-deploy ke
    domain lain dapat terblokir.
-   Jangan menambahkan backend, Firebase, Supabase, login, atau fitur
    lain di luar scope.
-   Bookmark tetap mengikuti implementasi tahap Front End dan tidak
    perlu diubah untuk integrasi API.
-   Jangan commit `env.json` atau API key.
