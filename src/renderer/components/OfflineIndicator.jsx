import React, { useState, useEffect } from 'react';
import { useLanguage } from '../contexts/LanguageContext';

export function useOnlineStatus() {
    const [isOnline, setIsOnline] = useState(
        typeof navigator !== 'undefined' ? navigator.onLine : true
    );

    useEffect(() => {
        const handleOnline = () => setIsOnline(true);
        const handleOffline = () => setIsOnline(false);

        window.addEventListener('online', handleOnline);
        window.addEventListener('offline', handleOffline);

        return () => {
            window.removeEventListener('online', handleOnline);
            window.removeEventListener('offline', handleOffline);
        };
    }, []);

    return isOnline;
}

export function OfflineIndicator() {
    const isOnline = useOnlineStatus();
    const { t } = useLanguage();
    const [dismissed, setDismissed] = useState(false);

    // Reset dismissed state when coming back online
    useEffect(() => {
        if (isOnline) {
            setDismissed(false);
        }
    }, [isOnline]);

    if (isOnline || dismissed) return null;

    return (
        <div className="fixed bottom-4 left-1/2 -translate-x-1/2 z-50 animate-slide-up">
            <div className="flex items-center gap-3 px-4 py-2 bg-accent-warning/90 text-dark-900 rounded-lg shadow-lg">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 2.829a4.978 4.978 0 01-1.414-2.83m-1.414 5.658a9 9 0 01-2.167-9.238m7.824 2.167a1 1 0 111.414 1.414m-1.414-1.414L3 3m8.293 8.293l1.414 1.414" />
                </svg>
                <div>
                    <p className="font-medium text-sm">{t('errors.offline')}</p>
                    <p className="text-xs opacity-80">{t('errors.offlineDesc')}</p>
                </div>
                <button
                    onClick={() => setDismissed(true)}
                    className="ml-2 p-1 hover:bg-dark-900/20 rounded"
                >
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>
    );
}

export default OfflineIndicator;
