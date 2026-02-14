import React, { useState } from 'react';
import { useLanguage } from '../contexts/LanguageContext';
import { useValidation } from '../contexts/ValidationContext';

// PDF Form Generation Component
export function PDFExport({ taxData, onExport, className = '' }) {
    const [isGenerating, setIsGenerating] = useState(false);
    const [selectedForms, setSelectedForms] = useState(['summary']);
    const { language } = useLanguage();
    const isGerman = language === 'de';
    const { isValid, errorCount } = useValidation();

    // Available German tax forms
    const availableForms = [
        {
            id: 'summary',
            name: 'Summary Report',
            nameDe: 'Zusammenfassung',
            description: 'Overview of all deductions and estimated savings',
            descriptionDe: 'Übersicht aller Abzüge und geschätzten Ersparnisse',
            icon: '📊',
            recommended: true
        },
        {
            id: 'anlage-n',
            name: 'Anlage N',
            nameDe: 'Anlage N',
            description: 'Income from employment',
            descriptionDe: 'Einkünfte aus nichtselbständiger Arbeit',
            icon: '💼',
            recommended: true
        },
        {
            id: 'anlage-vorsorge',
            name: 'Anlage Vorsorgeaufwand',
            nameDe: 'Anlage Vorsorgeaufwand',
            description: 'Insurance and pension contributions',
            descriptionDe: 'Versicherungen und Vorsorgeaufwendungen',
            icon: '🛡️',
            recommended: false
        },
        {
            id: 'anlage-haushaltsnahe',
            name: 'Anlage Haushaltsnahe',
            nameDe: 'Anlage Haushaltsnahe',
            description: 'Household services and craftsman costs',
            descriptionDe: 'Haushaltsnahe Dienstleistungen und Handwerker',
            icon: '🏠',
            recommended: false
        },
        {
            id: 'anlage-sonderausgaben',
            name: 'Anlage Sonderausgaben',
            nameDe: 'Anlage Sonderausgaben',
            description: 'Special expenses (donations, etc.)',
            descriptionDe: 'Sonderausgaben (Spenden, etc.)',
            icon: '❤️',
            recommended: false
        }
    ];

    const toggleForm = (formId) => {
        setSelectedForms(prev =>
            prev.includes(formId)
                ? prev.filter(id => id !== formId)
                : [...prev, formId]
        );
    };

    const handleExport = async () => {
        setIsGenerating(true);

        try {
            // Generate PDF content
            const pdfContent = generatePDFContent(taxData, selectedForms, isGerman);

            // In a real app, you'd use a PDF library here
            // For now, we'll create a printable HTML
            const printWindow = window.open('', '_blank');
            printWindow.document.write(pdfContent);
            printWindow.document.close();
            printWindow.focus();

            // Trigger print dialog
            setTimeout(() => {
                printWindow.print();
            }, 250);

            onExport?.({ forms: selectedForms, timestamp: new Date().toISOString() });
        } catch (error) {
            console.error('Export failed:', error);
        } finally {
            setIsGenerating(false);
        }
    };

    return (
        <div className={`bg-dark-800 border border-dark-600 rounded-xl overflow-hidden ${className}`}>
            {/* Header */}
            <div className="p-4 border-b border-dark-600">
                <div className="flex items-center gap-2 mb-1">
                    <span className="text-xl">📄</span>
                    <h3 className="font-semibold text-text-primary">
                        {isGerman ? 'PDF Export' : 'PDF Export'}
                    </h3>
                </div>
                <p className="text-sm text-text-secondary">
                    {isGerman
                        ? 'Wählen Sie die Formulare, die Sie exportieren möchten'
                        : 'Select the forms you want to export'}
                </p>
            </div>

            {/* Validation Warning */}
            {!isValid && (
                <div className="p-3 bg-accent-warning/10 border-b border-dark-600">
                    <div className="flex items-center gap-2 text-accent-warning text-sm">
                        <span>⚠️</span>
                        <span>
                            {isGerman
                                ? `${errorCount} Fehler vor dem Export beheben`
                                : `Fix ${errorCount} errors before exporting`}
                        </span>
                    </div>
                </div>
            )}

            {/* Form Selection */}
            <div className="p-4 space-y-2">
                {availableForms.map((form) => (
                    <button
                        key={form.id}
                        onClick={() => toggleForm(form.id)}
                        className={`w-full flex items-center gap-3 p-3 rounded-lg border transition-colors text-left ${selectedForms.includes(form.id)
                            ? 'bg-accent-primary/10 border-accent-primary/50'
                            : 'bg-dark-700 border-dark-600 hover:border-dark-500'
                            }`}
                    >
                        <div className={`w-5 h-5 rounded border-2 flex items-center justify-center ${selectedForms.includes(form.id)
                            ? 'bg-accent-primary border-accent-primary'
                            : 'border-dark-500'
                            }`}>
                            {selectedForms.includes(form.id) && (
                                <svg className="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" />
                                </svg>
                            )}
                        </div>

                        <span className="text-xl">{form.icon}</span>

                        <div className="flex-1">
                            <div className="flex items-center gap-2">
                                <span className="font-medium text-text-primary">
                                    {isGerman ? form.nameDe : form.name}
                                </span>
                                {form.recommended && (
                                    <span className="px-1.5 py-0.5 bg-accent-success/20 text-accent-success text-xs rounded">
                                        {isGerman ? 'Empfohlen' : 'Recommended'}
                                    </span>
                                )}
                            </div>
                            <span className="text-sm text-text-muted">
                                {isGerman ? form.descriptionDe : form.description}
                            </span>
                        </div>
                    </button>
                ))}
            </div>

            {/* Export Button */}
            <div className="p-4 border-t border-dark-600">
                <button
                    onClick={handleExport}
                    disabled={isGenerating || selectedForms.length === 0}
                    className="w-full py-3 bg-accent-primary hover:bg-accent-hover disabled:bg-dark-600 disabled:cursor-not-allowed text-white font-medium rounded-lg transition-colors flex items-center justify-center gap-2"
                >
                    {isGenerating ? (
                        <>
                            <svg className="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                            </svg>
                            {isGerman ? 'Generiere...' : 'Generating...'}
                        </>
                    ) : (
                        <>
                            <span>📄</span>
                            {isGerman
                                ? `${selectedForms.length} Formular(e) exportieren`
                                : `Export ${selectedForms.length} Form(s)`}
                        </>
                    )}
                </button>
            </div>
        </div>
    );
}

