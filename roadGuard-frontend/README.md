# RoadGuard Flutter Frontend

Flutter mobile and web application for the RoadGuard hazard reporting system.

## Features Implemented

### Authentication
- **Phone-based authentication** with OTP verification
- **Password-based login** as alternative
- **Secure token storage** using flutter_secure_storage
- **JWT token management** with automatic refresh
- **Role-based routing** (Citizen vs Admin)

### Citizen Features
- **Map View**: Google Maps integration showing nearby hazards
- **Report Hazard**: Camera-based photo capture with location validation
- **My Reports**: View and track submitted reports
- **Location Security**: VPN detection, fake location detection, GPS accuracy validation
- **Camera Enforcement**: Forces camera usage for photo capture

### Admin Features
- **Dashboard**: Overview of all hazard reports
- **Report Management**: Review, approve, reject, and update report status
- **Contractor Assignment**: Assign contractors to specific reports
- **Status Filtering**: Filter reports by various statuses
- **Contractor Management**: Add and manage contractors

### Security Features
- **VPN Detection**: Basic network interface checking
- **Location Validation**: GPS accuracy and data integrity checks
- **Camera-Only Mode**: Enforces camera usage for photo capture
- **Secure Storage**: JWT tokens stored securely
- **Role-Based Access**: Different features based on user role

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart       # API endpoints and constants
│   ├── theme/
│   │   └── app_theme.dart           # App theming
│   └── utils/
│       └── app_utils.dart           # Utility functions
├── data/
│   ├── models/
│   │   └── *.dart                   # Data models
│   ├── repositories/
│   │   └── *.dart                   # Data repositories
│   └── services/
│       ├── auth_service.dart        # Authentication service
│       ├── location_service.dart   # Location and GPS service
│       ├── camera_service.dart      # Camera and image service
│       └── report_service.dart      # Report API service
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── otp_verification_screen.dart
│   │   ├── citizen/
│   │   │   ├── home_screen.dart
│   │   │   ├── map_screen.dart
│   │   │   ├── report_hazard_screen.dart
│   │   │   └── my_reports_screen.dart
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart
│   │       ├── admin_reports_screen.dart
│   │       └── admin_contractors_screen.dart
│   ├── widgets/
│   │   └── *.dart                   # Reusable widgets
│   └── providers/
│       └── auth_provider.dart       # Authentication state management
└── main.dart                        # App entry point
```

## Technology Stack

- **Flutter 3.0+**
- **Provider** for state management
- **Google Maps Flutter** for map integration
- **Geolocator** for GPS and location services
- **Camera** for photo capture
- **Image Picker** for image selection
- **HTTP/Dio** for API calls
- **Flutter Secure Storage** for secure token storage
- **JWT Decoder** for token validation

## Setup Instructions

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd roadGuard-frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:8080';
   ```

4. **Configure Google Maps API Key**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the API key to your platform-specific configuration:
     - **Android**: `android/app/src/main/AndroidManifest.xml`
     - **iOS**: `ios/Runner/Info.plist`
     - **Web**: `web/index.html`

### Running the App

#### Mobile (Android/iOS)
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for release
flutter build apk    # Android
flutter build ios    # iOS
```

#### Web
```bash
# Run in browser
flutter run -d chrome

# Build for web
flutter build web
```

## Configuration

### Android Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture hazard photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to report hazard locations</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need location access to report hazard locations</string>
```

## Key Features

### Authentication Flow
1. User enters phone number
2. System sends OTP (or user can use password)
3. User verifies OTP or enters password
4. JWT token stored securely
5. User redirected based on role

### Report Submission Flow
1. User enables location services
2. App validates no VPN is active
3. User captures photo using camera only
4. App validates GPS accuracy
5. User enters hazard details
6. Report submitted with security metadata

### Admin Workflow
1. Admin views pending reports
2. Reviews hazard details and AI assessment
3. Approves, rejects, or requests more info
4. Assigns contractor if approved
5. Tracks report progress through statuses

## Security Implementation

### Location Security
```dart
// VPN Detection
Future<bool> isVpnDetected() async {
  // Checks network interfaces for VPN indicators
}

// Fake Location Detection
Future<bool> isFakeLocation(Position position) async {
  // Validates GPS accuracy and data consistency
}

// GPS Accuracy Validation
bool isGpsAccuracyAcceptable(double accuracy) {
  // Requires accuracy within 100 meters
  return accuracy <= 100.0;
}
```

### Camera Enforcement
```dart
// Camera-only mode enforced
// Gallery selection disabled in production
// Image metadata validation
```

### Secure Token Storage
```dart
// Uses flutter_secure_storage
// Tokens encrypted at rest
// Automatic token refresh
```

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test/
```

## Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

### Common Issues

1. **Location not working**
   - Ensure location permissions are granted
   - Check GPS is enabled on device
   - Verify location services are enabled in app settings

2. **Camera not working**
   - Ensure camera permissions are granted
   - Check if camera is available on device
   - Try restarting the app

3. **API calls failing**
   - Verify backend is running
   - Check API endpoint configuration
   - Ensure network connectivity
   - Check CORS configuration on backend

4. **Google Maps not loading**
   - Verify Google Maps API key is configured
   - Check API key has necessary permissions
   - Ensure Maps SDK is enabled in Google Cloud Console

## Future Enhancements

- Push notifications for report updates
- Offline mode support
- Image compression optimization
- Advanced VPN detection
- Biometric authentication
- Multi-language support
- Dark mode theme
- Report sharing functionality
- Analytics and crash reporting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
