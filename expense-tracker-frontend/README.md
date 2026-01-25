# Expense Tracker - Web Frontend (React + Vite)

Modern web dashboard for expense tracking with real-time analytics and beautiful UI.

## ✨ Features

- 📊 **Interactive Dashboard** - Real-time expense tracking with charts
- 🎨 **Dark Mode** - Modern gradient UI with smooth animations
- 📈 **Visual Analytics** - Category-wise pie charts with Recharts
- ⏱️ **Time Filters** - View by Daily, Weekly, Monthly, Yearly
- 💳 **Bill Management** - Track upcoming bills and mark as paid
- 📱 **Responsive Design** - Optimized for desktop and mobile
- 🔐 **User Authentication** - Login/Signup with email or mobile

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- npm or yarn
- Backend running on `http://localhost:8080`

### Installation

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start development server**:
   ```bash
   npm run dev
   ```

3. **Build for production**:
   ```bash
   npm run build
   ```

The app will be available at `http://localhost:5173`

## 🛠️ Tech Stack

- **Framework**: React 18
- **Build Tool**: Vite
- **State Management**: Zustand
- **Styling**: CSS Modules
- **Charts**: Recharts
- **Icons**: React Icons
- **Date Handling**: date-fns
- **Routing**: React Router v6

## 📂 Project Structure

```
src/
├── components/
│   └── ui/              # Reusable UI components
│       ├── Button.tsx
│       ├── Card.tsx
│       └── ...
├── pages/
│   ├── Home.tsx         # Dashboard with charts
│   ├── AddExpense.tsx   # Manual expense entry
│   ├── EditExpense.tsx  # Edit existing expense
│   ├── Details.tsx      # Expense details view
│   ├── Expenses.tsx     # All expenses list
│   ├── Login.tsx        # Authentication
│   ├── Signup.tsx
│   └── Suggestions.tsx  # AI insights
├── services/
│   └── api.ts           # Backend API calls
├── store/
│   └── useStore.ts      # Zustand state management
├── types/
│   └── index.ts         # TypeScript interfaces
├── App.tsx
└── main.tsx
```

## 🎨 Design System

### Color Palette
- **Primary**: `#6366F1` (Indigo)
- **Secondary**: `#A855F7` (Purple)
- **Background**: `#0F172A` (Dark Slate)
- **Surface**: `#1E293B` (Slate)
- **Text**: `#FFFFFF` / `#94A3B8`

### Typography
- **Font**: System fonts with fallback
- **Headings**: Bold, 24-32px
- **Body**: Regular, 14-16px

## 🔌 API Integration

The frontend communicates with the backend via REST API:

```typescript
// services/api.ts
const API_Base = 'http://localhost:8080/api';

// Example: Fetch expenses
const expenses = await api.getExpenses(userId);

// Example: Create expense
await api.createExpense({
  amount: 500,
  currency: 'INR',
  merchant: 'Starbucks',
  category: 'Food',
  type: 'Purchase',
  date: new Date().toISOString(),
  source: 'Manual',
  user: { id: userId }
});
```

## 📊 State Management

Using Zustand for lightweight state:

```typescript
interface AppState {
  user: User;
  expenses: Expense[];
  bills: Bill[];
  fetchExpenses: () => Promise<void>;
  addExpense: (expense: Omit<Expense, 'id'>) => Promise<void>;
  updateExpense: (id: string, expense: Partial<Expense>) => Promise<void>;
  removeExpense: (id: string) => Promise<void>;
}
```

## 🎯 Key Pages

### Dashboard (`/`)
- Total expenses card with gradient
- Budget vs. Remaining (monthly view)
- Category-wise pie chart
- Recent transactions list
- Time filter chips (Daily/Weekly/Monthly/Yearly)

### Add Expense (`/expenses/add`)
- Large amount input
- Transaction type selector
- Merchant/title field
- Category dropdown
- Date picker
- Optional notes

### Expenses List (`/expenses`)
- All transactions with filters
- Edit/Delete actions
- Category icons
- Amount color-coded (red for expenses)

### Suggestions (`/suggestions`)
- AI-powered spending insights
- Subscription cancellation alerts
- Habit-based savings tips

## 🔐 Authentication Flow

1. User visits `/login`
2. Enters mobile number + password
3. Backend validates credentials
4. User object stored in Zustand + localStorage
5. Redirect to dashboard
6. Auto-login on next visit

## 🎨 Styling Approach

Using **CSS Modules** for scoped styles:

```tsx
import styles from './Home.module.css';

<div className={styles.container}>
  <h1 className={styles.title}>Dashboard</h1>
</div>
```

### CSS Variables
```css
:root {
  --color-primary: #6366F1;
  --color-secondary: #A855F7;
  --bg-main: #0F172A;
  --bg-surface: #1E293B;
  --text-main: #FFFFFF;
  --text-muted: #94A3B8;
  --radius-md: 16px;
  --radius-lg: 24px;
}
```

## 📱 Responsive Design

- **Desktop**: Full sidebar navigation
- **Tablet**: Collapsible sidebar
- **Mobile**: Bottom navigation bar

Breakpoints:
- Mobile: `< 768px`
- Tablet: `768px - 1024px`
- Desktop: `> 1024px`

## 🐛 Troubleshooting

### CORS Errors
Ensure backend has CORS enabled for `http://localhost:5173`:
```java
@CrossOrigin(origins = "http://localhost:5173")
```

### API Connection Failed
- ✅ Backend running on port 8080
- ✅ Check `services/api.ts` for correct URL
- ✅ Verify network tab in DevTools

### Build Errors
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

## 🚀 Deployment

### Vercel (Recommended)
```bash
npm run build
vercel --prod
```

### Netlify
```bash
npm run build
netlify deploy --prod --dir=dist
```

### Environment Variables
Create `.env.production`:
```
VITE_API_URL=https://your-backend-url.com/api
```

Update `services/api.ts`:
```typescript
const API_Base = import.meta.env.VITE_API_URL || 'http://localhost:8080/api';
```

## 📦 Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.1",
    "zustand": "^4.4.7",
    "recharts": "^2.10.3",
    "react-icons": "^4.12.0",
    "date-fns": "^3.0.6",
    "clsx": "^2.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8",
    "typescript": "^5.2.2"
  }
}
```

## 🔄 Future Enhancements

- [ ] Real-time updates via WebSockets
- [ ] Export to CSV/PDF
- [ ] Receipt image upload
- [ ] Multi-currency support
- [ ] Recurring expense tracking
- [ ] Budget alerts/notifications
- [ ] Dark/Light theme toggle

## 📝 License

Educational project - not for commercial use.

## 👨‍💻 Author

Built with ⚡ Vite + React
