# AGENTS.md --- News App Flutter

## 1. Konteks Proyek

Proyek ini adalah aplikasi News App menggunakan Flutter dan Dart.

Proyek dikembangkan dalam dua tahap utama yang terpisah:
1. **Tahap Front End (Mock Data)**: Implementasi UI (Beranda, Detail Berita, Berita Tersimpan) berdasarkan referensi Stitch (`stitch_design/`), pemodelan data (`Article`), manajemen state dengan `Provider`, dan abstraksi sumber data `NewsService` menggunakan `MockNewsService` dengan data lokal JSON (`assets/mock/articles.json`).
2. **Tahap Integrasi API**: Mengganti `MockNewsService` dengan `ApiNewsService` untuk mengambil data nyata dari NewsAPI.org via HTTP, membaca API key secara aman melalui `String.fromEnvironment('NEWS_API_KEY')`, serta membuka tautan artikel dengan `url_launcher`.

Tujuan utama adalah membantu siswa memahami proses pengembangan secara bertahap. Gunakan bahasa Indonesia yang sederhana, jelaskan konsep penting, dan jangan membuat implementasi sekaligus.

## 2. Sumber Instruksi

Sebelum setiap pekerjaan: 1. Baca `AGENTS.md`. 2. Baca `docs/PRD.md`. 3.
Jika pekerjaan berkaitan dengan integrasi API, baca juga
`docs/API_INTEGRATION_GUIDE.md`. 4. Periksa kondisi proyek dan kode yang
sudah ada sebelum mengubahnya.

Jika dokumen bertentangan, jelaskan konflik dan minta persetujuan
sebelum mengambil keputusan yang mengubah scope. Jangan mengasumsikan
bahwa pekerjaan sebelumnya belum selesai; periksa proyek terlebih
dahulu.

## 3. Aturan Pengerjaan Bertahap

-   Kerjakan hanya satu langkah yang diminta pengguna.
-   Jangan melanjutkan ke langkah berikutnya tanpa instruksi.
-   Jangan membuat ulang bagian yang sudah selesai kecuali diminta atau
    diperlukan untuk memperbaiki bug.
-   Jangan menghapus atau menimpa pekerjaan yang ada tanpa alasan jelas
    dan persetujuan pengguna.
-   Jika prasyarat belum tersedia, jelaskan apa yang kurang dan
    berhenti.
-   Setelah selesai, laporkan ringkasan, file yang dibuat/diubah, konsep
    penting, cara menjalankan/menguji, hasil pemeriksaan, dan hal yang
    perlu dipahami siswa.
-   Berhenti setelah laporan. Jangan melakukan commit atau push Git
    kecuali diminta secara eksplisit.

## 4. Teknologi dan Package

Teknologi:
- Flutter SDK
- Dart
- Provider untuk state management
- JSON lokal (`assets/mock/articles.json`) untuk mock data pada tahap Front End
- `http` untuk HTTP request ke NewsAPI.org (hanya pada tahap Integrasi API)
- `url_launcher` untuk membuka tautan artikel (hanya pada tahap Integrasi API)
- Git dan GitHub

Package yang diizinkan:
- Tahap Front End: hanya `provider` selain package bawaan Flutter/Dart.
- Tahap Integrasi API: `provider`, `http`, dan `url_launcher`.

Jangan menambahkan package lain tanpa menjelaskan alasan dan meminta persetujuan pengguna.

## 5. Arsitektur

Pertahankan pemisahan tanggung jawab: - `models/`: model dan parsing
data. - `services/`: abstraksi sumber berita, implementasi mock,
implementasi API, dan exception. - `providers/`: state aplikasi dan
penghubung service dengan UI. - `screens/`: halaman aplikasi. -
`widgets/`: komponen UI yang dapat digunakan kembali. - `theme/`: warna,
tipografi, dan tema.

Aturan arsitektur: - UI membaca data dan state melalui Provider. -
`NewsProvider` bergantung pada abstraksi `NewsService`, bukan
implementasi konkret. - `MockNewsService` dan `ApiNewsService`
mengimplementasikan `NewsService`. - Pergantian sumber data dilakukan
melalui dependency injection di titik komposisi aplikasi (misalnya
`main.dart`). - Widget dan screen tidak boleh melakukan HTTP request
atau membaca JSON secara langsung. - `BookmarkProvider` menjadi
satu-satunya sumber state bookmark. Jangan membuat state bookmark
duplikat di screen/widget. - Integrasi API sebisa mungkin tidak mengubah
UI yang sudah selesai.

