import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { useLanguage } from './LanguageContext';

const AccessibilityContext = createContext();

// Default accessibility settings
const DEFAULT_SETTINGS = {
    highContrast: false,
    reducedMotion: false,
    largeText: false,
    screenReaderAnnouncements: true,
    focusIndicators: true,
    keyboardNavigation: true
};

export function AccessibilityProvider({ children }) {
    const [settings, setSettings] = useState(() => {
        // Load from localStorage or use defaults
        const saved = localStorage.getItem('taxmini-accessibility');
        if (saved) {
            return { ...DEFAULT_SETTINGS, ...JSON.parse(saved) };
        }

        // Check system preferences
        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        const prefersHighContrast = window.matchMedia('(prefers-contrast: more)').matches;

        return {
            ...DEFAULT_SETTINGS,
            reducedMotion: prefersReducedMotion,
            highContrast: prefersHighContrast
        };
    });

    const [announcement, setAnnouncement] = useState('');

    // Apply settings to document
    useEffect(() => {
        const root = document.documentElement;

        // High contrast
        if (settings.highContrast) {
            root.classList.add('high-contrast');
        } else {
            root.classList.remove('high-contrast');
        }

        // Reduced motion
        if (settings.reducedMotion) {
            root.classList.add('reduced-motion');
        } else {
            root.classList.remove('reduced-motion');
        }

        // Large text
        if (settings.largeText) {
            root.classList.add('large-text');
        } else {
            root.classList.remove('large-text');
        }

        // Focus indicators
        if (settings.focusIndicators) {
            root.classList.add('focus-visible');
        } else {
            root.classList.remove('focus-visible');
        }

        // Save to localStorage
        localStorage.setItem('taxmini-accessibility', JSON.stringify(settings));
    }, [settings]);

    // Update a single setting
    const updateSetting = useCallback((key, value) => {
        setSettings(prev => ({ ...prev, [key]: value }));
    }, []);

    // Toggle a setting
    const toggleSetting = useCallback((key) => {
        setSettings(prev => ({ ...prev, [key]: !prev[key] }));
    }, []);

    // Reset to defaults
    const resetSettings = useCallback(() => {
        setSettings(DEFAULT_SETTINGS);
    }, []);

    // Announce to screen readers
    const announce = useCallback((message, priority = 'polite') => {
        if (settings.screenReaderAnnouncements) {
            setAnnouncement({ message, priority });
            // Clear after announcement
            setTimeout(() => setAnnouncement(''), 1000);
        }
    }, [settings.screenReaderAnnouncements]);

    const value = {
        settings,
        updateSetting,
        toggleSetting,
        resetSettings,
        announce
    };

    return (
        <AccessibilityContext.Provider value={value}>
            {children}
            {/* Screen reader live region */}
            <div
                role="status"
                aria-live={announcement.priority || 'polite'}
                aria-atomic="true"
                className="sr-only"
            >
                {announcement.message}
            </div>
        </AccessibilityContext.Provider>
    );
}

export function useAccessibility() {
    const context = useContext(AccessibilityContext);
    if (!context) {
        return {
            settings: DEFAULT_SETTINGS,
            updateSetting: () => { },
            toggleSetting: () => { },
            resetSettings: () => { },
            announce: () => { }
        };
    }
    return context;
}

