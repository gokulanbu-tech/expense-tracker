export interface Expense {
  id: string;
  amount: number;
  currency: string;
  category: string; // e.g., 'Food', 'Transport', 'Utilities'
  merchant: string;
  date: string; // ISO string
  notes?: string;
  source: 'SMS' | 'Mail' | 'Manual';
  type: 'Purchase' | 'Transfer' | 'Withdrawal' | 'BillPayment' | 'Credited' | 'Debited' | 'Spent';
  user?: { id: string };
}

export interface Bill {
  id: string;
  title: string;
  amount: number;
  dueDate: string; // ISO string
  isPaid: boolean;
  user?: { id: string };
}

export interface User {
  id: string;
  firstName: string;
  lastName: string;
  mobileNumber: string;
  email: string;
  monthlyBudget: number;
  preferences: {
    darkMode: boolean;
    currency: string;
  };
}

export interface Suggestion {
  id: string;
  title: string;
  description: string;
  category: string;
  potentialSavings: number;
  actionUrl?: string;
  type: 'subscription' | 'habit' | 'offer';
}
