import React, { createContext, useContext, useMemo } from 'react';

const ProgressContext = createContext();

// Define completion requirements for each section
const COMPLETION_REQUIREMENTS = {
    personalInfo: {
        weight: 20,
        fields: ['firstName', 'lastName', 'taxId', 'dateOfBirth', 'address']
    },
    employment: {
        weight: 25,
        fields: ['employmentStatus', 'employer', 'grossIncome']
    },
    deductions: {
        weight: 30,
        minItems: 1 // At least review deductions
    },
    documents: {
        weight: 15,
        minItems: 0 // Optional but recommended
    },
    review: {
        weight: 10,
        fields: ['reviewed']
    }
};

export function ProgressProvider({ children, taxData }) {
    const progress = useMemo(() => {
        return calculateProgress(taxData);
    }, [taxData]);

    return (
        <ProgressContext.Provider value={progress}>
            {children}
        </ProgressContext.Provider>
    );
}

export function useProgress() {
    const context = useContext(ProgressContext);
    if (!context) {
        // Return default progress if used outside provider
        return {
            overall: 0,
            sections: {},
            completedSections: 0,
            totalSections: 5,
            nextStep: 'personalInfo',
            isComplete: false
        };
    }
    return context;
}

function calculateProgress(taxData) {
    if (!taxData) {
        return {
            overall: 0,
            sections: {
                personalInfo: { percent: 0, completed: false, missing: ['firstName', 'lastName', 'taxId', 'dateOfBirth', 'address'] },
                employment: { percent: 0, completed: false, missing: ['employmentStatus', 'employer', 'grossIncome'] },
                deductions: { percent: 0, completed: false, missing: ['Add at least one deduction'] },
                documents: { percent: 0, completed: false, missing: [] },
                review: { percent: 0, completed: false, missing: ['Final review'] }
            },
            completedSections: 0,
            totalSections: 5,
            nextStep: 'personalInfo',
            isComplete: false
        };
    }

    const sections = {};
    let totalWeight = 0;
    let earnedWeight = 0;
    let completedSections = 0;
    let nextStep = null;

    // Personal Info
    const personalInfo = taxData.personalInfo || {};
    const personalFields = COMPLETION_REQUIREMENTS.personalInfo.fields;
    const personalMissing = personalFields.filter(f => !personalInfo[f]);
    const personalPercent = Math.round(((personalFields.length - personalMissing.length) / personalFields.length) * 100);
    sections.personalInfo = {
        percent: personalPercent,
        completed: personalPercent === 100,
        missing: personalMissing
    };
    if (personalPercent === 100) completedSections++;
    else if (!nextStep) nextStep = 'personalInfo';
    totalWeight += COMPLETION_REQUIREMENTS.personalInfo.weight;
    earnedWeight += (personalPercent / 100) * COMPLETION_REQUIREMENTS.personalInfo.weight;

    // Employment
    const employment = taxData.employment || {};
    const employmentFields = COMPLETION_REQUIREMENTS.employment.fields;
    const employmentMissing = employmentFields.filter(f => !employment[f]);
    const employmentPercent = Math.round(((employmentFields.length - employmentMissing.length) / employmentFields.length) * 100);
    sections.employment = {
        percent: employmentPercent,
        completed: employmentPercent === 100,
        missing: employmentMissing
    };
    if (employmentPercent === 100) completedSections++;
    else if (!nextStep) nextStep = 'employment';
    totalWeight += COMPLETION_REQUIREMENTS.employment.weight;
    earnedWeight += (employmentPercent / 100) * COMPLETION_REQUIREMENTS.employment.weight;

    // Deductions
    const deductions = taxData.deductions || [];
    const hasDeductions = deductions.length > 0;
    const deductionsPercent = hasDeductions ? 100 : 0;
    sections.deductions = {
        percent: deductionsPercent,
        completed: hasDeductions,
        missing: hasDeductions ? [] : ['Add at least one deduction'],
        count: deductions.length
    };
    if (hasDeductions) completedSections++;
    else if (!nextStep) nextStep = 'deductions';
    totalWeight += COMPLETION_REQUIREMENTS.deductions.weight;
    earnedWeight += (deductionsPercent / 100) * COMPLETION_REQUIREMENTS.deductions.weight;

    // Documents
    const documents = taxData.documents || [];
    const hasDocuments = documents.length > 0;
    sections.documents = {
        percent: hasDocuments ? 100 : 50, // 50% if none (optional section)
        completed: true, // Always "complete" since optional
        missing: [],
        count: documents.length,
        optional: true
    };
    completedSections++; // Documents always count as complete
    totalWeight += COMPLETION_REQUIREMENTS.documents.weight;
    earnedWeight += (hasDocuments ? 1 : 0.5) * COMPLETION_REQUIREMENTS.documents.weight;

    // Review
    const reviewed = taxData.reviewed || false;
    sections.review = {
        percent: reviewed ? 100 : 0,
        completed: reviewed,
        missing: reviewed ? [] : ['Final review']
    };
    if (reviewed) completedSections++;
    else if (!nextStep) nextStep = 'review';
    totalWeight += COMPLETION_REQUIREMENTS.review.weight;
    earnedWeight += (reviewed ? 1 : 0) * COMPLETION_REQUIREMENTS.review.weight;

    const overall = Math.round((earnedWeight / totalWeight) * 100);

    return {
        overall,
        sections,
        completedSections,
        totalSections: 5,
        nextStep: nextStep || 'complete',
        isComplete: overall >= 90 // Consider complete at 90%+ (documents optional)
    };
}

