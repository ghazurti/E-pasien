# Flutter E-Pasien

Aplikasi mobile untuk sistem E-Pasien menggunakan Flutter dengan BLoC pattern.

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.38.7 atau lebih baru
- Backend Rust API running di `http://localhost:3000`

### Installation

```bash
# Clone atau navigate ke project
cd /Users/ghazur_it/Documents/E-Pasien/flutter_epasien

# Install dependencies
flutter pub get

# Run app
flutter run
```

## 📱 Features

- ✅ **Authentication**: Login dengan JWT, auto-login, logout
- ✅ **Jadwal Dokter**: Lihat dan filter jadwal dokter berdasarkan hari
- ✅ **Booking Poli**: Buat booking poli dengan form validation
- ✅ **Profile Management**: Lihat profil dan ganti password

## 🏗️ Architecture

### State Management: BLoC Pattern

```
lib/
├── blocs/          # Business Logic Components
│   ├── auth/       # Authentication BLoC
│   ├── jadwal/     # Jadwal BLoC
│   ├── booking/    # Booking BLoC
│   └── profile/    # Profile BLoC
├── models/         # Data models
├── services/       # API & Storage services
├── screens/        # UI screens
├── widgets/        # Reusable widgets
└── config/         # Configuration (API, Theme)
```

### Dependencies

- `flutter_bloc` - State management
- `http` - HTTP client
- `flutter_secure_storage` - Secure JWT storage
- `google_fonts` - Typography
- `intl` - Date formatting

## 🔧 Configuration

### API Base URL

Edit `lib/config/api_config.dart`:

```dart
// For emulator
static const String baseUrl = 'http://localhost:3000/api';

// For physical device (ganti dengan IP komputer Anda)
static const String baseUrl = 'http://192.168.x.x:3000/api';
```

## 🧪 Testing

```bash
# Analyze code
flutter analyze

# Run app in debug mode
flutter run

# Build APK
flutter build apk
```

## 📚 Documentation

Lihat dokumentasi lengkap di artifacts folder.

## 🎨 Design

- Material 3 Design
- Google Fonts (Poppins & Inter)
- Modern gradient colors
- Responsive layouts

## 📝 License

Private project untuk E-Pasien system.
