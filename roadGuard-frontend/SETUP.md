# RoadGuard Frontend - Setup Guide

## Prerequisites

- Flutter 3.0+ (install from [flutter.dev](https://flutter.dev/docs/get-started/install))
- Dart 3.0+
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (IDE)
- Git

## Environment Configuration

### Step 1: Create Environment File

The frontend uses environment variables for configuration. Follow these steps:

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your actual values

### Step 2: Configure Backend API URL

Update the API base URL in `.env` based on your environment:

**Local Development:**
```
# For Web/Desktop
API_BASE_URL=http://localhost:8080/roadguard/v1

# For Android Emulator
API_BASE_URL=http://10.0.2.2:8080/roadguard/v1

# For iOS Simulator
API_BASE_URL=http://localhost:8080/roadguard/v1
```

**Production:**
```
API_BASE_URL=https://your-api-domain.com/roadguard/v1
```

**Note:** The app automatically detects the platform and uses the appropriate URL. You can override this by setting `API_BASE_URL` in `.env`.

### Step 3: Configure Google Maps

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API
4. Create an API key with appropriate restrictions
5. Copy the API key and update `.env`:
   ```
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
   ```

**API Key Restrictions (Recommended):**
- Application restrictions: None (for development) or specific app signatures (for production)
- API restrictions: Only enable Maps, Places, and Geocoding APIs
- Referer restrictions: Add your domain for web builds

### Step 4: Configure App Environment

Set the app environment in `.env`:
```
APP_ENVIRONMENT=development
DEBUG_MODE=true
```

**Environments:**
- `development`: Enables debug logs and testing features
- `staging`: Pre-production testing
- `production`: Optimized for production use

## Installing Dependencies

```bash
# Get Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor
```

## Running the App

### Web Development

```bash
flutter run -d chrome
```

### Android Development

```bash
# Run on connected device/emulator
flutter run

# Or specify device
flutter devices
flutter run -d <device_id>
```

**Note for Android Emulator:**
If backend is running on your machine, use `adb reverse` to forward ports:
```bash
adb reverse tcp:8080 tcp:8080
```

### iOS Development

```bash
# Run on connected device/simulator
flutter run

# Or specify device
flutter devices
flutter run -d <device_id>
```

### Desktop Development

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)

```bash
flutter build ios --release
```

Then open Xcode and archive the app.

### Web

```bash
flutter build web --release
```

Output: `build/web/`

## Verifying Setup

1. App launches without errors
2. Backend API is accessible (check network logs)
3. Google Maps displays correctly
4. Authentication flow works
5. Report submission works

## Platform-Specific Setup

### Android

1. Open `android/app/build.gradle`
2. Update `applicationId` with your package name
3. Configure signing keys for release builds
4. Update `android/app/src/main/AndroidManifest.xml` with required permissions

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Update bundle identifier
3. Configure signing and capabilities
4. Add required permissions in `Info.plist`

### Web

1. Update `web/index.html` with your app metadata
2. Configure CORS on backend if needed
3. Test in multiple browsers

## Security Notes

- **NEVER** commit `.env` to version control
- **NEVER** hardcode API keys in source code
- Use restricted API keys with appropriate limitations
- Enable app signing for release builds
- Keep dependencies updated

## Troubleshooting

**Backend Connection Failed:**
- Verify backend is running
- Check API_BASE_URL in `.env`
- For Android emulator, run `adb reverse tcp:8080 tcp:8080`
- Check network connectivity

**Google Maps Not Loading:**
- Verify API key is valid
- Check API key restrictions
- Ensure required APIs are enabled
- Check billing is enabled in Google Cloud Console

**Build Errors:**
- Run `flutter clean` then `flutter pub get`
- Update Flutter: `flutter upgrade`
- Check `flutter doctor` for issues

**Environment Variables Not Loading:**
- Ensure `.env` file exists in project root
- Check file name is exactly `.env` (not `.env.txt`)
- Restart the app after changing `.env`

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)
