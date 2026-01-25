import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStore } from '../store/useStore';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { MdArrowBack, MdCheck } from 'react-icons/md';
import styles from './AddExpense.module.css';
import type { Expense } from '../types';
import clsx from 'clsx';

const CATEGORIES = ['Food', 'Transport', 'Utilities', 'Shopping', 'Entertainment', 'Health', 'Travel'];
const TYPES: Expense['type'][] = ['Purchase', 'Transfer', 'Withdrawal', 'BillPayment'];

export function AddExpense() {
    const navigate = useNavigate();
    const { addExpense } = useStore();
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    const [formData, setFormData] = useState({
        amount: '',
        category: 'Food',
        type: 'Purchase' as Expense['type'],
        date: new Date().toLocaleDateString('en-CA'),
        merchant: '',
        notes: ''
    });
    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!formData.amount || !formData.merchant) return;

        addExpense({
            amount: parseFloat(formData.amount),
            currency: 'INR',
            merchant: formData.merchant,
            category: formData.category,
            type: formData.type,
            date: new Date(formData.date).toISOString(),
            source: 'Manual',
            notes: formData.notes,
            user: { id: user.id }
        });

        navigate('/');
    };

    return (
        <div className={styles.container}>
            <header className={styles.header}>
                <Button variant="ghost" onClick={() => navigate(-1)}>
                    <MdArrowBack size={24} />
                </Button>
                <h1 className={styles.title}>Add Expense</h1>
                <div style={{ width: 40 }} /> {/* Spacer */}
            </header>

            <form onSubmit={handleSubmit} className={styles.form}>
                <div className={styles.amountInputWrapper}>
                    <span className={styles.currencyPrefix}>₹</span>
                    <input
                        type="number"
                        value={formData.amount}
                        onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                        placeholder="0.00"
                        className={styles.amountInput}
                        autoFocus
                        step="0.01"
                        required
                    />
                </div>

                <Card className={styles.card}>
                    <div className={styles.field}>
                        <label className={styles.label}>Transaction Type</label>
                        <div className={styles.chipGroup}>
                            {TYPES.map(t => (
                                <button
                                    key={t}
                                    type="button"
                                    className={clsx(styles.chip, formData.type === t && styles.activeChip)}
                                    onClick={() => setFormData({ ...formData, type: t })}
                                >
                                    {t}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className={styles.field}>
                        <label className={styles.label}>Merchant / Title</label>
                        <input
                            className={styles.input}
                            value={formData.merchant}
                            onChange={(e) => setFormData({ ...formData, merchant: e.target.value })}
                            placeholder="e.g. Starbucks, Uber"
                            required
                        />
                    </div>

                    <div className={styles.field}>
                        <label className={styles.label}>Category</label>
                        <select
                            className={styles.select}
                            value={formData.category}
                            onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                        >
                            {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
                        </select>
                    </div>

                    <div className={styles.field}>
                        <label className={styles.label}>Date</label>
                        <input
                            type="date"
                            className={styles.input}
                            value={formData.date}
                            onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                        />
                    </div>

                    <div className={styles.field}>
                        <label className={styles.label}>Notes (Optional)</label>
                        <textarea
                            className={styles.textarea}
                            value={formData.notes}
                            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                            placeholder="Add details..."
                            rows={3}
                        />
                    </div>

                    <Button type="submit" size="lg" className={styles.submitBtn}>
                        <MdCheck size={20} style={{ marginRight: 8 }} />
                        Save Expense
                    </Button>
                </Card>
            </form>
        </div>
    );
}
