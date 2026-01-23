import clsx from 'clsx';
import { type ButtonHTMLAttributes, forwardRef } from 'react';
import css from './Button.module.css';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
    size?: 'sm' | 'md' | 'lg';
    isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
    ({ className, variant = 'primary', size = 'md', isLoading, children, disabled, ...props }, ref) => {
        return (
            <button
                ref={ref}
                className={clsx(
                    css.base,
                    css[variant],
                    css[size],
                    isLoading && css.loading,
                    className
                )}
                disabled={disabled || isLoading}
                {...props}
            >
                {isLoading ? <span className={css.loader} /> : children}
            </button>
        );
    }
);
Button.displayName = 'Button';
