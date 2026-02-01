# Expense Tracker - Web Frontend

A modern, responsive web dashboard for managing finances, built with **React** and **TypeScript**.

## 🛠️ Technology Stack
*   **Framework**: React 18
*   **Build Tool**: Vite
*   **Language**: TypeScript
*   **Styling**: CSS Modules (Vanilla CSS)
*   **State**: React Hooks (Zustand/Context)
*   **Charts**: Recharts

## 🚀 Getting Started

### 1. Prerequisites
*   Node.js (v18 or higher)
*   npm or yarn

### 2. Installation
```bash
npm install
```

### 3. Run Development Server
```bash
npm run dev
```
The app will open at `http://localhost:5173`.

### 4. Build for Production
```bash
npm run build
```
This generates a `dist` folder ready for deployment (e.g., to Vercel, Netlify).

---

## 🎨 Features
*   **Dashboard**: Visual overview of monthly spending and budget status.
*   **Expense Log**: Detailed table view of all transactions with filtering.
*   **Dark Mode**: Dark-themed UI for better visual comfort.
*   **Multi-Currency**: Displays original currency symbols for transactions, with static conversion for totals (INR base).
*   **Responsive**: Works seamlessly on Desktop, Tablet, and Mobile web.


## 🔗 Connection to Backend
This frontend is configured to talk to the backend at `http://localhost:8080`.
*   Ensure the **Spring Boot Backend** is running before using the app.
*   API calls are centrally managed in `src/api` or `src/services`.

## 📁 Project Structure
```
src/
├── components/     # Reusable UI components (Cards, Navbar)
├── pages/          # Main application pages (Home, Expenses)
├── styles/         # Global styles and variables
├── types/          # TypeScript interfaces
└── App.tsx         # Main entry point & Routing
```
