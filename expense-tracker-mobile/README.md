# Expense Tracker - Mobile App (Flutter)

Native Android/iOS expense tracking app with **Gmail integration** for automatic transaction sync.

## 📱 Features

- ✅ **Google Sign-In** - OAuth 2.0 authentication
- ✅ **Gmail Sync** - Automatically parse bank transaction emails
- ✅ **SMS Parsing** - Extract expenses from bank SMS (Android)
- ✅ **Manual Entry** - Add expenses with full details
- ✅ **Real-time Dashboard** - Live expense tracking with charts
- ✅ **Budget Management** - Set and track monthly budgets
- ✅ **Offline Support** - Local data caching
- ✅ **Dark Mode** - Beautiful gradient UI

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Android Studio / Xcode
- Java JDK 21 (for backend)

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Ensure backend is running**:
   ```bash
   cd ../expense-tracker-backend
   ./gradlew bootRun
   ```

## 🔐 Google Cloud Setup (Gmail Integration)

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project: "Expense Tracker"
3. Enable **Gmail API**

### 2. Configure OAuth Consent Screen
1. Navigate to **APIs & Services > OAuth consent screen**
2. Select **External** user type
3. Add app name and contact info
4. Add scope: `https://www.googleapis.com/auth/gmail.readonly`
5. Add your Gmail as a **Test User**
6. Keep status as **Testing** (no verification needed)

### 3. Create Android OAuth Credentials
1. Go to **APIs & Services > Credentials**
2. Click **Create Credentials > OAuth client ID**
3. Select **Android**
4. **Package Name**: `com.antigravity.expensetracker`
5. **SHA-1 Certificate**:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA1 from the `debug` variant
6. Paste SHA-1 and click **Create**

### 4. Test the Integration
1. Run the app
2. Click **"Sign in with Google"**
3. You'll see a warning: "Google hasn't verified this app"
4. Click **Advanced > Go to [App Name] (unsafe)**
5. Grant permissions

## 📧 How Email Sync Works

### Cost-Free Architecture
- **No server webhooks** - Syncing happens on-device
- **No AI costs** - Uses local Regex parsing
- **No cloud storage** - Emails processed in memory

### Sync Flow
1. User clicks **Sync 🔄** button on dashboard
2. App fetches last 24 hours of emails matching:
   ```
   (transaction OR debit OR spent OR "alert for" OR "vpa debited")
   ```
3. Regex patterns extract:
   - Amount (₹/INR/Rs)
   - Merchant name
   - Date
4. Auto-categorizes (Food, Transport, Shopping, etc.)
5. Saves to backend via REST API

### Supported Bank Formats
The app handles multiple email patterns:
- `"Debited by ₹500 at Starbucks"`
- `"INR 1.00 was debited from your A/c"`
- `"VPA debited for Rs. 100 to Merchant"`
- `"Transaction of ₹250 at Amazon"`

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **HTTP Client**: http package
- **Charts**: fl_chart
- **Google APIs**: 
  - `google_sign_in: ^6.1.6`
  - `googleapis: ^11.4.0`
  - `extension_google_sign_in_as_googleapis_auth: ^2.0.13`
- **Local Storage**: shared_preferences
- **SMS Reading**: telephony (Android only)

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── login_screen.dart     # Login with Google/Mobile
│   ├── home_screen.dart      # Dashboard with charts
│   ├── add_expense_screen.dart
│   ├── details_screen.dart
│   ├── profile_screen.dart
│   └── suggestions_screen.dart
├── services/
│   ├── api_service.dart      # Backend REST calls
│   ├── gmail_service.dart    # Email sync logic
│   └── sms_service.dart      # SMS parsing (Android)
└── providers/
    └── user_provider.dart    # User state management
```

## 🔧 Configuration

### Backend URL
Update in `lib/services/api_service.dart`:
```dart
static const String baseUrl = "http://10.0.2.2:8080/api"; // Android Emulator
// For physical device: use your computer's IP
// static const String baseUrl = "http://192.168.1.x:8080/api";
```

### Gmail Sync Settings
In `lib/services/gmail_service.dart`:
```dart
// Adjust time window (default: last 24 hours)
q: '(transaction OR debit) after:1d'
```

## 📱 Platform-Specific Setup

### Android
1. **Minimum SDK**: 21 (Android 5.0)
2. **Permissions** (auto-added):
   - `INTERNET`
   - `READ_SMS` (for SMS sync)
   - `RECEIVE_SMS` (for SMS sync)

### iOS
1. **Minimum iOS**: 12.0
2. Add to `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

## 🐛 Troubleshooting

### Google Sign-In Fails
- ✅ Verify SHA-1 matches: `./gradlew signingReport`
- ✅ Check package name: `com.antigravity.expensetracker`
- ✅ Ensure you're added as a Test User
- ✅ Clear app data and try again

### Email Sync Not Working
- ✅ Check if Gmail API is enabled
- ✅ Verify `gmail.readonly` scope is granted
- ✅ Look at debug console for parsing errors
- ✅ Email must be from last 24 hours

### Backend Connection Failed
- ✅ Ensure backend is running on port 8080
- ✅ Use `10.0.2.2` for Android Emulator
- ✅ Use actual IP for physical device
- ✅ Check firewall settings

## 🔒 Security & Privacy

- **Gmail Access**: Read-only, never sends emails
- **Data Storage**: All data stored on your backend
- **OAuth Tokens**: Stored in device-encrypted SharedPreferences
- **No Third-Party Tracking**: Zero analytics or ads

## 🚀 Future Enhancements

- [ ] Background email sync (WorkManager)
- [ ] Receipt image upload with OCR
- [ ] Biometric authentication
- [ ] Multi-account support
- [ ] Expense sharing between users
- [ ] Export to PDF/CSV

## 📝 License

Educational project - not for commercial use.

## 👨‍💻 Author

Built with ❤️ using Flutter
