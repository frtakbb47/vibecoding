import React, { createContext, useContext, useMemo, useCallback } from 'react';
import { useLanguage } from './LanguageContext';

const ValidationContext = createContext();

// Validation rules
const VALIDATION_RULES = {
    personalInfo: {
        firstName: {
            required: true,
            label: 'First Name',
            labelDe: 'Vorname'
        },
        lastName: {
            required: true,
            label: 'Last Name',
            labelDe: 'Nachname'
        },
        taxId: {
            required: true,
            pattern: /^\d{11}$/,
            label: 'Tax ID (Steuer-ID)',
            labelDe: 'Steuer-ID',
            message: 'Tax ID must be exactly 11 digits',
            messageDe: 'Steuer-ID muss genau 11 Ziffern haben'
        },
        dateOfBirth: {
            required: true,
            label: 'Date of Birth',
            labelDe: 'Geburtsdatum'
        },
        address: {
            required: true,
            label: 'Address',
            labelDe: 'Adresse'
        }
    },
    employment: {
        employmentStatus: {
            required: true,
            label: 'Employment Status',
            labelDe: 'Beschäftigungsstatus'
        },
        grossIncome: {
            required: true,
            min: 0,
            label: 'Gross Income',
            labelDe: 'Bruttoeinkommen',
            message: 'Income must be a positive number',
            messageDe: 'Einkommen muss eine positive Zahl sein'
        }
    },
    deductions: {
        amount: {
            required: true,
            min: 0.01,
            label: 'Amount',
            labelDe: 'Betrag',
            message: 'Amount must be greater than 0',
            messageDe: 'Betrag muss größer als 0 sein'
        },
        category: {
            required: true,
            label: 'Category',
            labelDe: 'Kategorie'
        }
    }
};

// Warning thresholds for audit risk
const AUDIT_THRESHOLDS = {
    homeOffice: { max: 1260, warning: 'Home office exceeds €1,260 annual limit' },
    workEquipment: { max: 952, warning: 'Single equipment item over €952 may need depreciation' },
    travelExpenses: { ratio: 0.15, warning: 'Travel expenses seem high relative to income' },
    totalDeductions: { ratio: 0.35, warning: 'Total deductions are unusually high' }
};

export function ValidationProvider({ children, taxData }) {
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const validation = useMemo(() => {
        return validateTaxData(taxData, isGerman);
    }, [taxData, isGerman]);

    const validateField = useCallback((section, field, value) => {
        const rules = VALIDATION_RULES[section]?.[field];
        if (!rules) return { valid: true };

        const errors = [];

        if (rules.required && !value) {
            errors.push(isGerman
                ? `${rules.labelDe || rules.label} ist erforderlich`
                : `${rules.label} is required`
            );
        }

        if (rules.pattern && value && !rules.pattern.test(value)) {
            errors.push(isGerman ? rules.messageDe : rules.message);
        }

        if (rules.min !== undefined && value < rules.min) {
            errors.push(isGerman ? rules.messageDe : rules.message);
        }

        if (rules.max !== undefined && value > rules.max) {
            errors.push(isGerman ? rules.messageDe : rules.message);
        }

        return {
            valid: errors.length === 0,
            errors
        };
    }, [isGerman]);

    const value = {
        ...validation,
        validateField,
        isGerman
    };

    return (
        <ValidationContext.Provider value={value}>
            {children}
        </ValidationContext.Provider>
    );
}

export function useValidation() {
    const context = useContext(ValidationContext);
    if (!context) {
        return {
            isValid: true,
            errors: [],
            warnings: [],
            errorCount: 0,
            warningCount: 0,
            errorsBySection: {},
            validateField: () => ({ valid: true, errors: [] })
        };
    }
    return context;
}

