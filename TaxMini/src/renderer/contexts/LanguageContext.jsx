import React, { createContext, useContext, useState, useEffect } from 'react';
import { translations, getTranslation, formatTranslation, DEFAULT_LANGUAGE, SUPPORTED_LANGUAGES } from '../utils/i18n';

const LanguageContext = createContext(null);

export function LanguageProvider({ children }) {
    const [language, setLanguage] = useState(() => {
        // Try to load from localStorage or use browser language
        if (typeof window !== 'undefined') {
            const saved = localStorage.getItem('taxmini-language');
            if (saved && SUPPORTED_LANGUAGES.some(l => l.code === saved)) {
                return saved;
            }
            // Check browser language
            const browserLang = navigator.language?.split('-')[0];
            if (SUPPORTED_LANGUAGES.some(l => l.code === browserLang)) {
                return browserLang;
            }
        }
        return DEFAULT_LANGUAGE;
    });

    // Save language preference
    useEffect(() => {
        localStorage.setItem('taxmini-language', language);
    }, [language]);

    // Translation function
    const t = (path, replacements = {}) => {
        const text = getTranslation(language, path);
        if (typeof text === 'string' && Object.keys(replacements).length > 0) {
            return formatTranslation(text, replacements);
        }
        return text;
    };

    // Switch language
    const switchLanguage = (langCode) => {
        if (SUPPORTED_LANGUAGES.some(l => l.code === langCode)) {
            setLanguage(langCode);
        }
    };

    // Toggle between languages
    const toggleLanguage = () => {
        const currentIndex = SUPPORTED_LANGUAGES.findIndex(l => l.code === language);
        const nextIndex = (currentIndex + 1) % SUPPORTED_LANGUAGES.length;
        setLanguage(SUPPORTED_LANGUAGES[nextIndex].code);
    };

    const value = {
        language,
        setLanguage: switchLanguage,
        toggleLanguage,
        t,
        languages: SUPPORTED_LANGUAGES,
        currentLanguage: SUPPORTED_LANGUAGES.find(l => l.code === language),
    };

    return (
        <LanguageContext.Provider value={value}>
            {children}
        </LanguageContext.Provider>
    );
}

export function useLanguage() {
    const context = useContext(LanguageContext);
    if (!context) {
        throw new Error('useLanguage must be used within a LanguageProvider');
    }
    return context;
}

// Language Switch Button Component
export function LanguageSwitch({ className = '' }) {
    const { language, toggleLanguage } = useLanguage();

    return (
        <button
            onClick={toggleLanguage}
            className={`px-3 py-1.5 rounded-lg bg-dark-800 border border-dark-700 hover:border-dark-500 hover:bg-dark-700 transition-all text-sm font-bold text-text-primary ${className}`}
            title={language === 'en' ? 'Auf Deutsch wechseln' : 'Switch to English'}
        >
            {language === 'en' ? 'EN' : 'DE'}
        </button>
    );
}

export default LanguageContext;
