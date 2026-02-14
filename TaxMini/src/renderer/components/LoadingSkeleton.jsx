import React from 'react';

// Skeleton loading animation
export function Skeleton({ className = '', variant = 'rectangular' }) {
    const baseClasses = 'animate-pulse bg-dark-700/50';

    const variantClasses = {
        rectangular: 'rounded',
        circular: 'rounded-full',
        text: 'rounded h-4',
    };

    return (
        <div className={`${baseClasses} ${variantClasses[variant]} ${className}`} />
    );
}

// Card skeleton for documents, tips, etc.
export function CardSkeleton() {
    return (
        <div className="p-4 bg-dark-800 rounded-xl border border-dark-700 space-y-3">
            <div className="flex items-center gap-3">
                <Skeleton variant="circular" className="w-10 h-10" />
                <div className="flex-1 space-y-2">
                    <Skeleton variant="text" className="w-3/4" />
                    <Skeleton variant="text" className="w-1/2" />
                </div>
            </div>
        </div>
    );
}

// List skeleton
export function ListSkeleton({ count = 3 }) {
    return (
        <div className="space-y-3">
            {Array.from({ length: count }).map((_, i) => (
                <CardSkeleton key={i} />
            ))}
        </div>
    );
}

// Table row skeleton
export function TableRowSkeleton({ columns = 4 }) {
    return (
        <div className="flex items-center gap-4 p-3 bg-dark-800 rounded-lg">
            {Array.from({ length: columns }).map((_, i) => (
                <Skeleton key={i} variant="text" className={`flex-1 ${i === 0 ? 'w-1/3' : ''}`} />
            ))}
        </div>
    );
}

// Stats skeleton
export function StatsSkeleton() {
    return (
        <div className="grid grid-cols-3 gap-4">
            {Array.from({ length: 3 }).map((_, i) => (
                <div key={i} className="p-4 bg-dark-800 rounded-xl border border-dark-700 text-center space-y-2">
                    <Skeleton className="w-16 h-8 mx-auto" />
                    <Skeleton variant="text" className="w-20 mx-auto" />
                </div>
            ))}
        </div>
    );
}

// Full page loading
export function PageLoading({ message = 'Loading...' }) {
    return (
        <div className="h-full flex flex-col items-center justify-center p-8">
            <div className="relative">
                <div className="w-12 h-12 border-4 border-dark-600 border-t-accent-primary rounded-full animate-spin" />
            </div>
            <p className="mt-4 text-text-muted text-sm">{message}</p>
        </div>
    );
}

// Inline loading spinner
export function Spinner({ size = 'md', className = '' }) {
    const sizeClasses = {
        sm: 'w-4 h-4 border-2',
        md: 'w-6 h-6 border-2',
        lg: 'w-8 h-8 border-3',
    };

    return (
        <div className={`${sizeClasses[size]} border-dark-600 border-t-accent-primary rounded-full animate-spin ${className}`} />
    );
}

// Button loading state
export function ButtonLoading({ children, isLoading, className = '', ...props }) {
    return (
        <button className={`relative ${className}`} disabled={isLoading} {...props}>
            {isLoading && (
                <span className="absolute inset-0 flex items-center justify-center">
                    <Spinner size="sm" />
                </span>
            )}
            <span className={isLoading ? 'invisible' : ''}>{children}</span>
        </button>
    );
}

export default Skeleton;