function validateTaxData(taxData, isGerman) {
    if (!taxData) {
        return {
            isValid: false,
            errors: [isGerman ? 'Keine Daten vorhanden' : 'No data available'],
            warnings: [],
            errorCount: 1,
            warningCount: 0,
            errorsBySection: {}
        };
    }

    const errors = [];
    const warnings = [];
    const errorsBySection = {};

    // Validate personal info
    const personalErrors = [];
    const personalInfo = taxData.personalInfo || {};

    Object.entries(VALIDATION_RULES.personalInfo).forEach(([field, rules]) => {
        const value = personalInfo[field];
        if (rules.required && !value) {
            personalErrors.push({
                field,
                message: isGerman
                    ? `${rules.labelDe || rules.label} ist erforderlich`
                    : `${rules.label} is required`
            });
        }
        if (rules.pattern && value && !rules.pattern.test(value)) {
            personalErrors.push({
                field,
                message: isGerman ? rules.messageDe : rules.message
            });
        }
    });

    if (personalErrors.length > 0) {
        errorsBySection.personalInfo = personalErrors;
        errors.push(...personalErrors.map(e => e.message));
    }

    // Validate employment
    const employmentErrors = [];
    const employment = taxData.employment || {};

    Object.entries(VALIDATION_RULES.employment).forEach(([field, rules]) => {
        const value = employment[field];
        if (rules.required && !value && value !== 0) {
            employmentErrors.push({
                field,
                message: isGerman
                    ? `${rules.labelDe || rules.label} ist erforderlich`
                    : `${rules.label} is required`
            });
        }
        if (rules.min !== undefined && value < rules.min) {
            employmentErrors.push({
                field,
                message: isGerman ? rules.messageDe : rules.message
            });
        }
    });

    if (employmentErrors.length > 0) {
        errorsBySection.employment = employmentErrors;
        errors.push(...employmentErrors.map(e => e.message));
    }

    // Check for warnings (audit risks)
    const deductions = taxData.deductions || [];
    const grossIncome = employment.grossIncome || 0;

    // Home office check
    const homeOfficeTotal = deductions
        .filter(d => d.category === 'homeoffice' || d.name?.toLowerCase().includes('homeoffice'))
        .reduce((sum, d) => sum + (d.amount || 0), 0);

    if (homeOfficeTotal > AUDIT_THRESHOLDS.homeOffice.max) {
        warnings.push({
            type: 'audit',
            severity: 'high',
            message: isGerman
                ? `Homeoffice-Pauschale übersteigt das Jahreslimit von €${AUDIT_THRESHOLDS.homeOffice.max}`
                : AUDIT_THRESHOLDS.homeOffice.warning
        });
    }

    // Total deductions check
    const totalDeductions = deductions.reduce((sum, d) => sum + (d.amount || 0), 0);
    if (grossIncome > 0 && totalDeductions / grossIncome > AUDIT_THRESHOLDS.totalDeductions.ratio) {
        warnings.push({
            type: 'audit',
            severity: 'medium',
            message: isGerman
                ? 'Gesamtabzüge sind ungewöhnlich hoch im Verhältnis zum Einkommen'
                : AUDIT_THRESHOLDS.totalDeductions.warning
        });
    }

    // Check for high-value single items
    deductions.forEach(d => {
        if (d.amount > AUDIT_THRESHOLDS.workEquipment.max && d.category === 'equipment') {
            warnings.push({
                type: 'audit',
                severity: 'low',
                message: isGerman
                    ? `${d.name || 'Arbeitsmittel'} über €952 könnte Abschreibung erfordern`
                    : `${d.name || 'Equipment'} over €952 may need depreciation`
            });
        }
    });

    return {
        isValid: errors.length === 0,
        errors,
        warnings,
        errorCount: errors.length,
        warningCount: warnings.length,
        errorsBySection
    };
}

// Validation Panel Component
export function ValidationPanel({ onNavigate, className = '' }) {
    const { isValid, errors, warnings, errorCount, warningCount, errorsBySection } = useValidation();
    const { t } = useLanguage();

    if (isValid && warningCount === 0) {
        return (
            <div className={`bg-accent-success/10 border border-accent-success/30 rounded-xl p-4 ${className}`}>
                <div className="flex items-center gap-3">
                    <span className="text-2xl">✅</span>
                    <div>
                        <h3 className="font-semibold text-accent-success">
                            {t('validation.allGood') || 'All Good!'}
                        </h3>
                        <p className="text-sm text-text-secondary">
                            {t('validation.noIssues') || 'No issues found. Ready to export.'}
                        </p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={`bg-dark-800 border border-dark-600 rounded-xl overflow-hidden ${className}`}>
            <div className="p-4 border-b border-dark-600">
                <h3 className="font-semibold text-text-primary flex items-center gap-2">
                    <span>📋</span>
                    {t('validation.title') || 'Validation'}
                </h3>
            </div>

            <div className="max-h-64 overflow-y-auto">
                {/* Errors */}
                {errorCount > 0 && (
                    <div className="p-3 border-b border-dark-600">
                        <h4 className="text-sm font-medium text-accent-danger flex items-center gap-2 mb-2">
                            <span>❌</span>
                            {errorCount} {errorCount === 1 ? 'Error' : 'Errors'}
                        </h4>
                        <div className="space-y-1">
                            {Object.entries(errorsBySection).map(([section, sectionErrors]) => (
                                <div key={section}>
                                    {sectionErrors.map((err, idx) => (
                                        <button
                                            key={idx}
                                            onClick={() => onNavigate?.(section, err.field)}
                                            className="w-full text-left text-sm text-text-secondary hover:text-text-primary p-2 rounded hover:bg-dark-700 transition-colors"
                                        >
                                            {err.message}
                                        </button>
                                    ))}
                                </div>
                            ))}
                        </div>
                    </div>
                )}

                {/* Warnings */}
                {warningCount > 0 && (
                    <div className="p-3">
                        <h4 className="text-sm font-medium text-accent-warning flex items-center gap-2 mb-2">
                            <span>⚠️</span>
                            {warningCount} {warningCount === 1 ? 'Warning' : 'Warnings'}
                        </h4>
                        <div className="space-y-1">
                            {warnings.map((warning, idx) => (
                                <div
                                    key={idx}
                                    className={`text-sm p-2 rounded ${warning.severity === 'high'
                                        ? 'bg-accent-danger/10 text-accent-danger'
                                        : warning.severity === 'medium'
                                            ? 'bg-accent-warning/10 text-accent-warning'
                                            : 'bg-dark-700 text-text-secondary'
                                        }`}
                                >
                                    {warning.message}
                                </div>
                            ))}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}

// Inline Field Validation
export function FieldError({ section, field, value }) {
    const { validateField } = useValidation();
    const result = validateField(section, field, value);

    if (result.valid) return null;

    return (
        <div className="mt-1 text-xs text-accent-danger">
            {result.errors[0]}
        </div>
    );
}
