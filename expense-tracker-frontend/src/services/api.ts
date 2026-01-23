import type { Expense, Bill, User } from '../types';

const API_Base = 'http://localhost:8080/api';

export const api = {
    // Expenses
    getExpenses: async (userId?: string): Promise<Expense[]> => {
        const url = userId ? `${API_Base}/expenses?userId=${userId}` : `${API_Base}/expenses`;
        const res = await fetch(url);
        if (!res.ok) throw new Error('Failed to fetch expenses');
        return res.json();
    },

    createExpense: async (expense: Omit<Expense, 'id'>): Promise<Expense> => {
        const res = await fetch(`${API_Base}/expenses`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(expense),
        });
        if (!res.ok) throw new Error('Failed to create expense');
        return res.json();
    },

    updateExpense: async (id: string, expense: Partial<Expense>): Promise<Expense> => {
        const res = await fetch(`${API_Base}/expenses/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(expense),
        });
        if (!res.ok) throw new Error('Failed to update expense');
        return res.json();
    },

    deleteExpense: async (id: string): Promise<void> => {
        const res = await fetch(`${API_Base}/expenses/${id}`, {
            method: 'DELETE',
        });
        if (!res.ok) throw new Error('Failed to delete expense');
    },

    // Bills
    getBills: async (userId?: string): Promise<Bill[]> => {
        const url = userId ? `${API_Base}/bills?userId=${userId}` : `${API_Base}/bills`;
        const res = await fetch(url);
        if (!res.ok) throw new Error('Failed to fetch bills');
        return res.json();
    },

    createBill: async (bill: Omit<Bill, 'id'>): Promise<Bill> => {
        const res = await fetch(`${API_Base}/bills`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(bill),
        });
        if (!res.ok) throw new Error('Failed to create bill');
        return res.json();
    },

    markBillAsPaid: async (id: string): Promise<Bill> => {
        const res = await fetch(`${API_Base}/bills/${id}/pay`, {
            method: 'PUT',
        });
        if (!res.ok) throw new Error('Failed to update bill');
        return res.json();
    },

    // User
    getUser: async (): Promise<User> => {
        const res = await fetch(`${API_Base}/user`);
        if (!res.ok) throw new Error('Failed to fetch user');
        return res.json();
    },

    updateUser: async (user: User): Promise<User> => {
        const res = await fetch(`${API_Base}/user`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(user),
        });
        if (!res.ok) throw new Error('Failed to update user');
        return res.json();
    },

    // Auth
    signup: async (userData: any): Promise<User> => {
        const res = await fetch(`${API_Base}/auth/signup`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(userData),
        });
        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(errorText || 'Signup failed');
        }
        return res.json();
    },

    login: async (mobileNumber: string, password: string): Promise<User> => {
        const res = await fetch(`${API_Base}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ mobileNumber, password }),
        });
        if (!res.ok) {
            const errorText = await res.text();
            throw new Error(errorText || 'Login failed');
        }
        return res.json();
    }
};
