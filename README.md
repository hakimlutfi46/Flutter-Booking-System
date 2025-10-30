## Flutter Booking System (EdTech Prototype)

Ini adalah prototipe aplikasi mobile cross-platform (iOS/Android) untuk platform EdTech, yang dibangun menggunakan Flutter. Aplikasi ini memungkinkan orang tua (Parent) untuk mencari dan memesan sesi belajar 1-to-1 dengan guru (Tutor), dan memungkinkan Tutor untuk mengelola ketersediaan dan sesi mereka.
Proyek ini dibuat sebagai bagian dari Internship Assignment dan berfokus pada implementasi alur 1-to-1 end-to-end, arsitektur clean code (modular), dan integrasi real-time dengan Firebase.

### 🚀 Fitur Utama

Aplikasi ini memiliki dua alur pengguna (role) yang berbeda:

#### 👨‍👩‍👧 Alur Parent (Orang Tua)

- Autentikasi: Login & Registrasi (dengan pemilihan peran).
- Dashboard: Tampilan utama dengan statistik real-time (Sesi Mendatang, Sesi Selesai) dan kartu navigasi.
- Pencarian Tutor ( /tutors): Menampilkan semua tutor yang terdaftar. Dilengkapi search bar fungsional untuk memfilter berdasarkan nama atau mata pelajaran.
- Detail Tutor ( /tutors/:id): Menampilkan profil tutor (rating, subjek) dan daftar jadwal kosong ( availability) mereka secara real-time dalam waktu lokal.
- Booking ( processBooking): Alur pemesanan 1-klik yang aman menggunakan Firebase Transaction untuk membuat dokumen bookings dan memperbarui status availability menjadi closed secara bersamaan.
- My Bookings ( /bookings): Halaman dengan TabBar (Upcoming, Past, Cancelled) yang menampilkan daftar booking milik Parent secara real-time.
- Manajemen Booking:
  - Cancel: Membatalkan sesi upcoming (mengubah status bookings menjadi cancelled dan membuka kembali slot availability di backend).
  - Rebook: Membatalkan sesi lama dan otomatis mengarahkan ke halaman detail tutor untuk memilih jadwal baru.
- Profil: Melihat detail akun dan melakukan Logout (dengan dialog konfirmasi).

#### 👩‍🏫 Alur Tutor (Guru)

- Autentikasi: Login & Registrasi (dengan pemilihan peran).
- Dashboard: Tampilan utama dengan statistik real-time yang di-fetch dari Firestore ( Rating, Sesi Hari Ini, Sesi Minggu Ini).
- Today's Schedule: Menampilkan daftar sesi ( bookings) yang terkonfirmasi untuk hari ini, diurutkan berdasarkan waktu.
- Manajemen Ketersediaan ( /availability):
  - Create: Menambah slot jadwal baru (tanggal, waktu mulai, waktu selesai) melalui BottomSheet.
  - Read: Melihat daftar jadwal ( open & closed) secara real-time dengan TabBar (Semua, Buka, Penuh).
  - Delete: Menghapus slot jadwal yang masih open (dengan dialog konfirmasi).
- Manajemen Sesi ( /tutor-sessions):
  - Read: Melihat daftar sesi upcoming yang sudah dipesan oleh Parent.
  - Update (Cancel): Tutor dapat membatalkan sesi (mengubah status bookings & membuka slot availability).
  - Update (Complete): Tutor dapat menandai sesi sebagai 'completed' (yang akan otomatis menghapus slot availability lama dan memperbarui tampilan di dashboard Parent).
- Profil: Melihat detail akun, statistik (Total Sesi Selesai, Rating), dan Logout.

### 🛠️ Tech Stack & Arsitektur

#### Teknologi Utama

- Flutter (v3.x)
- GetX: Digunakan untuk State Management (Reactive), Dependency Injection, dan Navigation (Routing & Middleware).
- Firebase Auth: Untuk autentikasi Email/Password dan manajemen user.
- Firebase Firestore: Database NoSQL real-time untuk semua data aplikasi (users, tutors, availability, bookings).
- Packages: google_fonts, intl (untuk format tanggal/waktu lokal), uuid (untuk ID unik).

#### 🏛️ Arsitektur

Proyek ini dibangun menggunakan Clean Architecture yang dimodifikasi untuk GetX, memisahkan logika ke dalam beberapa layer (lapisan) di dalam folder lib/:

- lib/core: Berisi logika inti aplikasi yang tidak berubah:
  - navigation/: Mengelola semua rute ( Routes), halaman ( Nav), dan middleware ( AuthGuard, RoleGuard).
  - theme/: Mengatur tema global ( AppTheme), warna ( AppColors), dan font.
  - utils/: Helper global (misal: FormatterUtils).
