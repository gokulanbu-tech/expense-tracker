# Expense Tracker - Frontend

Modern React application built with TypeScript and Vite, featuring a premium glassmorphic UI.

## 🛠 Tech Stack
- **React 19** with TypeScript
- **Vite** for fast builds
- **Zustand** for global state management
- **Recharts** for interactive data visualization
- **Framer Motion** for smooth animations
- **React Icons** for consistent iconography
- **CSS Modules** for scoped styling

## 🚀 Getting Started

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Run the development server:**
   ```bash
   npm run dev
   ```

3. **Build for production:**
   ```bash
   npm run build
   ```

## 📱 Features
- **Interactive Pie Charts**: Category breakdown visualization supporting multiple timeframes.
- **Dynamic Dashboard**: Summary cards for daily/weekly/monthly spending.
- **Real-time API Sync**: Immediate updates from the Spring Boot backend.
- **Auth Simulation**: Basic login/signup flow with localStorage session persistence.
- **Dark Mode**: Premium dark aesthetic by default.

## 🗺 Application Routes
- `/`: Dashboard / Summary
- `/expenses`: Full list of all transactions
- `/expenses/:id`: Individual transaction details
- `/expenses/edit/:id`: Edit existing record
- `/add`: Quick entry for new expenses
- `/suggestions`: AI-powered financial tips
- `/login` / `/signup`: User authentication pages
