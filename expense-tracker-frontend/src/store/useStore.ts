import { create } from 'zustand';
import type { Expense, User, Suggestion, Bill } from '../types';
import { api } from '../services/api';

interface AppState {
    user: User;
    expenses: Expense[];
    bills: Bill[];
    suggestions: Suggestion[];
    isLoading: boolean;
    error: string | null;

    // Actions
    fetchInitialData: () => Promise<void>;
    fetchExpenses: () => Promise<void>;
    addExpense: (expense: Omit<Expense, 'id'>) => Promise<void>;
    updateExpense: (id: string, expense: Partial<Expense>) => Promise<void>;
    removeExpense: (id: string) => Promise<void>;
    addBill: (bill: Omit<Bill, 'id'>) => Promise<void>;
    markBillAsPaid: (id: string) => Promise<void>;
    updateUserPreferences: (preferences: Partial<User['preferences']>) => Promise<void>;
    fetchSuggestions: () => Promise<void>;
}

const MOCK_SUGGESTIONS: Suggestion[] = [
    {
        id: 's1',
        title: 'Cancel Unused Subscription',
        description: 'You haven\'t used "Premium Music" in 30 days.',
        category: 'Subscription',
        potentialSavings: 199.00,
        type: 'subscription'
    },
    {
        id: 's2',
        title: 'Coffee Habit',
        description: 'Switching to home brewing could save ₹3000/month.',
        category: 'Food',
        potentialSavings: 3000.00,
        type: 'habit'
    }
];

const getStoredUser = () => {
    try {
        const stored = localStorage.getItem('user');
        if (stored) return JSON.parse(stored);
    } catch (e) { }
    return {
        id: 'temp',
        firstName: 'Loading...',
        lastName: '',
        mobileNumber: '',
        email: '',
        monthlyBudget: 0,
        preferences: { darkMode: true, currency: 'INR' }
    };
};

export const useStore = create<AppState>((set, get) => ({
    user: getStoredUser(),
    expenses: [],
    bills: [],
    suggestions: [],
    isLoading: false,
    error: null,

    fetchInitialData: async () => {
        const currentUser = getStoredUser();
        set({ user: currentUser, isLoading: true, error: null });

        const userId = currentUser.id;
        if (!userId || userId === 'temp') {
            set({ isLoading: false });
            return;
        }

        try {
            const [expenses, bills] = await Promise.all([
                api.getExpenses(userId),
                api.getBills(userId)
            ]);
            set({ expenses, bills, isLoading: false });
        } catch (err) {
            set({ error: (err as Error).message, isLoading: false });
        }
    },

    fetchExpenses: async () => {
        const userId = get().user.id;
        if (!userId || userId === 'temp') return;

        set({ isLoading: true, error: null });
        try {
            const expenses = await api.getExpenses(userId);
            set({ expenses, isLoading: false });
        } catch (err) {
            set({ error: (err as Error).message, isLoading: false });
        }
    },

    addExpense: async (expenseData) => {
        set({ isLoading: true });
        try {
            const newExpense = await api.createExpense(expenseData);
            set((state) => ({
                expenses: [newExpense, ...state.expenses],
                isLoading: false
            }));
        } catch (err) {
            set({ error: (err as Error).message, isLoading: false });
        }
    },

    updateExpense: async (id, expenseData) => {
        set({ isLoading: true });
        try {
            const updatedExpense = await api.updateExpense(id, expenseData);
            set((state) => ({
                expenses: state.expenses.map(e => e.id === id ? updatedExpense : e),
                isLoading: false
            }));
        } catch (err) {
            set({ error: (err as Error).message, isLoading: false });
        }
    },

    removeExpense: async (id) => {
        try {
            await api.deleteExpense(id);
            set((state) => ({
                expenses: state.expenses.filter(e => e.id !== id)
            }));
        } catch (err) {
            set({ error: (err as Error).message });
        }
    },

    addBill: async (billData) => {
        try {
            const newBill = await api.createBill(billData);
            set((state) => ({ bills: [...state.bills, newBill] }));
        } catch (err) {
            set({ error: (err as Error).message });
        }
    },

    markBillAsPaid: async (id) => {
        try {
            const updatedBill = await api.markBillAsPaid(id);
            set((state) => ({
                bills: state.bills.map(b => b.id === id ? updatedBill : b)
            }));
        } catch (err) {
            set({ error: (err as Error).message });
        }
    },

    updateUserPreferences: async (prefs) => {
        const currentUser = get().user;
        const updatedUser = {
            ...currentUser,
            preferences: { ...currentUser.preferences, ...prefs }
        };
        // Note: Backend might strictly expect specific structure, but for now assuming it accepts partial updates or we send full object
        try {
            await api.updateUser(updatedUser);
            set({ user: updatedUser });
        } catch (err) {
            set({ error: (err as Error).message });
        }
    },

    fetchSuggestions: async () => {
        set({ isLoading: true });
        // Simulate API call as suggestions endpoint not implemented yet
        setTimeout(() => {
            set({ suggestions: MOCK_SUGGESTIONS });
        }, 1000);
    }
}));
