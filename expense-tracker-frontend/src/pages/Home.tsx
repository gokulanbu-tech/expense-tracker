import { useState, useMemo, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { format, startOfWeek, endOfWeek, startOfMonth, endOfMonth, startOfYear, endOfYear, isWithinInterval } from 'date-fns';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { useStore } from '../store/useStore';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { MdAdd, MdSchedule } from 'react-icons/md';
import styles from './Home.module.css';

type TimeFrame = 'daily' | 'weekly' | 'monthly' | 'yearly';

const COLORS = [
    '#3B82F6', // blue
    '#10B981', // emerald
    '#F59E0B', // amber
    '#EF4444', // red
    '#8B5CF6', // violet
    '#EC4899', // pink
    '#06B6D4', // cyan
];

export function Home() {
    const navigate = useNavigate();
    const { expenses, bills, user, markBillAsPaid, fetchInitialData } = useStore();
    const [timeFrame, setTimeFrame] = useState<TimeFrame>('monthly');

    useEffect(() => {
        fetchInitialData();
    }, [fetchInitialData]);

    const filteredExpenses = useMemo(() => {
        const now = new Date();
        let start: Date, end: Date;

        switch (timeFrame) {
            case 'daily':
                start = new Date(now.setHours(0, 0, 0, 0));
                end = new Date(now.setHours(23, 59, 59, 999));
                break;
            case 'weekly':
                start = startOfWeek(now);
                end = endOfWeek(now);
                break;
            case 'monthly':
                start = startOfMonth(now);
                end = endOfMonth(now);
                break;
            case 'yearly':
                start = startOfYear(now);
                end = endOfYear(now);
                break;
            default:
                start = startOfMonth(now);
                end = endOfMonth(now);
        }

        return expenses.filter(e =>
            isWithinInterval(new Date(e.date), { start, end })
        );
    }, [expenses, timeFrame]);

    const chartData = useMemo(() => {
        const categories: Record<string, number> = {};
        filteredExpenses.forEach(exp => {
            categories[exp.category] = (categories[exp.category] || 0) + exp.amount;
        });

        return Object.entries(categories).map(([name, value], index) => ({
            name,
            value,
            color: COLORS[index % COLORS.length]
        })).sort((a, b) => b.value - a.value);
    }, [filteredExpenses]);

    const totalSpent = filteredExpenses.reduce((acc, curr) => acc + curr.amount, 0);
    const remainingBudget = user.monthlyBudget - totalSpent;

    // Pending Bills
    const pendingBills = bills.filter(b => !b.isPaid).sort((a, b) => new Date(a.dueDate).getTime() - new Date(b.dueDate).getTime());

    return (
        <div className={styles.container}>
            <header className={styles.header}>
                <div>
                    <h1 className={styles.title}>Dashboard</h1>
                    <p className={styles.date}>{format(new Date(), 'EEEE, MMMM do')}</p>
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                    <Button size="sm" onClick={() => navigate('/add')}>
                        <MdAdd size={20} style={{ marginRight: 4 }} />
                        Add
                    </Button>
                </div>
            </header>

            {/* Time Frame Tabs */}
            <div className={styles.tabs}>
                {(['daily', 'weekly', 'monthly', 'yearly'] as TimeFrame[]).map((tf) => (
                    <button
                        key={tf}
                        className={`${styles.tab} ${timeFrame === tf ? styles.activeTab : ''}`}
                        onClick={() => setTimeFrame(tf)}
                    >
                        {tf.charAt(0).toUpperCase() + tf.slice(1)}
                    </button>
                ))}
            </div>

            <section className={styles.summaryGrid}>
                <Card variant="elevated" className={styles.summaryCard}>
                    <span className={styles.cardLabel}>{timeFrame.charAt(0).toUpperCase() + timeFrame.slice(1)} Spend</span>
                    <div className={styles.amount}>
                        ₹{totalSpent.toFixed(2)}
                    </div>
                    {timeFrame === 'monthly' && (
                        <div className={styles.budgetInfo}>
                            <div className={styles.progressContainer}>
                                <div
                                    className={styles.progressBar}
                                    style={{ width: `${Math.min((totalSpent / user.monthlyBudget) * 100, 100)}%` }}
                                />
                            </div>
                            <span className={styles.budgetLabel}>
                                ₹{remainingBudget.toFixed(2)} remaining
                            </span>
                        </div>
                    )}
                </Card>
            </section>

            {/* Expense Breakdown Chart */}
            <section className={styles.chartSection}>
                <h2 className={styles.sectionTitle}>Expense Breakdown</h2>
                <Card className={styles.chartCard}>
                    {chartData.length > 0 ? (
                        <>
                            <div className={styles.chartContainer}>
                                <ResponsiveContainer width="100%" height="100%">
                                    <PieChart>
                                        <Pie
                                            data={chartData}
                                            cx="50%"
                                            cy="50%"
                                            innerRadius={60}
                                            outerRadius={100}
                                            paddingAngle={5}
                                            dataKey="value"
                                        >
                                            {chartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={entry.color} stroke="transparent" />
                                            ))}
                                        </Pie>
                                        <Tooltip
                                            contentStyle={{
                                                backgroundColor: 'var(--bg-card)',
                                                border: '1px solid rgba(255,255,255,0.1)',
                                                borderRadius: 'var(--radius-md)',
                                                color: 'var(--text-main)'
                                            }}
                                            itemStyle={{ color: 'var(--text-main)' }}
                                            formatter={(value: number | undefined) => value !== undefined ? `₹${value.toLocaleString()}` : ''}
                                        />
                                    </PieChart>
                                </ResponsiveContainer>
                            </div>
                            <div className={styles.legend}>
                                {chartData.map((item) => (
                                    <div key={item.name} className={styles.legendItem}>
                                        <div className={styles.legendColor} style={{ backgroundColor: item.color }} />
                                        <span>{item.name}</span>
                                        <span className={styles.legendValue}>₹{item.value.toLocaleString()}</span>
                                    </div>
                                ))}
                            </div>
                        </>
                    ) : (
                        <p className={styles.emptyState}>No data to visualize for this period.</p>
                    )}
                </Card>
            </section>

            {/* Pending Bills */}
            {pendingBills.length > 0 && (
                <section className={styles.billsSection}>
                    <h2 className={styles.sectionTitle}>Pending Bills</h2>
                    <div className={styles.billsList}>
                        {pendingBills.map((bill) => (
                            <Card key={bill.id} className={styles.billItem}>
                                <div className={styles.billContent}>
                                    <div className={styles.billIcon}>
                                        <MdSchedule />
                                    </div>
                                    <div>
                                        <div className={styles.billTitle}>{bill.title}</div>
                                        <div className={styles.billDate}>Due {format(new Date(bill.dueDate), 'MMM d')}</div>
                                    </div>
                                </div>
                                <div className={styles.billAction}>
                                    <span className={styles.billAmount}>₹{bill.amount}</span>
                                    <Button size="sm" variant="ghost" onClick={() => markBillAsPaid(bill.id)}>
                                        Pay
                                    </Button>
                                </div>
                            </Card>
                        ))}
                    </div>
                </section>
            )}

            <section className={styles.timelineSection}>
                <div className={styles.sectionHeader}>
                    <h2 className={styles.sectionTitle}>Recent Transactions</h2>
                    <Button variant="ghost" size="sm" onClick={() => navigate('/expenses')}>View All</Button>
                </div>
                <div className={styles.timeline}>
                    {filteredExpenses.length === 0 ? (
                        <p className={styles.emptyState}>No transactions for this period.</p>
                    ) : (
                        filteredExpenses.slice(0, 5).map((expense) => (
                            <div key={expense.id} className={styles.timelineItem}>
                                <div className={styles.timelineTime}>
                                    {format(new Date(expense.date), 'MMM d')}
                                </div>
                                <div className={styles.timelineNode} />
                                <Card className={styles.timelineContent} onClick={() => navigate(`/expenses/${expense.id}`)}>
                                    <div className={styles.expenseHeader}>
                                        <span className={styles.merchant}>{expense.merchant}</span>
                                        <span className={styles.expenseAmount}>-₹{expense.amount.toFixed(2)}</span>
                                    </div>
                                    <div className={styles.expenseFooter}>
                                        <span className={styles.category}>{expense.category}</span>
                                        <span className={styles.source}>{expense.type || 'Purchase'}</span>
                                    </div>
                                </Card>
                            </div>
                        )))}
                </div>
            </section>
        </div>
    );
}

