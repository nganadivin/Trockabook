# Installation & Deployment Guide - Trocabook Frontend

## 📋 Prerequisites

- Flutter SDK 3.10.7+
- Dart 3.10+
- Android SDK (for Android development)
- Xcode (for iOS development)
- Git

## 🚀 Installation Steps

### 1. Clone Repository
```bash
git clone https://github.com/trocabook/trocabook_front.git
cd trocabook_front
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables

Create `.env` file in project root (if needed):
```env
API_BASE_URL=https://trocabook.vercel.app/
```

### 4. Run the App

#### Development (Hot Reload)
```bash
flutter run
```

#### Specific Device
```bash
flutter run -d <device_id>
```

To list available devices:
```bash
flutter devices
```

#### Android Release Build
```bash
flutter build apk --release
# Or for app bundle:
flutter build appbundle --release
```

#### iOS Release Build
```bash
flutter build ios --release
```

#### Web Build
```bash
flutter build web --release
```

## 🔑 API Configuration

The app connects to: `https://trocabook.vercel.app/`

Base URL is defined in: `lib/core/config/api_endpoints.dart`

To change API endpoint:
```dart
static const String apibaseUrl = 'https://your-api.com/api';
```

## 🔐 Authentication Flow

1. User enters credentials on LoginPage
2. AuthService calls `/auth/login` endpoint
3. Server returns `idToken` and `refreshToken`
4. Tokens stored in FlutterSecureStorage
5. Subsequent requests include `Bearer <idToken>` header
6. On 401 error, token refresh is attempted (future feature)

## 📦 Building for Production

### Android

```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Build signed APK
flutter build apk --release

# Or app bundle (recommended for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release

# Create IPA
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -derivedDataPath build -archivePath build/Runner.xcarchive -archive
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportPath build/ios-release -exportOptionsPlist ExportOptions.plist
```

### Web

```bash
flutter build web --release
# Hosted in: build/web
```

## 🧪 Testing

### Run Unit Tests
```bash
flutter test test/
```

### Run Widget Tests
```bash
flutter test test/widget/
```

### Run Integration Tests
```bash
flutter test integration_test/
```

## 🐛 Debugging

### Enable Debug Mode
```bash
flutter run -v  # Verbose logging
```

### DevTools
```bash
flutter pub global activate devtools
devtools
# Then run app in debug mode and connect
```

### Android Studio DevTools
- Open Android Studio
- Tools → Dart DevTools
- Connect running device

## 📊 Performance Profiling

```bash
# Profile app startup
flutter run --profile

# Capture frame stats
flutter run --profile --enable-impeller-tracing
```

## 🔄 Hot Reload & Hot Restart

During development:
- **Hot Reload**: `r` - Updates code without losing state
- **Hot Restart**: `R` - Full restart, clears state
- **Quit**: `q` - Exit app

## 🛠️ Build Configuration

### Android (android/app/build.gradle)
```gradle
compileSdkVersion 34
minSdkVersion 21
targetSdkVersion 34
```

### iOS (ios/Podfile)
```ruby
platform :ios, '11.0'
```

## 📝 Project Structure

```
trocabook_front/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app/                      # App-level configuration
│   ├── core/                     # Core utilities
│   │   ├── config/               # Configuration files
│   │   ├── network/              # HTTP client
│   │   ├── services/             # Business logic services
│   │   ├── errors/               # Exception classes
│   │   └── widgets/              # Reusable widgets
│   └── features/                 # Feature modules
│       ├── auth/
│       ├── books/
│       ├── chat/
│       └── ...
├── assets/                       # Images, fonts, animations
├── pubspec.yaml                  # Dependencies
└── analysis_options.yaml         # Linting rules
```

## 🚨 Common Issues & Fixes

### Issue: "flutter command not found"
**Solution**: Add Flutter to PATH
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: "Gradle build failed"
**Solution**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Pods could not be installed (iOS)"
**Solution**: Update pods
```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

### Issue: "Keystore file not found"
**Solution**: Create new keystore for Android signing

### Issue: App crashes on startup
**Solution**: Check logcat output
```bash
flutter logs
```

## 📱 Device Testing

### Test on Emulator
```bash
# Android
emulator -avd Pixel_5_API_33 &
flutter run

# iOS
open -a Simulator
flutter run
```

### Test on Physical Device
```bash
# Enable USB debugging on device
# Connect via USB
flutter devices  # Verify device appears
flutter run -d <device_id>
```

## 🔄 Continuous Integration

### GitHub Actions Example
```yaml
name: Flutter Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk
```

## 📦 Release Checklist

- [ ] All tests passing
- [ ] No console errors or warnings
- [ ] API endpoints configured correctly
- [ ] Version bumped in pubspec.yaml
- [ ] CHANGELOG updated
- [ ] Screenshots prepared
- [ ] App store description written
- [ ] Privacy policy reviewed
- [ ] Terms of service reviewed
- [ ] Build tested on multiple devices

## 🚀 Deployment

### Google Play Store
1. Build app bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Configure store listing
4. Submit for review

### Apple App Store
1. Build IPA with Xcode
2. Upload via App Store Connect
3. Configure app information
4. Submit for review

### Web Deployment
```bash
flutter build web --release
# Deploy 'build/web' folder to hosting service
```

## 📞 Support

For issues or questions:
- Check [Flutter Documentation](https://flutter.dev/docs)
- Review [Dio Documentation](https://pub.dev/packages/dio)
- Check existing GitHub issues
- Contact development team

---

**Last Updated:** 2026-02-09
**Flutter Version:** 3.10.7+
**Minimum SDK:** API 21 (Android), iOS 11.0