// Progress Bar Component
export function ProgressBar({ className = '' }) {
    const { overall, completedSections, totalSections, isComplete } = useProgress();

    const getColor = () => {
        if (isComplete) return 'bg-accent-success';
        if (overall >= 60) return 'bg-accent-primary';
        if (overall >= 30) return 'bg-accent-warning';
        return 'bg-accent-danger';
    };

    return (
        <div className={`flex items-center gap-3 ${className}`}>
            <div className="flex-1 h-2 bg-dark-700 rounded-full overflow-hidden">
                <div
                    className={`h-full ${getColor()} transition-all duration-500 ease-out`}
                    style={{ width: `${overall}%` }}
                />
            </div>
            <span className="text-sm font-medium text-text-secondary whitespace-nowrap">
                {overall}%
            </span>
            {isComplete && (
                <span className="text-accent-success">✓</span>
            )}
        </div>
    );
}

// Detailed Progress Panel
export function ProgressPanel({ onNavigate }) {
    const { overall, sections, isComplete, nextStep } = useProgress();

    const sectionLabels = {
        personalInfo: { label: 'Personal Info', icon: '👤' },
        employment: { label: 'Employment', icon: '💼' },
        deductions: { label: 'Deductions', icon: '📝' },
        documents: { label: 'Documents', icon: '📎' },
        review: { label: 'Review', icon: '✅' }
    };

    return (
        <div className="bg-dark-800 border border-dark-600 rounded-xl p-4">
            <div className="flex items-center justify-between mb-4">
                <h3 className="font-semibold text-text-primary">Your Progress</h3>
                <span className={`text-2xl font-bold ${isComplete ? 'text-accent-success' : 'text-accent-primary'}`}>
                    {overall}%
                </span>
            </div>

            <ProgressBar className="mb-4" />

            <div className="space-y-2">
                {Object.entries(sections).map(([key, section]) => (
                    <button
                        key={key}
                        onClick={() => onNavigate?.(key)}
                        className="w-full flex items-center gap-3 p-2 rounded-lg hover:bg-dark-700 transition-colors text-left"
                    >
                        <span className="text-lg">{sectionLabels[key]?.icon}</span>
                        <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between">
                                <span className="text-sm text-text-primary">
                                    {sectionLabels[key]?.label}
                                </span>
                                <span className={`text-xs ${section.completed ? 'text-accent-success' : 'text-text-muted'}`}>
                                    {section.completed ? '✓' : `${section.percent}%`}
                                </span>
                            </div>
                            <div className="h-1 bg-dark-600 rounded-full mt-1 overflow-hidden">
                                <div
                                    className={`h-full transition-all duration-300 ${section.completed ? 'bg-accent-success' : 'bg-accent-primary'
                                        }`}
                                    style={{ width: `${section.percent}%` }}
                                />
                            </div>
                        </div>
                    </button>
                ))}
            </div>

            {!isComplete && nextStep !== 'complete' && (
                <button
                    onClick={() => onNavigate?.(nextStep)}
                    className="mt-4 w-full py-2 bg-accent-primary hover:bg-accent-hover text-white rounded-lg font-medium transition-colors"
                >
                    Continue: {sectionLabels[nextStep]?.label} →
                </button>
            )}
        </div>
    );
}
