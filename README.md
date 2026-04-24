# SiSehat Bau-Bau — Aplikasi E-Pasien

Aplikasi mobile Flutter untuk sistem layanan kesehatan **RSUD Bau-Bau**, memungkinkan pasien mengakses berbagai layanan rumah sakit secara digital.

---

## Fitur Aplikasi

| Fitur | Keterangan |
|---|---|
| Login / Autentikasi | JWT, auto-login, logout |
| Beranda | Info rumah sakit, berita kesehatan |
| Booking Poli | Daftar poli, pilih dokter & jadwal |
| Antrian | Cek nomor antrian real-time |
| Hasil Laboratorium | Lihat & download PDF hasil lab |
| Hasil Radiologi | Riwayat pemeriksaan radiologi |
| Rekam Medis | Riwayat kunjungan pasien |
| Riwayat Obat | Daftar resep & obat yang pernah diterima |
| Surat Kontrol | Surat rujukan & kontrol dokter |
| Notifikasi Push | FCM — info antrian, hasil lab, dll |

---

## Arsitektur

```
lib/
├── blocs/          # State management (BLoC pattern)
│   └── auth/
├── config/         # API URL, tema warna
├── models/         # Data models
├── screens/        # Halaman UI
├── services/       # API calls, cache, storage
├── utils/          # Helper (PDF generator, dll)
└── main.dart
```

**Stack:** Flutter 3.x · BLoC · Firebase FCM · Rust Backend API

---

## Setup & Instalasi

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) versi **3.10** ke atas
- Android Studio / VS Code
- Akun [Firebase Console](https://console.firebase.google.com/)
- Backend Rust API (lihat repo backend)

### 2. Clone & Install Dependencies

```bash
git clone https://github.com/ghazurti/E-pasien.git
cd E-pasien
flutter pub get
```

### 3. Konfigurasi API URL

Edit `lib/config/api_config.dart`:

```dart
// Emulator Android
static const String baseUrl = 'http://10.0.2.2:3000';

// Device fisik (ganti dengan IP komputer di jaringan yang sama)
static const String baseUrl = 'http://192.168.x.x:3000';
```

---

## Setup Firebase (Push Notification)

Aplikasi ini menggunakan **Firebase Cloud Messaging (FCM)** untuk notifikasi push. File `google-services.json` tidak disertakan di repo karena alasan keamanan — ikuti langkah berikut untuk mengaktifkannya.

### Langkah 1 — Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add project"**
3. Beri nama project, contoh: `SiSehat-BauBau`
4. Klik **Continue** → pilih atau nonaktifkan Google Analytics → **Create project**

### Langkah 2 — Tambahkan Aplikasi Android

1. Di halaman project Firebase, klik ikon **Android** (Add app)
2. Isi **Android package name** sesuai yang ada di `android/app/build.gradle.kts`:
   ```
   com.example.flutter_epasien
   ```
3. Isi **App nickname** (opsional): `SiSehat Bau-Bau`
4. Klik **Register app**

### Langkah 3 — Download google-services.json

1. Setelah register, klik **Download google-services.json**
2. Salin file tersebut ke:
   ```
   android/app/google-services.json
   ```
3. File ini **JANGAN di-commit** ke Git (sudah ada di `.gitignore`)

### Langkah 4 — Aktifkan Cloud Messaging

1. Di Firebase Console, buka **Build → Cloud Messaging**
2. Pastikan **Firebase Cloud Messaging API (V1)** sudah aktif
3. Jika belum, klik **Enable**

### Langkah 5 — Jalankan Aplikasi

```bash
flutter run
```

Saat pertama kali dijalankan, aplikasi akan meminta izin notifikasi. Token FCM akan otomatis dikirim ke backend.

### Verifikasi FCM

Untuk menguji notifikasi dari Firebase Console:

1. Buka **Cloud Messaging → Send your first message**
2. Isi judul dan isi pesan
3. Pilih **Target → Single device**
4. Paste token FCM dari log debug aplikasi
5. Klik **Send test message**

---

## Build APK

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/`

---

## Menjalankan Backend

Pastikan backend Rust sudah berjalan sebelum menjalankan aplikasi:

```bash
cd ../backend-rust
cargo run
```

---

