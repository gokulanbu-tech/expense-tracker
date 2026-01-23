import { type ReactNode, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { MdDashboard, MdReceiptLong, MdAutoAwesome, MdMenu, MdClose } from 'react-icons/md';
import clsx from 'clsx';
import styles from './Layout.module.css';
import { Button } from './ui/Button';

interface LayoutProps {
    children: ReactNode;
}

export function Layout({ children }: LayoutProps) {
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);

    const toggleSidebar = () => setIsSidebarOpen(!isSidebarOpen);

    const navItems = [
        { to: '/', icon: MdDashboard, label: 'Summary' },
        { to: '/expenses', icon: MdReceiptLong, label: 'Expenses' },
        { to: '/suggestions', icon: MdAutoAwesome, label: 'AI Suggestions' },
    ];

    return (
        <div className={styles.container}>
            {/* Mobile Header */}
            <header className={styles.mobileHeader}>
                <div className={styles.logo}>ExpenseTracker</div>
                <Button variant="ghost" size="sm" onClick={toggleSidebar}>
                    {isSidebarOpen ? <MdClose size={24} /> : <MdMenu size={24} />}
                </Button>
            </header>

            {/* Sidebar / Drawer */}
            <aside className={clsx(styles.sidebar, isSidebarOpen && styles.open)}>
                <div className={styles.sidebarHeader}>
                    <div className={styles.logo}>ExpenseTracker</div>
                </div>

                <nav className={styles.nav}>
                    {navItems.map((item) => (
                        <NavLink
                            key={item.to}
                            to={item.to}
                            onClick={() => setIsSidebarOpen(false)}
                            className={({ isActive }) =>
                                clsx(styles.navItem, isActive && styles.active)
                            }
                        >
                            <item.icon className={styles.navIcon} />
                            <span>{item.label}</span>
                        </NavLink>
                    ))}
                </nav>

                <div className={styles.userInfo}>
                    {/* Placeholder for user info */}
                    <div className={styles.avatar}>
                        {(() => {
                            try {
                                const user = JSON.parse(localStorage.getItem('user') || '{}');
                                if (user.firstName && user.lastName) {
                                    return `${user.firstName.charAt(0)}${user.lastName.charAt(0)}`.toUpperCase();
                                }
                                return 'GU';
                            } catch (e) { return 'GU'; }
                        })()}
                    </div>
                    <div className={styles.userDetails}>
                        <span className={styles.userName}>
                            {(() => {
                                try {
                                    const user = JSON.parse(localStorage.getItem('user') || '{}');
                                    return user.firstName ? `${user.firstName} ${user.lastName}` : 'Guest User';
                                } catch (e) { return 'Guest User'; }
                            })()}
                        </span>
                        <span className={styles.userBudget}>
                            {(() => {
                                try {
                                    const user = JSON.parse(localStorage.getItem('user') || '{}');
                                    return user.monthlyBudget ? `₹${user.monthlyBudget.toLocaleString()} / mo` : '₹0 / mo';
                                } catch (e) { return '₹0 / mo'; }
                            })()}
                        </span>
                    </div>
                </div>
            </aside>

            {/* Backdrop */}
            {isSidebarOpen && (
                <div className={styles.backdrop} onClick={() => setIsSidebarOpen(false)} />
            )}

            {/* Main Content */}
            <main className={styles.main}>
                <div className={styles.content}>
                    {children}
                </div>
            </main>
        </div>
    );
}
