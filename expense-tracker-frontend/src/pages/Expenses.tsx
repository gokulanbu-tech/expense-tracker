import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { MdFilterList } from 'react-icons/md';
import { format } from 'date-fns';
import { useNavigate } from 'react-router-dom';
import styles from './Expenses.module.css';

export function Expenses() {
    const { expenses, fetchExpenses } = useStore();
    const navigate = useNavigate();

    useEffect(() => {
        fetchExpenses();
    }, [fetchExpenses]);

    return (
        <div className={styles.container}>
            <header className={styles.header}>
                <h1 className={styles.title}>All Expenses</h1>
                <Button variant="secondary" size="sm">
                    <MdFilterList size={20} style={{ marginRight: 4 }} />
                    Filter
                </Button>
            </header>

            <div className={styles.list}>
                {expenses.map((expense) => (
                    <Card
                        key={expense.id}
                        className={styles.expenseItem}
                        onClick={() => navigate(`/expenses/${expense.id}`)}
                    >
                        <div className={styles.expenseMain}>
                            <span className={styles.merchant}>{expense.merchant}</span>
                            <span className={styles.date}>{format(new Date(expense.date), 'MMM d, yyyy')}</span>
                        </div>
                        <div className={styles.expenseMeta}>
                            <span className={styles.category}>{expense.category}</span>
                            <span className={expense.type === 'Credited' ? styles.amountPositive : styles.amount}>
                                {expense.type === 'Credited' ? '+' : '-'}₹{expense.amount.toFixed(2)}
                            </span>
                        </div>
                    </Card>
                ))}
                {expenses.length === 0 && (
                    <div className={styles.emptyState}>
                        <p>No expenses recorded yet.</p>
                    </div>
                )}
            </div>
        </div>
    );
}
