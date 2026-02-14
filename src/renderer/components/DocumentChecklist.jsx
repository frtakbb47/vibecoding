import React, { useState, useMemo } from 'react';

/**
 * DocumentChecklist - Shows users exactly what documents they need
 * Based on their profile and selected deductions
 */

// Document requirements database
const DOCUMENT_TYPES = {
    lohnsteuerbescheinigung: {
        id: 'lohnsteuerbescheinigung',
        name: 'Lohnsteuerbescheinigung',
        nameEN: 'Annual Tax Certificate',
        description: 'Your employer sends this by end of February. Contains all salary and tax info.',
        required: true,
        priority: 1,
        source: 'Employer (Arbeitgeber)',
        deadline: 'Usually available by February',
        fields: ['Bruttolohn', 'Lohnsteuer', 'Sozialversicherung', 'Kirchensteuer'],
        applicableTo: ['employed'],
    },
    payslips: {
        id: 'payslips',
        name: 'Gehaltsabrechnungen',
        nameEN: 'Monthly Payslips',
        description: 'Monthly payslips as backup. Especially useful if Lohnsteuerbescheinigung is incomplete.',
        required: false,
        priority: 2,
        source: 'Employer / HR Portal',
        deadline: 'Keep all 12 months',
        applicableTo: ['employed'],
    },
    homeoffice_log: {
        id: 'homeoffice_log',
        name: 'Homeoffice-Nachweis',
        nameEN: 'Home Office Log',
        description: 'Simple calendar or log showing which days you worked from home.',
        required: false,
        priority: 3,
        source: 'Self-created',
        tip: 'A simple Excel or calendar export works. Note: max 210 days at €6/day.',
        applicableTo: ['homeoffice'],
    },
    work_equipment: {
        id: 'work_equipment',
        name: 'Arbeitsmittel-Belege',
        nameEN: 'Work Equipment Receipts',
        description: 'Receipts for computer, desk, chair, monitors, software, etc.',
        required: false,
        priority: 3,
        source: 'Stores / Online shops',
        tip: 'Items under €800 net are fully deductible. Over €800 must be depreciated.',
        applicableTo: ['employed', 'student'],
    },
    commute_proof: {
        id: 'commute_proof',
        name: 'Pendlerpauschale-Nachweis',
        nameEN: 'Commute Documentation',
        description: 'Proof of workplace address and home-to-work distance.',
        required: false,
        priority: 4,
        source: 'Google Maps / Employment contract',
        tip: 'Screenshot from Google Maps showing the distance is usually enough.',
        applicableTo: ['commute'],
    },
    course_certificates: {
        id: 'course_certificates',
        name: 'Fortbildungsnachweise',
        nameEN: 'Training Certificates',
        description: 'Receipts for courses, certifications, books, conferences.',
        required: false,
        priority: 5,
        source: 'Training providers / Bookstores',
        applicableTo: ['employed', 'student'],
    },
    insurance_docs: {
        id: 'insurance_docs',
        name: 'Versicherungsbescheinigungen',
        nameEN: 'Insurance Certificates',
        description: 'Annual statements from insurance companies.',
        required: false,
        priority: 5,
        source: 'Insurance companies',
        tip: 'Most insurers send these in January/February.',
        applicableTo: ['all'],
    },
    donation_receipts: {
        id: 'donation_receipts',
        name: 'Spendenbescheinigungen',
        nameEN: 'Donation Receipts',
        description: 'Official receipts for charitable donations.',
        required: false,
        priority: 6,
        source: 'Charitable organizations',
        tip: 'For donations under €300, a bank statement is sufficient.',
        applicableTo: ['all'],
    },
    moving_receipts: {
        id: 'moving_receipts',
        name: 'Umzugskostenbelege',
        nameEN: 'Moving Receipts',
        description: 'Invoices from moving companies, travel receipts for job-related moves.',
        required: false,
        priority: 6,
        source: 'Moving company / Travel receipts',
        applicableTo: ['moved'],
    },
    bank_statements: {
        id: 'bank_statements',
        name: 'Kontoauszüge',
        nameEN: 'Bank Statements',
        description: 'Bank statements showing tax-relevant transactions.',
        required: false,
        priority: 7,
        source: 'Your bank',
        tip: 'Only needed for specific deductions if you lack receipts.',
        applicableTo: ['all'],
    },
    student_enrollment: {
        id: 'student_enrollment',
        name: 'Immatrikulationsbescheinigung',
        nameEN: 'Student Enrollment Certificate',
        description: 'Proof of university enrollment for student tax benefits.',
        required: false,
        priority: 2,
        source: 'University',
        applicableTo: ['student'],
    },
};

