# Expense Tracker - Pro

A modern, full-stack expense tracking application with real-time analytics, bill management, and AI-powered financial insights.

## 📁 Project Structure

This repository is split into two main parts:

- **[Front End (React/Vite)](./expense-tracker-frontend)**: Modern dashboard with dark mode, interactive charts, and responsive UI.
- **[Back End (Spring Boot)](./expense-tracker-backend)**: RESTful API built with Java, Spring Boot, and SQLite for data persistence.

## 🚀 Quick Start

### 1. Prerequisites
- Node.js (v18+)
- Java JDK 21
- npm

### 2. Run the Backend
```bash
cd expense-tracker-backend
./gradlew bootRun
```
The server will start at `http://localhost:8080`.

### 3. Run the Frontend
```bash
cd expense-tracker-frontend
npm install
npm run dev
```
The application will be available at `http://localhost:5173`.

## ✨ Key Features
- **Real-time Dashboard**: Live spend tracking synced with the database.
- **Visual Analytics**: Category-wise pie charts with daily, weekly, monthly, and yearly filtering using Recharts.
- **Expense Management**: Full CRUD (Create, Read, Update, Delete) functionality for transactions.
- **Bill Tracking**: Manage upcoming bills and mark them as paid.
- **Multi-user Support**: Personal data isolation based on User ID.
- **Responsive Design**: Optimized for both desktop and mobile viewing.
