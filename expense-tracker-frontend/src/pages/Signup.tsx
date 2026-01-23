import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { api } from '../services/api';
import styles from './Auth.module.css';

export function Signup() {
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        firstName: '',
        lastName: '',
        email: '',
        mobileNumber: '',
        password: '',
    });
    const [error, setError] = useState('');

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.signup(formData);
            navigate('/login', { state: { mobileNumber: formData.mobileNumber } });
        } catch (err) {
            if (err instanceof Error)
                setError(err.message);
            else
                setError("Signup failed");
        }
    };

    return (

        <div className={styles.container}>
            <div className={styles.card}>
                <h2 className={styles.title}>Create Account</h2>
                {error && <div className={styles.error}>{error}</div>}
                <form className={styles.form} onSubmit={handleSubmit}>
                    <div className={styles.row}>
                        <div className={styles.inputGroup}>
                            <label className={styles.label}>First Name</label>
                            <input
                                type="text"
                                required
                                className={styles.input}
                                value={formData.firstName}
                                onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                                placeholder="Gokul"
                            />
                        </div>
                        <div className={styles.inputGroup}>
                            <label className={styles.label}>Last Name</label>
                            <input
                                type="text"
                                required
                                className={styles.input}
                                value={formData.lastName}
                                onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                                placeholder="Anbarasan"
                            />
                        </div>
                    </div>
                    <div className={styles.inputGroup}>
                        <label className={styles.label}>Email</label>
                        <input
                            type="email"
                            required
                            className={styles.input}
                            value={formData.email}
                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                            placeholder="email@summa.com"
                        />
                    </div>
                    <div className={styles.inputGroup}>
                        <label className={styles.label}>Mobile Number</label>
                        <input
                            type="tel"
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

                    <button type="submit" className={styles.button}>
                        Sign Up
                    </button>
                </form>
                <div className={styles.footer}>
                    Already have an account?{' '}
                    <Link to="/login" className={styles.link}>
                        Sign in
                    </Link>
                </div>
            </div>
        </div>
    );
}