- lib/data: Bertanggung jawab atas sumber data (Database).
  - models/: Berisi semua model data (PODO) seperti UserModel, TutorModel, BookingModel, dll.
  - repositories/: Berisi class yang berkomunikasi langsung dengan Firestore ( BookingRepository, TutorRepository, dll.).
- lib/domain: (Saat ini kosong) Tempat ideal untuk Usecases atau logika bisnis murni yang kompleks.
- lib/presentation: Berisi semua yang terkait dengan UI (Tampilan).
  - global/: Controller yang hidup selama aplikasi berjalan ( AuthController).
  - parent_features/: Fitur/halaman yang hanya bisa diakses oleh Parent (misal search_tutors).
  - tutor_features/: Fitur/halaman yang hanya bisa diakses oleh Tutor (misal availability).
  - shared_features/: Fitur/halaman yang dipakai bersama (Login, Splash, Dashboard, Profile).
  - widgets/: Komponen UI kustom yang reusable ( PrimaryButton, InfoCard, LoadingSpinner, dll.).

### 🏁 Panduan Menjalankan Proyek

Untuk menjalankan proyek ini, Anda wajib mengkonfigurasi proyek Firebase Anda sendiri.

#### 1. Kebutuhan Awal

- Pastikan Anda memiliki Flutter SDK (v3.x atau terbaru) terinstal.
- Editor (VS Code atau Android Studio).
- Emulator/Device fisik.

#### 2. Setup Firebase (Wajib)

Proyek ini tidak akan berjalan tanpa koneksi ke Firebase.

1. Buat Proyek Firebase: Buka Firebase Console dan buat proyek baru (misal: "My Booking App").
2. Aktifkan Auth: Di menu "Build" -> "Authentication", aktifkan Sign-in methodEmail/Password.
3. Aktifkan Firestore: Di menu "Build" -> "Firestore Database", buat database baru dalam mode Production (Pilih lokasi server terdekat, misal asia-southeast2 Jakarta).
4. Update Security Rules: Buka tab Rules di Firestore. Salin seluruh isi file firestore_rules.rules dari repository ini dan tempel ke editor rules Anda. Klik Publish.

#### 3. Setup Koneksi Flutter

1. Clone Repository:

```bash
git clone [URL_REPO_ANDA]
cd [NAMA_FOLDER_REPO]
```

2. Install FlutterFire CLI:

```powershell
dart pub global activate flutterfire_cli
```

3. Konfigurasi Proyek: Jalankan perintah ini dan pilih proyek Firebase yang baru saja Anda buat:

```powershell
flutterfire configure
```

(Perintah ini akan otomatis membuat file lib/firebase_options.dart).

4. Install Dependencies:

```powershell
flutter pub get
```

#### 4. Buat Data Tutor (Wajib untuk Tes)

Aplikasi ini memerlukan minimal satu user dengan peran "tutor" agar bisa dites.

1. Buat User (Auth): Buka Firebase Console -> Authentication. Klik "Add user" dan buat user baru (misal: tutor@gmail.com, password 123456). Salin User UID-nya.
2. Buat Dokumen User (Firestore):
   - Buka Firestore -> Klik "+ Start collection" -> ID: users.
   - Buat dokumen baru. Document ID: tempel User UID dari langkah 1.
   - Tambahkan field:
     - uid (string) -> (tempel User UID lagi)
     - email (string) -> tutor@gmail.com
     - role (string) -> tutor
     - name (string) -> Nama Tutor
     - timezone (string) -> Asia/Jakarta (Contoh)
3. Buat Dokumen Tutor (Firestore):
   - Klik "+ Start collection" -> ID: tutors.
   - Buat dokumen baru. Document ID: tempel User UID yang sama.
   - Tambahkan field:
     - uid (string) -> (tempel User UID lagi)
     - name (string) -> Nama Tutor
     - subject (string) -> Matematika
     - rating (number) -> 4.5
     - timezone (string) -> Asia/Jakarta
4. Selesai!

#### 5. Jalankan Aplikasi

1. Jalankan aplikasi:

```powershell
flutter run
```

2. PENTING (Indeks Firestore): Saat Anda membuka halaman "Detail Tutor" ( /tutor-detail) atau "My Bookings" ( /bookings) pertama kali, aplikasi akan gagal dan log di debug console akan menampilkan error FAILED_PRECONDITION.
3. Salin URL yang ada di pesan error tersebut (dimulai dengan https://console.firebase.google.com/v1/r/project/...).
4. Buka URL itu di browser Anda dan klik "Create Index".
5. Tunggu beberapa menit hingga index selesai dibuat (Status "Enabled").
6. Cold Restart (Stop & Run ulang) aplikasi Anda. Fitur sekarang akan berfungsi.