// Accessibility Settings Panel
export function AccessibilityPanel({ className = '' }) {
    const { settings, toggleSetting, resetSettings } = useAccessibility();
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const settingsConfig = [
        {
            key: 'highContrast',
            icon: '🎨',
            label: isGerman ? 'Hoher Kontrast' : 'High Contrast',
            description: isGerman
                ? 'Erhöht Farbkontrast für bessere Lesbarkeit'
                : 'Increases color contrast for better readability'
        },
        {
            key: 'reducedMotion',
            icon: '🎬',
            label: isGerman ? 'Reduzierte Bewegung' : 'Reduced Motion',
            description: isGerman
                ? 'Minimiert Animationen und Übergänge'
                : 'Minimizes animations and transitions'
        },
        {
            key: 'largeText',
            icon: '🔤',
            label: isGerman ? 'Große Schrift' : 'Large Text',
            description: isGerman
                ? 'Vergrößert die Textgröße'
                : 'Increases text size'
        },
        {
            key: 'screenReaderAnnouncements',
            icon: '📢',
            label: isGerman ? 'Bildschirmleser-Meldungen' : 'Screen Reader Announcements',
            description: isGerman
                ? 'Wichtige Änderungen werden angesagt'
                : 'Important changes are announced'
        },
        {
            key: 'focusIndicators',
            icon: '🎯',
            label: isGerman ? 'Fokus-Indikatoren' : 'Focus Indicators',
            description: isGerman
                ? 'Zeigt deutlichen Fokusrahmen bei Tastaturnavigation'
                : 'Shows clear focus ring for keyboard navigation'
        },
        {
            key: 'keyboardNavigation',
            icon: '⌨️',
            label: isGerman ? 'Tastaturnavigation' : 'Keyboard Navigation',
            description: isGerman
                ? 'Aktiviert erweiterte Tastaturkürzel'
                : 'Enables enhanced keyboard shortcuts'
        }
    ];

    return (
        <div className={`bg-dark-800 border border-dark-600 rounded-xl overflow-hidden ${className}`}>
            {/* Header */}
            <div className="p-4 border-b border-dark-600">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <span className="text-xl">♿</span>
                        <h3 className="font-semibold text-text-primary">
                            {isGerman ? 'Barrierefreiheit' : 'Accessibility'}
                        </h3>
                    </div>
                    <button
                        onClick={resetSettings}
                        className="text-xs text-text-muted hover:text-text-secondary transition-colors"
                    >
                        {isGerman ? 'Zurücksetzen' : 'Reset'}
                    </button>
                </div>
            </div>

            {/* Settings */}
            <div className="p-4 space-y-3">
                {settingsConfig.map((config) => (
                    <button
                        key={config.key}
                        onClick={() => toggleSetting(config.key)}
                        className="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-dark-700 transition-colors text-left"
                        role="switch"
                        aria-checked={settings[config.key]}
                    >
                        <span className="text-xl">{config.icon}</span>
                        <div className="flex-1">
                            <div className="font-medium text-text-primary">{config.label}</div>
                            <div className="text-xs text-text-muted">{config.description}</div>
                        </div>
                        <div
                            className={`w-10 h-6 rounded-full transition-colors flex items-center ${settings[config.key] ? 'bg-accent-primary' : 'bg-dark-600'
                                }`}
                        >
                            <div
                                className={`w-4 h-4 rounded-full bg-white shadow transition-transform ${settings[config.key] ? 'translate-x-5' : 'translate-x-1'
                                    }`}
                            />
                        </div>
                    </button>
                ))}
            </div>

            {/* Keyboard Shortcuts Help */}
            <div className="p-4 border-t border-dark-600 bg-dark-900/50">
                <h4 className="text-sm font-medium text-text-muted mb-2">
                    {isGerman ? 'Tastaturkürzel' : 'Keyboard Shortcuts'}
                </h4>
                <div className="grid grid-cols-2 gap-2 text-xs">
                    <div className="flex items-center justify-between">
                        <span className="text-text-muted">Tab</span>
                        <span className="text-text-secondary">{isGerman ? 'Navigation' : 'Navigate'}</span>
                    </div>
                    <div className="flex items-center justify-between">
                        <span className="text-text-muted">Enter</span>
                        <span className="text-text-secondary">{isGerman ? 'Auswählen' : 'Select'}</span>
                    </div>
                    <div className="flex items-center justify-between">
                        <span className="text-text-muted">Esc</span>
                        <span className="text-text-secondary">{isGerman ? 'Schließen' : 'Close'}</span>
                    </div>
                    <div className="flex items-center justify-between">
                        <span className="text-text-muted">?</span>
                        <span className="text-text-secondary">{isGerman ? 'Hilfe' : 'Help'}</span>
                    </div>
                </div>
            </div>
        </div>
    );
}

// Skip to content link
export function SkipLink() {
    const { language } = useLanguage();
    const isGerman = language === 'de';

    return (
        <a
            href="#main-content"
            className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-accent-primary focus:text-white focus:rounded-lg"
        >
            {isGerman ? 'Zum Hauptinhalt springen' : 'Skip to main content'}
        </a>
    );
}

// Accessible icon button
export function IconButton({
    icon,
    label,
    onClick,
    className = '',
    disabled = false,
    ...props
}) {
    return (
        <button
            onClick={onClick}
            disabled={disabled}
            className={`p-2 rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-accent-primary focus:ring-offset-2 focus:ring-offset-dark-800 ${disabled ? 'opacity-50 cursor-not-allowed' : 'hover:bg-dark-700'
                } ${className}`}
            aria-label={label}
            title={label}
            {...props}
        >
            {icon}
        </button>
    );
}

// Focus trap for modals
export function FocusTrap({ children, active = true }) {
    const trapRef = React.useRef(null);

    useEffect(() => {
        if (!active || !trapRef.current) return;

        const trap = trapRef.current;
        const focusableElements = trap.querySelectorAll(
            'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        const firstElement = focusableElements[0];
        const lastElement = focusableElements[focusableElements.length - 1];

        const handleKeyDown = (e) => {
            if (e.key !== 'Tab') return;

            if (e.shiftKey) {
                if (document.activeElement === firstElement) {
                    e.preventDefault();
                    lastElement?.focus();
                }
            } else {
                if (document.activeElement === lastElement) {
                    e.preventDefault();
                    firstElement?.focus();
                }
            }
        };

        trap.addEventListener('keydown', handleKeyDown);
        firstElement?.focus();

        return () => trap.removeEventListener('keydown', handleKeyDown);
    }, [active]);

    return <div ref={trapRef}>{children}</div>;
}

// Visually hidden text for screen readers
export function VisuallyHidden({ children }) {
    return <span className="sr-only">{children}</span>;
}
