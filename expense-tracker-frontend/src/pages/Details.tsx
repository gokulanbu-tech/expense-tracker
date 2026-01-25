import { useParams, useNavigate } from 'react-router-dom';
import { useStore } from '../store/useStore';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { MdArrowBack, MdDelete, MdEdit } from 'react-icons/md';
import { format } from 'date-fns';
import styles from './Details.module.css';

export function Details() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { expenses, removeExpense } = useStore();

    const expense = expenses.find(e => e.id === id);

    if (!expense) {
        return (
            <div className={styles.container}>
                <div className={styles.notFound}>
                    <h2>Expense not found</h2>
                    <Button onClick={() => navigate('/')}>Go Back</Button>
                </div>
            </div>
        );
    }

    const handleDelete = () => {
        if (confirm('Are you sure you want to delete this expense?')) {
            removeExpense(expense.id);
            navigate('/');
        }
    };

    return (
        <div className={styles.container}>
            <header className={styles.header}>
                <Button variant="ghost" onClick={() => navigate(-1)}>
                    <MdArrowBack size={24} />
                    Back
                </Button>
                <h1 className={styles.title}>Expense Details</h1>
                <div style={{ display: 'flex', gap: '8px' }}>
                    <Button variant="ghost" size="sm" onClick={() => navigate(`/expenses/edit/${id}`)}>
                        <MdEdit size={20} />
                    </Button>
                    <Button variant="danger" size="sm" onClick={handleDelete}>
                        <MdDelete size={20} />
                    </Button>
                </div>
            </header>

            <Card className={styles.detailsCard}>
                <div className={styles.amountSection}>
                    <span className={styles.currency}>{expense.currency}</span>
                    <span className={styles.amount}>{expense.amount.toFixed(2)}</span>
                </div>

                <div className={styles.metaGrid}>
                    <div className={styles.metaItem}>
                        <span className={styles.label}>Merchant</span>
                        <span className={styles.value}>{expense.merchant}</span>
                    </div>

                    <div className={styles.metaItem}>
                        <span className={styles.label}>Date</span>
                        <span className={styles.value}>{format(new Date(expense.date), 'PPP')}</span>
                    </div>

                    <div className={styles.metaItem}>
                        <span className={styles.label}>Category</span>
                        <span className={styles.value}>{expense.category}</span>
                    </div>

                    <div className={styles.metaItem}>
                        <span className={styles.label}>Source</span>
                        <span className={styles.value}>{expense.source}</span>
                    </div>
                </div>

                {expense.notes && (
                    <div className={styles.notesSection}>
                        <span className={styles.label}>Notes</span>
                        <p className={styles.notes}>{expense.notes}</p>
                    </div>
                )}
            </Card>
        </div>
    );
}