// Generate printable HTML content
function generatePDFContent(taxData, selectedForms, isGerman) {
    const year = taxData?.taxYear || new Date().getFullYear();
    const personal = taxData?.personalInfo || {};
    const employment = taxData?.employment || {};
    const deductions = taxData?.deductions || [];
    const totalDeductions = deductions.reduce((sum, d) => sum + (d.amount || 0), 0);

    // Group deductions by category
    const byCategory = {};
    deductions.forEach(d => {
        const cat = d.category || 'other';
        if (!byCategory[cat]) byCategory[cat] = [];
        byCategory[cat].push(d);
    });

    const categoryLabels = {
        commute: isGerman ? 'Fahrtkosten' : 'Commuting',
        homeoffice: isGerman ? 'Homeoffice' : 'Home Office',
        equipment: isGerman ? 'Arbeitsmittel' : 'Work Equipment',
        education: isGerman ? 'Weiterbildung' : 'Education',
        insurance: isGerman ? 'Versicherungen' : 'Insurance',
        donations: isGerman ? 'Spenden' : 'Donations',
        medical: isGerman ? 'Gesundheit' : 'Medical',
        household: isGerman ? 'Haushalt' : 'Household',
        other: isGerman ? 'Sonstiges' : 'Other'
    };

    return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>TaxMini - ${isGerman ? 'Steuererklärung' : 'Tax Return'} ${year}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 12px; color: #333; padding: 20mm; }
        .header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 2px solid #333; }
        .header h1 { font-size: 24px; margin-bottom: 5px; }
        .header p { color: #666; }
        .section { margin-bottom: 25px; }
        .section-title { font-size: 14px; font-weight: bold; margin-bottom: 10px; padding-bottom: 5px; border-bottom: 1px solid #ddd; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        .info-item { padding: 8px; background: #f5f5f5; border-radius: 4px; }
        .info-item label { display: block; font-size: 10px; color: #666; margin-bottom: 2px; }
        .info-item value { font-weight: 500; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f5f5f5; font-weight: 600; }
        .amount { text-align: right; font-family: monospace; }
        .total-row { font-weight: bold; background: #e8f4e8; }
        .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 10px; color: #666; text-align: center; }
        .category-section { margin-bottom: 15px; }
        .category-title { font-weight: 600; color: #444; margin-bottom: 5px; }
        @media print { body { padding: 10mm; } }
    </style>
</head>
<body>
    <div class="header">
        <h1>TaxMini - ${isGerman ? 'Steuererklärung' : 'Tax Return'} ${year}</h1>
        <p>${isGerman ? 'Generiert am' : 'Generated on'} ${new Date().toLocaleDateString(isGerman ? 'de-DE' : 'en-US')}</p>
    </div>

    ${selectedForms.includes('summary') ? `
    <div class="section">
        <div class="section-title">${isGerman ? 'Persönliche Daten' : 'Personal Information'}</div>
        <div class="info-grid">
            <div class="info-item">
                <label>${isGerman ? 'Name' : 'Name'}</label>
                <value>${personal.firstName || ''} ${personal.lastName || ''}</value>
            </div>
            <div class="info-item">
                <label>${isGerman ? 'Steuer-ID' : 'Tax ID'}</label>
                <value>${personal.taxId || '-'}</value>
            </div>
            <div class="info-item">
                <label>${isGerman ? 'Adresse' : 'Address'}</label>
                <value>${personal.address || '-'}</value>
            </div>
            <div class="info-item">
                <label>${isGerman ? 'Geburtsdatum' : 'Date of Birth'}</label>
                <value>${personal.dateOfBirth || '-'}</value>
            </div>
        </div>
    </div>

    <div class="section">
        <div class="section-title">${isGerman ? 'Einkommen' : 'Income'}</div>
        <div class="info-grid">
            <div class="info-item">
                <label>${isGerman ? 'Bruttoeinkommen' : 'Gross Income'}</label>
                <value>€${(employment.grossIncome || 0).toLocaleString()}</value>
            </div>
            <div class="info-item">
                <label>${isGerman ? 'Beschäftigungsstatus' : 'Employment Status'}</label>
                <value>${employment.employmentStatus || '-'}</value>
            </div>
        </div>
    </div>
    ` : ''}

    ${selectedForms.includes('summary') || selectedForms.includes('anlage-n') ? `
    <div class="section">
        <div class="section-title">${isGerman ? 'Abzüge' : 'Deductions'}</div>

        ${Object.entries(byCategory).map(([cat, items]) => `
        <div class="category-section">
            <div class="category-title">${categoryLabels[cat] || cat}</div>
            <table>
                <thead>
                    <tr>
                        <th>${isGerman ? 'Beschreibung' : 'Description'}</th>
                        <th class="amount">${isGerman ? 'Betrag' : 'Amount'}</th>
                    </tr>
                </thead>
                <tbody>
                    ${items.map(d => `
                    <tr>
                        <td>${d.name || d.description || '-'}</td>
                        <td class="amount">€${(d.amount || 0).toLocaleString()}</td>
                    </tr>
                    `).join('')}
                    <tr class="total-row">
                        <td>${isGerman ? 'Summe' : 'Subtotal'}</td>
                        <td class="amount">€${items.reduce((s, d) => s + (d.amount || 0), 0).toLocaleString()}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        `).join('')}

        <table style="margin-top: 20px;">
            <tr class="total-row" style="background: #d4edda;">
                <td style="font-size: 14px;">${isGerman ? 'Gesamtabzüge' : 'Total Deductions'}</td>
                <td class="amount" style="font-size: 14px;">€${totalDeductions.toLocaleString()}</td>
            </tr>
        </table>
    </div>
    ` : ''}

    <div class="footer">
        <p>${isGerman
            ? 'Dieses Dokument wurde mit TaxMini erstellt - Ihrem datenschutzfreundlichen Steuerassistenten.'
            : 'This document was generated with TaxMini - your privacy-first tax assistant.'
        }</p>
        <p style="margin-top: 5px;">© ${new Date().getFullYear()} TaxMini | ${isGerman ? 'Alle Angaben ohne Gewähr' : 'All information without guarantee'}</p>
    </div>
</body>
</html>
    `;
}

// Quick export button
export function QuickExportButton({ taxData, className = '' }) {
    const [isExporting, setIsExporting] = useState(false);
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const handleQuickExport = async () => {
        setIsExporting(true);
        try {
            const pdfContent = generatePDFContent(taxData, ['summary'], isGerman);
            const printWindow = window.open('', '_blank');
            printWindow.document.write(pdfContent);
            printWindow.document.close();
            printWindow.focus();
            setTimeout(() => printWindow.print(), 250);
        } finally {
            setIsExporting(false);
        }
    };

    return (
        <button
            onClick={handleQuickExport}
            disabled={isExporting}
            className={`flex items-center gap-2 px-3 py-1.5 bg-dark-700 hover:bg-dark-600 text-text-secondary hover:text-text-primary rounded-lg transition-colors ${className}`}
            data-tour="export"
        >
            {isExporting ? (
                <svg className="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                </svg>
            ) : (
                <span>📄</span>
            )}
            <span className="text-sm">PDF</span>
        </button>
    );
}
