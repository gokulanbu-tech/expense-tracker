import { useState, useEffect } from 'react';
import { useNavigate, Link, useLocation } from 'react-router-dom';
import { useStore } from '../store/useStore';
import { api } from '../services/api';
import styles from './Auth.module.css';

export function Login() {
    const navigate = useNavigate();
    const location = useLocation();
    const { fetchInitialData } = useStore();
    const [formData, setFormData] = useState({
        mobileNumber: '',
        password: '',
    });
    const [error, setError] = useState('');

    useEffect(() => {
        if (location.state?.mobileNumber) {
            setFormData(prev => ({ ...prev, mobileNumber: location.state.mobileNumber }));
        }
    }, [location.state]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const user = await api.login(formData.mobileNumber, formData.password);
            localStorage.setItem('user', JSON.stringify(user));
            await fetchInitialData(); // Sync store immediately
            navigate('/');
        } catch (err) {
            if (err instanceof Error)
                setError(err.message);
            else
                setError("Login failed");
        }
    };

    return (
        <div className={styles.container}>
            <div className={styles.card}>
                <h2 className={styles.title}>Sign in to your account</h2>
                {error && <div className={styles.error}>{error}</div>}
                <form className={styles.form} onSubmit={handleSubmit}>
                    <div className={styles.inputGroup}>
                        <label className={styles.label}>Mobile Number</label>
                        <input
                            type="text"
                            required
                            className={styles.input}
                            value={formData.mobileNumber}
                            onChange={(e) => setFormData({ ...formData, mobileNumber: e.target.value })}
                            placeholder="8940225321"
                        />
                    </div>
                    <div className={styles.inputGroup}>
                        <label className={styles.label}>Password</label>
                        <input
                            type="password"
                            required
                            className={styles.input}
                            value={formData.password}
                            onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                            placeholder="i won't share my password"
                        />
                    </div>

                    <button
                        type="submit"
                        className={styles.button}
                    >
                        Sign in
                    </button>
                </form>
                <div className={styles.footer}>
                    <Link to="/signup" className={styles.link}>
                        Don't have an account? Sign up
                    </Link>
                </div>
            </div>
        </div>
    );
}
