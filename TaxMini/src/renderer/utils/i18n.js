// Internationalization (i18n) system for TaxMini
// Supports English and German

export const translations = {
    en: {
        // Welcome Screen
        welcome: {
            subtitle: 'German tax returns made simple',
            taxYear: 'Tax Year',
            basicAllowance: 'Basic Allowance',
            startButton: 'Start Tax Return',
            features: {
                private: '100% Private',
                privateDesc: 'Stays on your device',
                fast: '5 Minutes',
                fastDesc: 'Quick & easy',
                free: 'Free',
                freeDesc: 'No hidden costs',
            },
            audience: {
                students: 'Students',
                employees: 'Employees',
                expats: 'Expats',
            },
            stats: {
                avgRefund: 'avg. refund',
                getMoneyBack: 'get money back',
                source: 'Based on German Federal Statistical Office data',
            },
            keyboardHint: 'Press {key} to start',
        },
        // Header
        header: {
            tagline: 'Privacy-First Tax Assistant',
            taxYear: 'Tax Year',
            newSession: 'New Session',
            setup: 'Setup',
            documents: 'Documents',
            analysis: 'AI Analysis',
            saved: 'Saved',
            offline: 'Offline',
        },
        // Common
        common: {
            next: 'Next',
            back: 'Back',
            save: 'Save',
            cancel: 'Cancel',
            close: 'Close',
            loading: 'Loading...',
            error: 'Error',
            success: 'Success',
            search: 'Search',
            filter: 'Filter',
            all: 'All',
            new: 'New',
            edit: 'Edit',
            delete: 'Delete',
            confirm: 'Confirm',
            processing: 'Processing...',
            retry: 'Retry',
        },
        // Footer / Credits
        credits: {
            madeBy: 'Made by',
            builtWith: 'Built with',
            and: 'and',
            model: 'Claude Opus 4.5',
        },
        // Wizard
        wizard: {
            step1Title: 'Tax Year',
            step1Desc: 'Which year are you filing for?',
            step2Title: 'Personal Status',
            step2Desc: 'Tell us about your situation',
            step3Title: 'Income Estimate',
            step3Desc: 'Approximate numbers help us prepare better',
            step4Title: 'Employment Details',
            step4Desc: 'Your work situation in Germany',
            step5Title: 'Potential Deductions',
            step5Desc: 'Common expenses you might deduct',
            step6Title: 'Documents Checklist',
            step6Desc: 'What you\'ll need to prepare',
            userType: 'I am a...',
            student: 'Student',
            employee: 'Employee',
            expat: 'Expat',
            single: 'Single',
            married: 'Married',
            separated: 'Separated',
            maritalStatus: 'Marital Status',
            hasChildren: 'I have children',
            isStudent: 'I\'m a student',
            isExpat: 'I\'m an expat (moved to Germany from abroad)',
            churchTax: 'I pay church tax',
            arrivalYear: 'When did you move to Germany?',
            grossIncome: 'Estimated Gross Income',
            taxPaid: 'Estimated Tax Paid',
            tip: 'Tip',
            tipRetroactive: 'You can file your tax return up to 4 years retroactively',
        },
        // Workspace
        workspace: {
            documents: 'Documents',
            checklist: 'Checklist',
            deductions: 'Deductions',
            calendar: 'Calendar',
            expenses: 'Expenses',
            results: 'Results',
            overview: 'Overview',
            advisor: 'Advisor',
            dropFiles: 'Drop files here',
            orClick: 'or click to browse',
            supportedFormats: 'Supports PDF, images (JPG, PNG)',
            noDocuments: 'No documents yet',
            addDocuments: 'Add your tax documents to get started',
        },
        // Deductions
        deductions: {
            title: 'Deduction Optimizer',
            subtitle: 'Find deductions you might be missing',
            potential: 'Potential Savings',
            maxAmount: 'up to',
            claimed: 'Claimed',
            notClaimed: 'Not Claimed',
            filterAll: 'All',
            filterNew: 'New 2026',
            filterWork: 'Work Expenses',
            filterSpecial: 'Special',
        },
        // Calendar
        calendar: {
            title: 'Tax Calendar',
            subtitle: 'Important deadlines for your tax return',
            upcoming: 'Upcoming',
            important: 'Important',
            daysLeft: 'days left',
            today: 'Today',
            overdue: 'Overdue',
        },
        // Tips
        tips: {
            title: 'Quick Tips',
            general: 'General',
            students: 'Students',
            expats: 'Expats',
        },
        // Keyboard shortcuts
        shortcuts: {
            title: 'Keyboard Shortcuts',
            general: 'General',
            documents: 'Documents',
            navigation: 'Navigation',
            newTaxReturn: 'Start new tax return',
            saveSession: 'Save session',
            showShortcuts: 'Show keyboard shortcuts',
            closeModal: 'Close modal / Go back',
            openFile: 'Open file dialog',
            paste: 'Paste (auto-switches to response tab)',
            prevStep: 'Previous step (in wizard)',
            nextStep: 'Next step (in wizard)',
            confirmContinue: 'Confirm / Continue',
            pressToClose: 'Press {key} to close',
        },
        // Errors
        errors: {
            title: 'Something went wrong',
            description: 'An error occurred. Please try again.',
            reload: 'Reload App',
            goBack: 'Go Back',
            offline: 'You are currently offline',
            offlineDesc: 'Some features may not work without an internet connection.',
        },
        // Export
        export: {
            title: 'Export Results',
            format: 'Format',
            download: 'Download',
            copy: 'Copy to Clipboard',
            copied: 'Copied!',
        },
        // What's New
        whatsNew: {
            title: 'What\'s New in 2026',
            showMore: 'Show more',
            showLess: 'Show less',
        },
        // Progress
        progress: {
            title: 'Your Progress',
            complete: 'Complete',
            continue: 'Continue',
            sections: {
                personalInfo: 'Personal Info',
                employment: 'Employment',
                deductions: 'Deductions',
                documents: 'Documents',
                review: 'Review',
            },
        },
        // Validation
        validation: {
            title: 'Validation',
            allGood: 'All Good!',
            noIssues: 'No issues found. Ready to export.',
            errors: 'Errors',
            warnings: 'Warnings',
            required: 'Required',
        },
        // Audit Risk
        auditRisk: {
            title: 'Audit Risk',
            low: 'Low Risk',
            medium: 'Moderate Risk',
            high: 'High Risk',
            factors: 'Risk Factors',
            recommendations: 'Recommendations',
        },
        // Achievements
        achievements: {
            title: 'Achievements',
            unlocked: 'Unlocked',
            locked: 'Locked',
            points: 'points',
            streak: 'Day Streak',
            nextRank: 'Next rank',
        },
        // PDF Export
        pdfExport: {
            title: 'PDF Export',
            selectForms: 'Select the forms you want to export',
            summary: 'Summary Report',
            generating: 'Generating...',
            export: 'Export',
        },
        // ELSTER
        elster: {
            title: 'ELSTER',
            subtitle: 'Electronic Tax Filing',
            login: 'Login',
            review: 'Review',
            submit: 'Submit',
            success: 'Successfully Submitted!',
            reference: 'Reference Number',
        },
        // Accessibility
        accessibility: {
            title: 'Accessibility',
            highContrast: 'High Contrast',
            reducedMotion: 'Reduced Motion',
            largeText: 'Large Text',
            screenReader: 'Screen Reader Announcements',
            focusIndicators: 'Focus Indicators',
            skipToContent: 'Skip to main content',
        },
        // Onboarding
        onboarding: {
            skip: 'Skip',
            next: 'Next',
            getStarted: 'Get Started!',
            welcome: 'Welcome to TaxMini!',
        },
        // Attachments
        attachments: {
            title: 'Attachments',
            dragDrop: 'Drag receipts here or click',
            maxSize: 'Max',
            remove: 'Remove',
            open: 'Open',
        },
    },
    de: {
        // Welcome Screen
        welcome: {
            subtitle: 'Deutsche Steuererklärung leicht gemacht',
            taxYear: 'Steuerjahr',
            basicAllowance: 'Grundfreibetrag',
            startButton: 'Steuererklärung starten',
            features: {
                private: '100% Privat',
                privateDesc: 'Bleibt auf deinem Gerät',
                fast: '5 Minuten',
                fastDesc: 'Schnell & einfach',
                free: 'Kostenlos',
                freeDesc: 'Keine versteckten Kosten',
            },
            audience: {
                students: 'Studenten',
                employees: 'Angestellte',
                expats: 'Expats',
            },
            stats: {
                avgRefund: 'Ø Erstattung',
                getMoneyBack: 'bekommen Geld zurück',
                source: 'Basierend auf Daten des Statistischen Bundesamts',
            },
            keyboardHint: 'Drücke {key} zum Starten',
        },
        // Header
        header: {
            tagline: 'Privatsphäre-erster Steuerassistent',
            taxYear: 'Steuerjahr',
            newSession: 'Neue Sitzung',
            setup: 'Einrichtung',
            documents: 'Dokumente',
            analysis: 'KI-Analyse',
            saved: 'Gespeichert',
            offline: 'Offline',
        },
        // Common
        common: {
            next: 'Weiter',
            back: 'Zurück',
            save: 'Speichern',
            cancel: 'Abbrechen',
            close: 'Schließen',
            loading: 'Laden...',
            error: 'Fehler',
            success: 'Erfolg',
            search: 'Suchen',
            filter: 'Filtern',
            all: 'Alle',
            new: 'Neu',
            edit: 'Bearbeiten',
            delete: 'Löschen',
            confirm: 'Bestätigen',
            processing: 'Verarbeitung...',
            retry: 'Erneut versuchen',
        },
        // Footer / Credits
        credits: {
            madeBy: 'Erstellt von',
            builtWith: 'Entwickelt mit',
            and: 'und',
            model: 'Claude Opus 4.5',
        },
        // Wizard
        wizard: {
            step1Title: 'Steuerjahr',
            step1Desc: 'Für welches Jahr erstellst du die Erklärung?',
            step2Title: 'Persönlicher Status',
            step2Desc: 'Erzähl uns von deiner Situation',
            step3Title: 'Einkommensschätzung',
            step3Desc: 'Ungefähre Zahlen helfen uns bei der Vorbereitung',
            step4Title: 'Beschäftigungsdetails',
            step4Desc: 'Deine Arbeitssituation in Deutschland',
            step5Title: 'Mögliche Absetzungen',
            step5Desc: 'Übliche Ausgaben, die du absetzen könntest',
            step6Title: 'Dokumenten-Checkliste',
            step6Desc: 'Was du vorbereiten musst',
            userType: 'Ich bin...',
            student: 'Student/in',
            employee: 'Angestellte/r',
            expat: 'Expat',
            single: 'Ledig',
            married: 'Verheiratet',
            separated: 'Getrennt',
            maritalStatus: 'Familienstand',
            hasChildren: 'Ich habe Kinder',
            isStudent: 'Ich bin Student/in',
            isExpat: 'Ich bin Expat (aus dem Ausland nach Deutschland gezogen)',
            churchTax: 'Ich zahle Kirchensteuer',
            arrivalYear: 'Wann bist du nach Deutschland gezogen?',
            grossIncome: 'Geschätztes Bruttoeinkommen',
            taxPaid: 'Geschätzte gezahlte Steuern',
            tip: 'Tipp',
            tipRetroactive: 'Du kannst deine Steuererklärung bis zu 4 Jahre rückwirkend abgeben',
        },
        // Workspace
        workspace: {
            documents: 'Dokumente',
            checklist: 'Checkliste',
            deductions: 'Absetzungen',
            calendar: 'Kalender',
            expenses: 'Ausgaben',
            results: 'Ergebnisse',
            overview: 'Übersicht',
            advisor: 'Berater',
            dropFiles: 'Dateien hier ablegen',
            orClick: 'oder klicken zum Durchsuchen',
            supportedFormats: 'Unterstützt PDF, Bilder (JPG, PNG)',
            noDocuments: 'Noch keine Dokumente',
            addDocuments: 'Füge deine Steuerunterlagen hinzu, um zu beginnen',
        },
        // Deductions
        deductions: {
            title: 'Absetzungs-Optimierer',
            subtitle: 'Finde Absetzungen, die dir vielleicht entgehen',
            potential: 'Potenzielle Ersparnis',
            maxAmount: 'bis zu',
            claimed: 'Beansprucht',
            notClaimed: 'Nicht beansprucht',
            filterAll: 'Alle',
            filterNew: 'Neu 2026',
            filterWork: 'Arbeitskosten',
            filterSpecial: 'Sonstiges',
        },
        // Calendar
        calendar: {
            title: 'Steuerkalender',
            subtitle: 'Wichtige Fristen für deine Steuererklärung',
            upcoming: 'Bevorstehend',
            important: 'Wichtig',
            daysLeft: 'Tage übrig',
            today: 'Heute',
            overdue: 'Überfällig',
        },
        // Tips
        tips: {
            title: 'Schnelle Tipps',
            general: 'Allgemein',
            students: 'Studenten',
            expats: 'Expats',
        },
        // Keyboard shortcuts
        shortcuts: {
            title: 'Tastenkürzel',
            general: 'Allgemein',
            documents: 'Dokumente',
            navigation: 'Navigation',
            newTaxReturn: 'Neue Steuererklärung starten',
            saveSession: 'Sitzung speichern',
            showShortcuts: 'Tastenkürzel anzeigen',
            closeModal: 'Modal schließen / Zurück',
            openFile: 'Dateidialog öffnen',
            paste: 'Einfügen (wechselt zum Antwort-Tab)',
            prevStep: 'Vorheriger Schritt (im Assistenten)',
            nextStep: 'Nächster Schritt (im Assistenten)',
            confirmContinue: 'Bestätigen / Weiter',
            pressToClose: 'Drücke {key} zum Schließen',
        },
        // Errors
        errors: {
            title: 'Etwas ist schief gelaufen',
            description: 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.',
            reload: 'App neu laden',
            goBack: 'Zurück',
            offline: 'Du bist derzeit offline',
            offlineDesc: 'Einige Funktionen funktionieren ohne Internetverbindung möglicherweise nicht.',
        },
        // Export
        export: {
            title: 'Ergebnisse exportieren',
            format: 'Format',
            download: 'Herunterladen',
            copy: 'In Zwischenablage kopieren',
            copied: 'Kopiert!',
        },
        // What's New
        whatsNew: {
            title: 'Neu in 2026',
            showMore: 'Mehr anzeigen',
            showLess: 'Weniger anzeigen',
        },
        // Progress
        progress: {
            title: 'Dein Fortschritt',
            complete: 'Abgeschlossen',
            continue: 'Fortsetzen',
            sections: {
                personalInfo: 'Persönliche Daten',
                employment: 'Beschäftigung',
                deductions: 'Absetzungen',
                documents: 'Dokumente',
                review: 'Überprüfung',
            },
        },
        // Validation
        validation: {
            title: 'Validierung',
            allGood: 'Alles in Ordnung!',
            noIssues: 'Keine Probleme gefunden. Bereit zum Export.',
            errors: 'Fehler',
            warnings: 'Warnungen',
            required: 'Erforderlich',
        },
        // Audit Risk
        auditRisk: {
            title: 'Prüfungsrisiko',
            low: 'Niedriges Risiko',
            medium: 'Mittleres Risiko',
            high: 'Hohes Risiko',
            factors: 'Risikofaktoren',
            recommendations: 'Empfehlungen',
        },
        // Achievements
        achievements: {
            title: 'Erfolge',
            unlocked: 'Freigeschaltet',
            locked: 'Gesperrt',
            points: 'Punkte',
            streak: 'Tage-Serie',
            nextRank: 'Nächster Rang',
        },
        // PDF Export
        pdfExport: {
            title: 'PDF Export',
            selectForms: 'Wähle die Formulare zum Exportieren',
            summary: 'Zusammenfassungsbericht',
            generating: 'Wird erstellt...',
            export: 'Exportieren',
        },
        // ELSTER
        elster: {
            title: 'ELSTER',
            subtitle: 'Elektronische Steuererklärung',
            login: 'Anmelden',
            review: 'Überprüfen',
            submit: 'Absenden',
            success: 'Erfolgreich übermittelt!',
            reference: 'Referenznummer',
        },
        // Accessibility
        accessibility: {
            title: 'Barrierefreiheit',
            highContrast: 'Hoher Kontrast',
            reducedMotion: 'Reduzierte Bewegung',
            largeText: 'Großer Text',
            screenReader: 'Screenreader-Ansagen',
            focusIndicators: 'Fokus-Indikatoren',
            skipToContent: 'Zum Hauptinhalt springen',
        },
        // Onboarding
        onboarding: {
            skip: 'Überspringen',
            next: 'Weiter',
            getStarted: 'Los geht\'s!',
            welcome: 'Willkommen bei TaxMini!',
        },
        // Attachments
        attachments: {
            title: 'Anhänge',
            dragDrop: 'Belege hierher ziehen oder klicken',
            maxSize: 'Max',
            remove: 'Entfernen',
            open: 'Öffnen',
        },
    },
};

// Get nested translation by dot notation path
export function getTranslation(lang, path) {
    const keys = path.split('.');
    let result = translations[lang];

    for (const key of keys) {
        if (result && typeof result === 'object' && key in result) {
            result = result[key];
        } else {
            // Fallback to English if key not found
            result = translations.en;
            for (const k of keys) {
                if (result && typeof result === 'object' && k in result) {
                    result = result[k];
                } else {
                    return path; // Return path as fallback
                }
            }
            break;
        }
    }

    return result;
}

// Helper to replace placeholders like {key}
export function formatTranslation(text, replacements = {}) {
    let result = text;
    for (const [key, value] of Object.entries(replacements)) {
        result = result.replace(`{${key}}`, value);
    }
    return result;
}

// Supported languages
export const SUPPORTED_LANGUAGES = [
    { code: 'en', name: 'English', shortName: 'EN' },
    { code: 'de', name: 'Deutsch', shortName: 'DE' },
];

// Default language
export const DEFAULT_LANGUAGE = 'en';
