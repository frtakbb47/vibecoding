import React, { createContext, useContext, useState, useCallback, useEffect, useRef } from 'react';
import { useLanguage } from './LanguageContext';

const SearchContext = createContext();

// Searchable content types
const SEARCHABLE_TYPES = {
    DEDUCTION: 'deduction',
    CATEGORY: 'category',
    HELP: 'help',
    SETTING: 'setting',
    ACTION: 'action'
};

// Built-in help topics
const HELP_TOPICS = [
    { id: 'werbungskosten', title: 'Werbungskosten', titleEn: 'Work-related Expenses', description: 'Costs directly related to your employment', category: 'help' },
    { id: 'homeoffice', title: 'Homeoffice-Pauschale', titleEn: 'Home Office Allowance', description: '€6/day up to €1,260/year (2026)', category: 'help' },
    { id: 'pendlerpauschale', title: 'Pendlerpauschale', titleEn: 'Commuter Allowance', description: '€0.30/km first 20km, €0.38/km beyond', category: 'help' },
    { id: 'sonderausgaben', title: 'Sonderausgaben', titleEn: 'Special Expenses', description: 'Insurance, donations, church tax', category: 'help' },
    { id: 'handwerker', title: 'Handwerkerleistungen', titleEn: 'Craftsman Services', description: '20% of labor costs, max €1,200/year', category: 'help' },
    { id: 'haushalt', title: 'Haushaltsnahe Dienstleistungen', titleEn: 'Household Services', description: '20% of costs, max €4,000/year', category: 'help' },
    { id: 'riester', title: 'Riester-Rente', titleEn: 'Riester Pension', description: 'Up to €2,100 deductible', category: 'help' },
    { id: 'krankheit', title: 'Krankheitskosten', titleEn: 'Medical Expenses', description: 'Above reasonable burden threshold', category: 'help' },
    { id: 'steuerklasse', title: 'Steuerklasse', titleEn: 'Tax Class', description: 'Tax brackets I-VI based on status', category: 'help' },
    { id: 'grundfreibetrag', title: 'Grundfreibetrag', titleEn: 'Basic Allowance', description: '€12,096 tax-free for 2026', category: 'help' },
];

// Common deduction categories
const DEDUCTION_CATEGORIES = [
    { id: 'commute', title: 'Fahrtkosten', titleEn: 'Commuting Costs', icon: '🚗', category: 'category' },
    { id: 'homeoffice', title: 'Homeoffice', titleEn: 'Home Office', icon: '🏠', category: 'category' },
    { id: 'equipment', title: 'Arbeitsmittel', titleEn: 'Work Equipment', icon: '💻', category: 'category' },
    { id: 'education', title: 'Weiterbildung', titleEn: 'Education', icon: '📚', category: 'category' },
    { id: 'insurance', title: 'Versicherungen', titleEn: 'Insurance', icon: '🛡️', category: 'category' },
    { id: 'donations', title: 'Spenden', titleEn: 'Donations', icon: '❤️', category: 'category' },
    { id: 'medical', title: 'Gesundheit', titleEn: 'Medical', icon: '🏥', category: 'category' },
    { id: 'household', title: 'Haushalt', titleEn: 'Household', icon: '🏡', category: 'category' },
];

// Quick actions
const QUICK_ACTIONS = [
    { id: 'add-deduction', title: 'Neue Abzugsmöglichkeit hinzufügen', titleEn: 'Add New Deduction', icon: '➕', action: 'addDeduction', category: 'action' },
    { id: 'export-pdf', title: 'Als PDF exportieren', titleEn: 'Export as PDF', icon: '📄', action: 'exportPdf', category: 'action' },
    { id: 'preview', title: 'Vorschau anzeigen', titleEn: 'Show Preview', icon: '👁️', action: 'preview', category: 'action' },
    { id: 'validate', title: 'Daten überprüfen', titleEn: 'Validate Data', icon: '✅', action: 'validate', category: 'action' },
    { id: 'save', title: 'Speichern', titleEn: 'Save', icon: '💾', action: 'save', category: 'action' },
    { id: 'settings', title: 'Einstellungen', titleEn: 'Settings', icon: '⚙️', action: 'settings', category: 'action' },
];