## 6. Model Article dan Parsing JSON

Pertahankan model `Article` yang sudah ada. Bentuk data NewsAPI.org
mencakup: - `source` (objek dengan `id` dan `name`) - `author` -
`title` - `description` - `url` - `urlToImage` - `publishedAt` -
`content`

`title` merupakan informasi utama; field opsional harus dapat bernilai
null atau tidak tersedia. Parsing harus menangani nested `source.name`
dan field opsional yang kosong/tidak valid secara aman. UI tidak boleh
menampilkan teks `"null"`.

Jangan membuat parser bergantung pada field kategori nonstandar dari
NewsAPI.org. Jika mock data memiliki metadata kategori lokal, pisahkan
penanganannya agar tidak merusak kompatibilitas data API.

## 7. Integrasi NewsAPI.org

Ikuti `docs/API_INTEGRATION_GUIDE.md` untuk tahapan dan contoh teknis.

Ketentuan: - Gunakan endpoint `https://newsapi.org/v2/top-headlines`. -
Kirim API key melalui header `X-Api-Key`. - API key hanya dibaca melalui
`String.fromEnvironment('NEWS_API_KEY')`. - Jangan pernah menulis API
key asli langsung di source code, prompt, log, screenshot, atau
repository. - Simpan key lokal di `env.json`, yang wajib masuk
`.gitignore`. - Sediakan `env.example.json` hanya dengan placeholder,
tanpa key asli. - Jalankan aplikasi dengan
`flutter run --dart-define-from-file=env.json`. - Gunakan timeout
request dan tangani status HTTP serta kegagalan jaringan. - Jangan
mengirim API key melalui query parameter. - Jangan mengklaim API
berhasil diuji jika request nyata belum dijalankan.

NewsAPI Developer gratis memiliki batas dan ketentuan penggunaan yang
perlu diperhatikan. Jangan membuat request berulang tanpa kebutuhan
karena kuota harian terbatas.

## 8. Penanganan Error

Gunakan `NewsException` untuk pesan error yang dapat dipahami pengguna,
sesuai panduan integrasi.

`NewsProvider` harus: - Menampilkan loading ketika memuat. - Mengubah
state menjadi success atau empty saat request berhasil. - Menangkap
`NewsException` dan meneruskan pesan yang sesuai. - Menangani error lain
(misalnya tidak ada internet atau timeout) dengan pesan umum yang
ramah. - Menyediakan mekanisme retry melalui fungsi pemuatan ulang. -
Tidak membiarkan exception jaringan membuat aplikasi crash.

Jangan menggunakan `catch` kosong atau menyembunyikan error tanpa
mengubah state yang sesuai.

## 9. UI dan UX

-   Pertahankan desain dan halaman yang sudah disepakati pada PRD.
-   Gunakan Material 3.
-   Bahasa antarmuka adalah Bahasa Indonesia.
-   Pertahankan Home, Article Detail, dan Bookmark; jangan menambah
    halaman di luar scope tanpa persetujuan.
-   Gunakan komponen artikel yang dapat dipakai ulang.
-   Pertahankan loading, success, error, dan empty state.
-   Bedakan hasil pencarian/filter kosong dari kegagalan request.
-   Tampilkan placeholder jika gambar tidak tersedia atau gagal dimuat.
-   Tangani field artikel yang kosong tanpa menampilkan `"null"`.
-   Pastikan konten dapat di-scroll, tidak overflow, dan memperhatikan
    safe area.
-   Tombol Baca Selengkapnya membuka URL artikel menggunakan
    `url_launcher` jika URL valid/tersedia. Jika tidak tersedia,
    tampilkan pesan yang ramah.
-   Jangan merombak UI hanya karena sumber data berubah dari mock ke
    API.

## 10. Keamanan dan Git

-   Jangan pernah menampilkan, mencetak, atau menambahkan API key asli
    ke kode/repository.
