import React from 'react';
import { useLanguage } from '../contexts/LanguageContext';

function KeyboardShortcuts({ isOpen, onClose }) {
    const { t } = useLanguage();

    if (!isOpen) return null;

    const shortcuts = [
        {
            category: t('shortcuts.general'), items: [
                { keys: ['Ctrl', 'N'], description: t('shortcuts.newTaxReturn') },
                { keys: ['Ctrl', 'S'], description: t('shortcuts.saveSession') },
                { keys: ['Ctrl', '?'], description: t('shortcuts.showShortcuts') },
                { keys: ['Escape'], description: t('shortcuts.closeModal') },
            ]
        },
        {
            category: t('shortcuts.documents'), items: [
                { keys: ['Ctrl', 'O'], description: t('shortcuts.openFile') },
                { keys: ['Ctrl', 'V'], description: t('shortcuts.paste') },
            ]
        },
        {
            category: t('shortcuts.navigation'), items: [
                { keys: ['←'], description: t('shortcuts.prevStep') },
                { keys: ['→'], description: t('shortcuts.nextStep') },
                { keys: ['Enter'], description: t('shortcuts.confirmContinue') },
            ]
        },
    ];

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
            <div
                className="bg-dark-800 rounded-2xl border border-dark-600 shadow-2xl w-full max-w-lg mx-4 overflow-hidden animate-scale-in"
                role="dialog"
                aria-labelledby="shortcuts-title"
            >
                {/* Header */}
                <div className="p-6 border-b border-dark-600">
                    <div className="flex items-center justify-between">
                        <h2 id="shortcuts-title" className="text-xl font-bold text-text-primary flex items-center gap-2">
                            <span className="text-2xl">⌨️</span>
                            {t('shortcuts.title')}
                        </h2>
                        <button
                            onClick={onClose}
                            className="p-2 rounded-lg hover:bg-dark-700 text-text-muted hover:text-text-primary transition-colors"
                            aria-label={t('common.close')}
                        >
                            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                {/* Content */}
                <div className="p-6 max-h-96 overflow-y-auto space-y-6">
                    {shortcuts.map((group) => (
                        <div key={group.category}>
                            <h3 className="text-sm font-medium text-text-muted mb-3 uppercase tracking-wider">
                                {group.category}
                            </h3>
                            <div className="space-y-2">
                                {group.items.map((shortcut, index) => (
                                    <div
                                        key={index}
                                        className="flex items-center justify-between py-2 px-3 rounded-lg bg-dark-700/50"
                                    >
                                        <span className="text-sm text-text-secondary">
                                            {shortcut.description}
                                        </span>
                                        <div className="flex items-center gap-1">
                                            {shortcut.keys.map((key, keyIndex) => (
                                                <React.Fragment key={keyIndex}>
                                                    <kbd className="px-2 py-1 text-xs font-mono bg-dark-900 border border-dark-500 rounded text-text-primary shadow-sm">
                                                        {key}
                                                    </kbd>
                                                    {keyIndex < shortcut.keys.length - 1 && (
                                                        <span className="text-text-muted text-xs">+</span>
                                                    )}
                                                </React.Fragment>
                                            ))}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>

                {/* Footer */}
                <div className="p-4 border-t border-dark-600 bg-dark-900/50">
                    <p className="text-xs text-text-muted text-center">
                        {t('shortcuts.pressToClose', { key: '' })} <kbd className="px-1.5 py-0.5 text-xs font-mono bg-dark-700 border border-dark-500 rounded">Escape</kbd>
                    </p>
                </div>
            </div>
        </div>
    );
}

export default KeyboardShortcuts;
