# Expense Tracker - Mobile App

A cross-platform mobile application built with **Flutter**, designed for Android and iOS. This app serves as the primary data entry point, leveraging device capabilities like SMS reading (Android) to automate expense tracking.

## 🛠️ Technology Stack
*   **Framework**: Flutter (3.10+)
*   **Language**: Dart
*   **State Management**: Provider / Riverpod
*   **Auth**: Google Sign-In & Custom JWT
*   **Networking**: HTTP & Dio

## 🚀 Getting Started

### 1. Prerequisites
*   Flutter SDK installed and added to PATH.
*   Android Studio (for Android Emulator) or Xcode (for iOS Simulator).

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
# Run on connected device or emulator
flutter run
```

---

## ✨ Mobile-Exclusive Features
*   **SMS Parsing (Android)**: Automatically reads bank transaction SMS messages to log expenses without manual entry.
*   **Gmail Sync**: Uses Google APIs to securely fetch transaction emails.
*   **Offline Mode**: View cached data even without internet (synced when online).

## 💰 Financial Tracking Features
*   **Multi-Currency**: Supports manual entry of expenses in **INR, USD, EUR, GBP, JPY**.
*   **Smart Dashboard**:
    *   Aggregates total spending in INR (Home Currency).
    *   Uses static conversion rates for instant analysis (Rules: USD=87, EUR=92, GBP=110, JPY=0.6).
    *   Lists display original currency symbols for accuracy.

## 💳 Bill Management
*   **Recurring Bills**: Track monthly/weekly/yearly subscriptions and utility bills.
*   **Smart Editing**: Update bill details (amount, date, note) or delete them entirely.
*   **Payment Tracking**: 
    *   Mark bills as paid manually.
    *   **Logic**: Prevents marking as paid *before* the due date to avoid errors.
    *   **Auto-Advance**: Paying a bill automatically resets the due date to the next cycle.

## 📱 Build for Release

### Android (APK / Bundle)
```bash
# Generate APK
flutter build apk --release

# Generate App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS (IPA)
```bash
# Requires macOS & Xcode
flutter build ios --release
```
*   Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

## 🔧 Configuration
*   **API Base URL**: Configured in `lib/services/api_service.dart`. Defaults to `http://10.0.2.2:8080` for Android Emulator access to localhost.
*   **Permissions**: 
    *   **SMS**: Requires `READ_SMS` permission (Android).
    *   **Contacts/Google**: Requires OAuth setup in Google Cloud Console.