-   `env.json` wajib tercantum di `.gitignore`.
-   `env.example.json` boleh di-commit hanya jika isinya placeholder.
-   Sebelum commit, periksa `git status` dan pastikan `env.json` tidak
    ikut ter-stage.
-   Jangan mengubah remote, branch, atau riwayat Git tanpa instruksi.
-   Jangan melakukan commit/push tanpa permintaan eksplisit.
-   Jangan menghapus file yang berpotensi penting tanpa menjelaskan
    dampaknya dan meminta persetujuan.

## 11. Pemeriksaan Kualitas

Jika relevan: - Jalankan `flutter pub get` setelah perubahan
dependency. - Jalankan `flutter analyze`. - Jalankan aplikasi dan uji
alur yang berubah jika lingkungan memungkinkan. - Periksa error dan
warning yang diperkenalkan oleh perubahan. - Jelaskan pemeriksaan yang
tidak dapat dijalankan; jangan mengaku telah menjalankan tes yang
sebenarnya belum dilakukan.

Untuk integrasi API, uji skenario yang tersedia dalam panduan: - API key
benar. - API key kosong/tidak diteruskan. - API key salah. - Tidak ada
internet atau timeout. - Hasil pencarian kosong. - Field artikel seperti
gambar/penulis tidak tersedia.

## 12. Gaya Kode dan Pembelajaran

-   Gunakan null safety dan nama variabel/fungsi yang jelas.
-   Pilih solusi paling sederhana yang memenuhi kebutuhan.
-   Hindari overengineering, abstraksi berlebihan, dan duplikasi.
-   Jangan melakukan formatting besar-besaran yang tidak terkait.
-   Berikan komentar Bahasa Indonesia pada bagian yang penting untuk
    pembelajaran, terutama Future, async/await, parsing JSON, Provider,
    HTTP, dan penanganan error.
-   Jelaskan alasan teknis dengan bahasa yang mudah dipahami siswa
    pemula.

## 13. Definition of Done

Satu tugas dianggap selesai jika: - Hanya langkah yang diminta yang
dikerjakan. - Implementasi mengikuti PRD, panduan API (jika relevan),
dan aturan ini. - Tidak ada package atau fitur di luar scope tanpa
persetujuan. - Pemeriksaan yang relevan telah dijalankan atau
keterbatasannya dijelaskan. - Pengguna mendapat ringkasan, daftar file,
penjelasan, dan cara pengujian. - Agent berhenti dan menunggu instruksi
selanjutnya.

**Jangan pernah membuat atau mengubah seluruh aplikasi sekaligus.
Kerjakan satu langkah sesuai instruksi pengguna.**

## Stitch Design Reference

### Reference Directory
- All approved UI design references are stored in the project root directory: `stitch_design/`.
- This directory is the single source of truth for the application's visual design.
- Before implementing, modifying, or reviewing any UI screen, inspect the relevant files inside `stitch_design/`.
- Explore the directory recursively when necessary to identify all available design references.
- Do not assume specific filenames or file extensions. Inspect the actual directory contents first.
- Do not modify, rename, move, or delete any files inside `stitch_design/`.

### Design Implementation Rules
- The Flutter UI MUST follow the approved Stitch references as closely as possible.
- Treat the Stitch references as the primary visual specification.
- Match the following design elements:
  - Layout and component positioning
  - Colors and color palette
  - Typography, font sizes, and font weights
  - Spacing, padding, and margins
  - Border radius, shadows, and elevation
  - Images, icons, and visual hierarchy
  - Navigation patterns and interactive states
- Maintain visual consistency across Home, Article Detail, and Bookmark screens.
- Create reusable Flutter widgets for repeated UI components.
- Use Material 3 and Flutter-compatible implementations without unnecessarily changing the original design.
- Do not invent a new visual direction, redesign approved screens, or introduce unnecessary UI elements.
- If a design element cannot be reproduced exactly, implement the closest practical alternative while preserving its appearance and behavior.

### Design and Functionality Priority
- `stitch_design/` defines how the application should look.
- `docs/PRD.md` defines what the application should do.
- `AGENTS.md` defines how the application should be implemented.
- `docs/API_INTEGRATION_GUIDE.md` provides technical guidance for API integration.

Never sacrifice the approved visual design when implementing functionality unless a technical limitation makes it necessary. Explain any unavoidable deviation before proceeding.