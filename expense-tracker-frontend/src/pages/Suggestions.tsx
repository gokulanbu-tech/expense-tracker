import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { MdLightbulb, MdArrowForward } from 'react-icons/md';
import styles from './Suggestions.module.css';

export function Suggestions() {
    const { suggestions, fetchSuggestions, isLoading } = useStore();

    useEffect(() => {
        fetchSuggestions();
    }, [fetchSuggestions]);

    return (
        <div className={styles.container}>
            <header className={styles.header}>
                <h1 className={styles.title}>AI Insights</h1>
                <p className={styles.subtitle}>Smart ways to reduce your spending</p>
            </header>

            {isLoading ? (
                <div className={styles.loading}>Generating insights...will work on this later</div>
            ) : (
                <div className={styles.grid}>
                    {suggestions.map((suggestion) => (
                        <Card key={suggestion.id} className={styles.card} variant="elevated">
                            <div className={styles.cardHeader}>
                                <div className={styles.iconWrapper}>
                                    <MdLightbulb className={styles.icon} />
                                </div>
                                <span className={styles.category}>{suggestion.category}</span>
                            </div>

                            <h3 className={styles.cardTitle}>{suggestion.title}</h3>
                            <p className={styles.cardDescription}>{suggestion.description}</p>

                            <div className={styles.savings}>
                                Potential Savings: <span className={styles.amount}>₹{suggestion.potentialSavings}/mo</span>
                            </div>

                            <Button className={styles.actionBtn} size="sm" variant="secondary">
                                Take Action <MdArrowForward style={{ marginLeft: 8 }} />
                            </Button>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    );
}
