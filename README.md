# Expense Tracker - Full Stack Application

A comprehensive expense tracking application with **Web**, **Mobile**, and **Backend** components featuring real-time email sync, SMS parsing, and intelligent financial insights.

## 📁 Project Structure

This repository contains three integrated applications:

- **[Mobile App (Flutter)](./expense-tracker-mobile)**: Native Android/iOS app with Google Sign-In and Gmail integration
- **[Web Frontend (React/Vite)](./expense-tracker-frontend)**: Modern dashboard with dark mode and interactive charts
- **[Backend (Spring Boot)](./expense-tracker-backend)**: RESTful API with SQLite database

## 🚀 Quick Start

### Prerequisites
- **Backend**: Java JDK 21
- **Frontend**: Node.js (v18+), npm
- **Mobile**: Flutter SDK 3.10+, Android Studio/Xcode

### 1. Run the Backend
```bash
cd expense-tracker-backend
./gradlew bootRun
```
Server starts at `http://localhost:8080`

### 2. Run the Web Frontend
```bash
cd expense-tracker-frontend
npm install
npm run dev
```
Available at `http://localhost:5173`

### 3. Run the Mobile App
```bash
cd expense-tracker-mobile
flutter pub get
flutter run
```

## ✨ Key Features

### 💰 Expense Management
- **Manual Entry**: Add expenses with category, merchant, date, and notes
- **Auto-Sync from Email**: Automatically parse bank transaction emails (Gmail integration)
- **SMS Integration**: Extract expenses from bank SMS alerts (Android)
- **Real-time Dashboard**: Live spend tracking with daily/weekly/monthly/yearly filters
- **Budget Tracking**: Set monthly budgets and track remaining balance

### 📊 Analytics & Insights
- **Visual Charts**: Category-wise pie charts and expense trends
- **Time-based Filtering**: View expenses by day, week, month, or year
- **Smart Categorization**: Auto-categorize transactions (Food, Transport, Shopping, etc.)
- **Spending Suggestions**: AI-powered recommendations to reduce expenses

### 🔐 Authentication
- **Google Sign-In**: OAuth 2.0 integration for mobile app
- **Traditional Login**: Email/mobile + password for web
- **Multi-user Support**: Personal data isolation per user

### 📱 Mobile-Specific Features
- **Gmail Sync**: Read transaction emails with `gmail.readonly` scope
- **Regex Parsing**: Extract amount, merchant, and date from various bank formats
- **Background Sync**: Periodic email checking (cost-free, no webhooks needed)
- **Offline Support**: Local data caching with Flutter

### 🌐 Web-Specific Features
- **Responsive Design**: Optimized for desktop and mobile browsers
- **Dark Mode**: Modern UI with gradient cards and animations
- **Bill Management**: Track upcoming bills and mark as paid
- **Export Data**: Download expense reports

## 🛠️ Tech Stack

### Backend
- **Framework**: Spring Boot 3.2.3
- **Database**: SQLite (file-based, zero setup)
- **ORM**: Hibernate/JPA
- **API Docs**: Swagger/OpenAPI

### Web Frontend
- **Framework**: React 18 + Vite
- **State Management**: Zustand
- **Styling**: CSS Modules
- **Charts**: Recharts
- **Icons**: React Icons

### Mobile App
- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **Charts**: fl_chart
- **HTTP Client**: http package
- **Google APIs**: googleapis, google_sign_in

## 📧 Email Sync Setup (Mobile)

1. **Enable Gmail API** in Google Cloud Console
2. **Create OAuth 2.0 Credentials** for Android
3. **Add SHA-1 fingerprint**: `cd android && ./gradlew signingReport`
4. **Package Name**: `com.antigravity.expensetracker`
5. **Add Test Users** in OAuth consent screen (for development)

The app uses **local Regex parsing** (100% free) to extract transaction details from emails.

## 🗄️ Database Schema

- **users**: User profiles with budget settings
- **expenses**: Transaction records with category, amount, date
- **bills**: Upcoming bill tracking
- **sms_messages**: SMS transaction history (mobile)

## 🔒 Security

- Passwords stored in plain text (⚠️ **Development only** - implement hashing for production)
- OAuth tokens stored in SharedPreferences (mobile)
- CORS enabled for `localhost:5173` (frontend)

## 📝 API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login with mobile/email
- `POST /api/auth/google-login` - Google OAuth login

### Expenses
- `GET /api/expenses?userId={id}` - Get user expenses
- `POST /api/expenses` - Create expense
- `PUT /api/expenses/{id}` - Update expense
- `DELETE /api/expenses/{id}` - Delete expense

### Bills
- `GET /api/bills?userId={id}` - Get user bills
- `POST /api/bills` - Create bill
- `PUT /api/bills/{id}/pay` - Mark bill as paid

## 🚧 Future Enhancements

- [ ] PostgreSQL migration for production
- [ ] Real-time WebSocket updates
- [ ] Receipt image upload and OCR
- [ ] Recurring expense tracking
- [ ] Multi-currency support
- [ ] Export to CSV/PDF
- [ ] Password hashing (bcrypt)
- [ ] JWT authentication

## 📄 License

This project is for educational purposes.

## 👨‍💻 Author

Built with ❤️ by Gokul Anbarasan