export function SearchProvider({ children, deductions = [], onAction }) {
    const [isOpen, setIsOpen] = useState(false);
    const [query, setQuery] = useState('');
    const [results, setResults] = useState([]);
    const [selectedIndex, setSelectedIndex] = useState(0);

    const { language } = useLanguage();
    const isGerman = language === 'de';

    // Build searchable items
    const searchableItems = useCallback(() => {
        const items = [];

        // Add user's deductions
        deductions.forEach(d => {
            items.push({
                id: `deduction-${d.id}`,
                type: SEARCHABLE_TYPES.DEDUCTION,
                title: d.name || d.description,
                description: `€${d.amount?.toLocaleString() || 0}`,
                icon: '📝',
                data: d
            });
        });

        // Add categories
        DEDUCTION_CATEGORIES.forEach(c => {
            items.push({
                id: `category-${c.id}`,
                type: SEARCHABLE_TYPES.CATEGORY,
                title: isGerman ? c.title : c.titleEn,
                icon: c.icon,
                data: c
            });
        });

        // Add help topics
        HELP_TOPICS.forEach(h => {
            items.push({
                id: `help-${h.id}`,
                type: SEARCHABLE_TYPES.HELP,
                title: isGerman ? h.title : h.titleEn,
                description: h.description,
                icon: '❓',
                data: h
            });
        });

        // Add quick actions
        QUICK_ACTIONS.forEach(a => {
            items.push({
                id: `action-${a.id}`,
                type: SEARCHABLE_TYPES.ACTION,
                title: isGerman ? a.title : a.titleEn,
                icon: a.icon,
                action: a.action,
                data: a
            });
        });

        return items;
    }, [deductions, isGerman]);

    // Search function
    const search = useCallback((q) => {
        if (!q.trim()) {
            // Show recent/suggested items when query is empty
            setResults(QUICK_ACTIONS.slice(0, 4).map(a => ({
                id: `action-${a.id}`,
                type: SEARCHABLE_TYPES.ACTION,
                title: isGerman ? a.title : a.titleEn,
                icon: a.icon,
                action: a.action,
                data: a
            })));
            return;
        }

        const items = searchableItems();
        const lowerQuery = q.toLowerCase();

        const matches = items.filter(item => {
            const titleMatch = item.title?.toLowerCase().includes(lowerQuery);
            const descMatch = item.description?.toLowerCase().includes(lowerQuery);
            return titleMatch || descMatch;
        });

        // Sort by relevance (exact matches first)
        matches.sort((a, b) => {
            const aExact = a.title?.toLowerCase().startsWith(lowerQuery) ? 0 : 1;
            const bExact = b.title?.toLowerCase().startsWith(lowerQuery) ? 0 : 1;
            return aExact - bExact;
        });

        setResults(matches.slice(0, 10));
        setSelectedIndex(0);
    }, [searchableItems, isGerman]);

    // Handle query changes
    useEffect(() => {
        search(query);
    }, [query, search]);

    // Keyboard navigation
    useEffect(() => {
        const handleKeyDown = (e) => {
            // Open search with Ctrl+K or Cmd+K
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                e.preventDefault();
                setIsOpen(true);
                return;
            }

            if (!isOpen) return;

            switch (e.key) {
                case 'Escape':
                    setIsOpen(false);
                    setQuery('');
                    break;
                case 'ArrowDown':
                    e.preventDefault();
                    setSelectedIndex(i => Math.min(i + 1, results.length - 1));
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    setSelectedIndex(i => Math.max(i - 1, 0));
                    break;
                case 'Enter':
                    e.preventDefault();
                    if (results[selectedIndex]) {
                        handleSelect(results[selectedIndex]);
                    }
                    break;
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [isOpen, results, selectedIndex]);

    const handleSelect = (item) => {
        if (item.action && onAction) {
            onAction(item.action, item.data);
        }
        setIsOpen(false);
        setQuery('');
    };

    const value = {
        isOpen,
        setIsOpen,
        query,
        setQuery,
        results,
        selectedIndex,
        setSelectedIndex,
        handleSelect,
        open: () => setIsOpen(true),
        close: () => {
            setIsOpen(false);
            setQuery('');
        }
    };

    return (
        <SearchContext.Provider value={value}>
            {children}
        </SearchContext.Provider>
    );
}

export function useSearch() {
    const context = useContext(SearchContext);
    if (!context) {
        return {
            isOpen: false,
            setIsOpen: () => { },
            query: '',
            setQuery: () => { },
            results: [],
            selectedIndex: 0,
            setSelectedIndex: () => { },
            handleSelect: () => { },
            open: () => { },
            close: () => { }
        };
    }
    return context;
}

// Search Modal Component
export function SearchModal() {
    const {
        isOpen,
        close,
        query,
        setQuery,
        results,
        selectedIndex,
        setSelectedIndex,
        handleSelect
    } = useSearch();
    const inputRef = useRef(null);
    const { t } = useLanguage();

    useEffect(() => {
        if (isOpen && inputRef.current) {
            inputRef.current.focus();
        }
    }, [isOpen]);

    if (!isOpen) return null;

    const typeLabels = {
        deduction: 'Deduction',
        category: 'Category',
        help: 'Help',
        setting: 'Setting',
        action: 'Action'
    };

    return (
        <div className="fixed inset-0 z-50 flex items-start justify-center pt-[15vh]">
            {/* Backdrop */}
            <div
                className="absolute inset-0 bg-black/60 backdrop-blur-sm"
                onClick={close}
            />

            {/* Modal */}
            <div className="relative w-full max-w-xl bg-dark-800 border border-dark-600 rounded-xl shadow-2xl overflow-hidden animate-scale-in">
                {/* Search Input */}
                <div className="flex items-center gap-3 px-4 py-3 border-b border-dark-600">
                    <svg className="w-5 h-5 text-text-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <input
                        ref={inputRef}
                        type="text"
                        value={query}
                        onChange={(e) => setQuery(e.target.value)}
                        placeholder={t('common.search') || 'Search...'}
                        className="flex-1 bg-transparent text-text-primary placeholder-text-muted focus:outline-none"
                    />
                    <kbd className="px-2 py-1 text-xs bg-dark-700 text-text-muted rounded">ESC</kbd>
                </div>

                {/* Results */}
                <div className="max-h-80 overflow-y-auto">
                    {results.length === 0 ? (
                        <div className="px-4 py-8 text-center text-text-muted">
                            {query ? 'No results found' : 'Start typing to search...'}
                        </div>
                    ) : (
                        <div className="py-2">
                            {results.map((result, index) => (
                                <button
                                    key={result.id}
                                    onClick={() => handleSelect(result)}
                                    onMouseEnter={() => setSelectedIndex(index)}
                                    className={`w-full flex items-center gap-3 px-4 py-2 text-left transition-colors ${index === selectedIndex
                                        ? 'bg-accent-primary/20 text-text-primary'
                                        : 'text-text-secondary hover:bg-dark-700'
                                        }`}
                                >
                                    <span className="text-lg">{result.icon}</span>
                                    <div className="flex-1 min-w-0">
                                        <div className="font-medium truncate">{result.title}</div>
                                        {result.description && (
                                            <div className="text-xs text-text-muted truncate">
                                                {result.description}
                                            </div>
                                        )}
                                    </div>
                                    <span className="text-xs text-text-muted capitalize">
                                        {typeLabels[result.type]}
                                    </span>
                                </button>
                            ))}
                        </div>
                    )}
                </div>

                {/* Footer */}
                <div className="flex items-center gap-4 px-4 py-2 border-t border-dark-600 text-xs text-text-muted">
                    <span className="flex items-center gap-1">
                        <kbd className="px-1.5 py-0.5 bg-dark-700 rounded">↑↓</kbd>
                        Navigate
                    </span>
                    <span className="flex items-center gap-1">
                        <kbd className="px-1.5 py-0.5 bg-dark-700 rounded">↵</kbd>
                        Select
                    </span>
                    <span className="flex items-center gap-1">
                        <kbd className="px-1.5 py-0.5 bg-dark-700 rounded">Ctrl</kbd>
                        <kbd className="px-1.5 py-0.5 bg-dark-700 rounded">K</kbd>
                        Open
                    </span>
                </div>
            </div>
        </div>
    );
}

// Search Button for Header
export function SearchButton({ className = '' }) {
    const { open } = useSearch();
    const { t } = useLanguage();

    return (
        <button
            onClick={open}
            className={`flex items-center gap-2 px-3 py-1.5 bg-dark-700 hover:bg-dark-600 border border-dark-500 rounded-lg text-text-secondary hover:text-text-primary transition-colors ${className}`}
        >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <span className="text-sm hidden sm:inline">{t('common.search') || 'Search'}</span>
            <kbd className="hidden sm:inline px-1.5 py-0.5 text-xs bg-dark-600 rounded">⌘K</kbd>
        </button>
    );
}