function DocumentChecklist({ profile, deductions, documents, extractedText }) {
    const [showOptional, setShowOptional] = useState(true);

    // Determine which documents are needed based on profile
    const neededDocuments = useMemo(() => {
        const needed = [];
        const userContext = [];

        // Build user context
        if (profile?.isStudent) userContext.push('student');
        if (profile?.isExpat) userContext.push('expat');
        if (profile?.employmentType === 'employed' || !profile?.isStudent) {
            userContext.push('employed');
        }
        if (deductions?.workFromHome || profile?.worksFromHome) userContext.push('homeoffice');
        if (deductions?.commuting) userContext.push('commute');
        if (deductions?.movingExpenses) userContext.push('moved');
        userContext.push('all');

        // Filter documents
        Object.values(DOCUMENT_TYPES).forEach(doc => {
            if (doc.applicableTo.some(type => userContext.includes(type))) {
                needed.push(doc);
            }
        });

        return needed.sort((a, b) => a.priority - b.priority);
    }, [profile, deductions]);

    // Check which documents are already uploaded
    const uploadedDocs = useMemo(() => {
        const uploaded = new Set();

        documents?.forEach(doc => {
            const name = doc.name?.toLowerCase() || '';
            const text = (extractedText?.[doc.path]?.text || '').toLowerCase();

            // Detect document types from name and content
            if (name.includes('lohnsteuer') || text.includes('lohnsteuerbescheinigung')) {
                uploaded.add('lohnsteuerbescheinigung');
            }
            if (name.includes('gehalt') || name.includes('payslip') || text.includes('entgeltabrechnung')) {
                uploaded.add('payslips');
            }
            if (name.includes('spende') || text.includes('spendenbescheinigung')) {
                uploaded.add('donation_receipts');
            }
            if (name.includes('versicherung') || text.includes('versicherungsbeitrag')) {
                uploaded.add('insurance_docs');
            }
            if (name.includes('rechnung') || name.includes('invoice') || name.includes('receipt')) {
                uploaded.add('work_equipment');
            }
        });

        return uploaded;
    }, [documents, extractedText]);

    const requiredDocs = neededDocuments.filter(d => d.required);
    const optionalDocs = neededDocuments.filter(d => !d.required);

    const completedRequired = requiredDocs.filter(d => uploadedDocs.has(d.id)).length;
    const completedOptional = optionalDocs.filter(d => uploadedDocs.has(d.id)).length;

    return (
        <div className="space-y-4">
            {/* Header with progress */}
            <div className="flex items-center justify-between">
                <div>
                    <h3 className="font-semibold text-text-primary flex items-center gap-2">
                        <span className="w-6 h-6 rounded bg-accent-primary/20 flex items-center justify-center">
                            <span className="text-sm">📋</span>
                        </span>
                        Document Checklist
                    </h3>
                    <p className="text-xs text-text-muted mt-1">
                        Based on your profile
                    </p>
                </div>
                <div className="text-right">
                    <div className="flex items-center gap-1">
                        <span className={`text-lg font-bold ${completedRequired === requiredDocs.length ? 'text-accent-success' : 'text-accent-warning'}`}>
                            {completedRequired}/{requiredDocs.length}
                        </span>
                        <span className="text-xs text-text-muted">required</span>
                    </div>
                </div>
            </div>

            {/* Required Documents */}
            {requiredDocs.length > 0 && (
                <div className="space-y-2">
                    <p className="text-xs font-medium text-text-secondary uppercase tracking-wide">Required</p>
                    {requiredDocs.map(doc => (
                        <DocumentItem
                            key={doc.id}
                            doc={doc}
                            isUploaded={uploadedDocs.has(doc.id)}
                        />
                    ))}
                </div>
            )}

            {/* Optional Documents Toggle */}
            {optionalDocs.length > 0 && (
                <div className="space-y-2">
                    <button
                        onClick={() => setShowOptional(!showOptional)}
                        className="flex items-center justify-between w-full text-xs font-medium text-text-secondary uppercase tracking-wide hover:text-text-primary transition-colors"
                    >
                        <span>Optional ({completedOptional}/{optionalDocs.length} uploaded)</span>
                        <svg
                            className={`w-4 h-4 transition-transform ${showOptional ? 'rotate-180' : ''}`}
                            fill="none" viewBox="0 0 24 24" stroke="currentColor"
                        >
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                        </svg>
                    </button>

                    {showOptional && (
                        <div className="space-y-2">
                            {optionalDocs.map(doc => (
                                <DocumentItem
                                    key={doc.id}
                                    doc={doc}
                                    isUploaded={uploadedDocs.has(doc.id)}
                                />
                            ))}
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}

function DocumentItem({ doc, isUploaded }) {
    const [expanded, setExpanded] = useState(false);

    return (
        <div
            className={`border rounded-lg transition-all ${isUploaded
                    ? 'border-accent-success/30 bg-accent-success/5'
                    : doc.required
                        ? 'border-accent-warning/30 bg-accent-warning/5'
                        : 'border-dark-600'
                }`}
        >
            <div
                className="p-3 flex items-center gap-3 cursor-pointer"
                onClick={() => setExpanded(!expanded)}
            >
                {/* Status icon */}
                <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 ${isUploaded
                        ? 'bg-accent-success text-white'
                        : doc.required
                            ? 'bg-accent-warning/20 text-accent-warning'
                            : 'bg-dark-600 text-text-muted'
                    }`}>
                    {isUploaded ? (
                        <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                    ) : (
                        <span className="text-xs">{doc.required ? '!' : '?'}</span>
                    )}
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                    <p className={`font-medium text-sm ${isUploaded ? 'text-accent-success' : 'text-text-primary'}`}>
                        {doc.name}
                    </p>
                    <p className="text-xs text-text-muted">{doc.nameEN}</p>
                </div>

                {/* Expand icon */}
                <svg
                    className={`w-4 h-4 text-text-muted transition-transform ${expanded ? 'rotate-180' : ''}`}
                    fill="none" viewBox="0 0 24 24" stroke="currentColor"
                >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
            </div>

            {/* Expanded details */}
            {expanded && (
                <div className="px-3 pb-3 pt-0 border-t border-dark-600 mt-1 space-y-2">
                    <p className="text-xs text-text-secondary mt-3">{doc.description}</p>

                    <div className="flex flex-wrap gap-2 text-xs">
                        <span className="px-2 py-0.5 bg-dark-700 rounded text-text-muted">
                            📍 {doc.source}
                        </span>
                        {doc.deadline && (
                            <span className="px-2 py-0.5 bg-dark-700 rounded text-text-muted">
                                📅 {doc.deadline}
                            </span>
                        )}
                    </div>

                    {doc.tip && (
                        <div className="p-2 bg-accent-primary/10 rounded-lg">
                            <p className="text-xs text-accent-primary">💡 {doc.tip}</p>
                        </div>
                    )}

                    {doc.fields && (
                        <div className="text-xs text-text-muted">
                            <span className="font-medium">Contains: </span>
                            {doc.fields.join(', ')}
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}

export default DocumentChecklist;
