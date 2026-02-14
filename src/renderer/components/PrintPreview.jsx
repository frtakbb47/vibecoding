import React, { useState, useMemo } from 'react';
import { useLanguage } from '../contexts/LanguageContext';

// Print Preview Component
export function PrintPreview({ taxData, onClose, onPrint }) {
    const [zoom, setZoom] = useState(100);
    const [currentPage, setCurrentPage] = useState(1);
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const pages = useMemo(() => generatePreviewPages(taxData, isGerman), [taxData, isGerman]);
    const totalPages = pages.length;

    const handlePrint = () => {
        window.print();
        onPrint?.();
    };

    return (
        <div className="fixed inset-0 z-50 bg-dark-950 flex flex-col">
            {/* Header */}
            <div className="flex items-center justify-between p-4 border-b border-dark-600 bg-dark-800">
                <div className="flex items-center gap-4">
                    <button
                        onClick={onClose}
                        className="p-2 text-text-muted hover:text-text-primary hover:bg-dark-700 rounded-lg transition-colors"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                    <h2 className="font-semibold text-text-primary">
                        {isGerman ? 'Druckvorschau' : 'Print Preview'}
                    </h2>
                </div>

                {/* Zoom controls */}
                <div className="flex items-center gap-2">
                    <button
                        onClick={() => setZoom(z => Math.max(50, z - 25))}
                        className="p-2 text-text-muted hover:text-text-primary hover:bg-dark-700 rounded transition-colors"
                    >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
                        </svg>
                    </button>
                    <span className="text-sm text-text-secondary w-12 text-center">{zoom}%</span>
                    <button
                        onClick={() => setZoom(z => Math.min(200, z + 25))}
                        className="p-2 text-text-muted hover:text-text-primary hover:bg-dark-700 rounded transition-colors"
                    >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                        </svg>
                    </button>
                </div>

                {/* Print button */}
                <button
                    onClick={handlePrint}
                    className="flex items-center gap-2 px-4 py-2 bg-accent-primary hover:bg-accent-hover text-white rounded-lg font-medium transition-colors"
                >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                    </svg>
                    {isGerman ? 'Drucken' : 'Print'}
                </button>
            </div>

            {/* Preview Area */}
            <div className="flex-1 overflow-auto p-8 bg-dark-900">
                <div
                    className="mx-auto"
                    style={{
                        transform: `scale(${zoom / 100})`,
                        transformOrigin: 'top center'
                    }}
                >
                    {/* Page */}
                    <div
                        className="bg-white text-gray-900 shadow-2xl mx-auto"
                        style={{
                            width: '210mm',
                            minHeight: '297mm',
                            padding: '20mm'
                        }}
                        dangerouslySetInnerHTML={{ __html: pages[currentPage - 1] }}
                    />
                </div>
            </div>

            {/* Footer / Page Navigation */}
            {totalPages > 1 && (
                <div className="flex items-center justify-center gap-4 p-4 border-t border-dark-600 bg-dark-800">
                    <button
                        onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                        disabled={currentPage === 1}
                        className="p-2 text-text-muted hover:text-text-primary disabled:opacity-30 transition-colors"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                    </button>
                    <span className="text-text-secondary">
                        {isGerman ? 'Seite' : 'Page'} {currentPage} / {totalPages}
                    </span>
                    <button
                        onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                        disabled={currentPage === totalPages}
                        className="p-2 text-text-muted hover:text-text-primary disabled:opacity-30 transition-colors"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            )}
        </div>
    );
}

// Generate preview pages
function generatePreviewPages(taxData, isGerman) {
    const year = taxData?.taxYear || new Date().getFullYear();
    const personal = taxData?.personalInfo || {};
    const employment = taxData?.employment || {};
    const deductions = taxData?.deductions || [];
    const totalDeductions = deductions.reduce((sum, d) => sum + (d.amount || 0), 0);

    // Group by category
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

    // Page 1: Summary
    const page1 = `
        <style>
            .preview-header { text-align: center; margin-bottom: 40px; }
            .preview-header h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; color: #1a1a1a; }
            .preview-header p { color: #666; font-size: 14px; }
            .preview-section { margin-bottom: 30px; }
            .preview-section-title { font-size: 16px; font-weight: 600; color: #333; padding-bottom: 8px; border-bottom: 2px solid #6366f1; margin-bottom: 15px; }
            .preview-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
            .preview-field { background: #f8f9fa; padding: 12px; border-radius: 8px; }
            .preview-field-label { font-size: 11px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
            .preview-field-value { font-size: 14px; font-weight: 500; color: #1a1a1a; }
            .preview-table { width: 100%; border-collapse: collapse; }
            .preview-table th { background: #f1f5f9; padding: 10px; text-align: left; font-size: 12px; font-weight: 600; border-bottom: 2px solid #e2e8f0; }
            .preview-table td { padding: 10px; border-bottom: 1px solid #e2e8f0; font-size: 13px; }
            .preview-table .amount { text-align: right; font-family: 'Courier New', monospace; }
            .preview-total { background: #ecfdf5; font-weight: 600; }
            .preview-grand-total { background: #6366f1; color: white; font-weight: 700; font-size: 16px; }
            .preview-category { margin-bottom: 20px; }
            .preview-category-title { font-size: 14px; font-weight: 600; color: #4b5563; margin-bottom: 8px; padding-left: 10px; border-left: 3px solid #6366f1; }
        </style>

        <div class="preview-header">
            <h1>TaxMini ${isGerman ? 'Steuererklärung' : 'Tax Return'}</h1>
            <p>${isGerman ? 'Steuerjahr' : 'Tax Year'} ${year} | ${isGerman ? 'Erstellt am' : 'Generated'} ${new Date().toLocaleDateString(isGerman ? 'de-DE' : 'en-US')}</p>
        </div>

        <div class="preview-section">
            <div class="preview-section-title">${isGerman ? 'Persönliche Daten' : 'Personal Information'}</div>
            <div class="preview-grid">
                <div class="preview-field">
                    <div class="preview-field-label">${isGerman ? 'Vollständiger Name' : 'Full Name'}</div>
                    <div class="preview-field-value">${personal.firstName || ''} ${personal.lastName || ''}</div>
                </div>
                <div class="preview-field">
                    <div class="preview-field-label">${isGerman ? 'Steuer-ID' : 'Tax ID'}</div>
                    <div class="preview-field-value">${personal.taxId || '—'}</div>
                </div>
                <div class="preview-field">
                    <div class="preview-field-label">${isGerman ? 'Adresse' : 'Address'}</div>
                    <div class="preview-field-value">${personal.address || '—'}</div>
                </div>
                <div class="preview-field">
                    <div class="preview-field-label">${isGerman ? 'Geburtsdatum' : 'Date of Birth'}</div>
                    <div class="preview-field-value">${personal.dateOfBirth || '—'}</div>
                </div>
            </div>
        </div>

        <div class="preview-section">
            <div class="preview-section-title">${isGerman ? 'Einkommen' : 'Income'}</div>
            <div class="preview-grid">
                <div class="preview-field">
                    <div class="preview-field-label">${isGerman ? 'Bruttojahreseinkommen' : 'Gross Annual Income'}</div>
                    <div class="preview-field-value">€${(employment.grossIncome || 0).toLocaleString()}</div>
                </div>
                <div class="preview-field">
                    <div class="preview-field-label">${isGerman ? 'Beschäftigung' : 'Employment'}</div>
                    <div class="preview-field-value">${employment.employmentStatus || '—'}</div>
                </div>
            </div>
        </div>

        <div class="preview-section">
            <div class="preview-section-title">${isGerman ? 'Abzugsübersicht' : 'Deduction Summary'}</div>

            ${Object.entries(byCategory).map(([cat, items]) => `
                <div class="preview-category">
                    <div class="preview-category-title">${categoryLabels[cat] || cat}</div>
                    <table class="preview-table">
                        <tbody>
                            ${items.map(d => `
                                <tr>
                                    <td>${d.name || d.description || '—'}</td>
                                    <td class="amount">€${(d.amount || 0).toLocaleString()}</td>
                                </tr>
                            `).join('')}
                            <tr class="preview-total">
                                <td>${isGerman ? 'Zwischensumme' : 'Subtotal'}</td>
                                <td class="amount">€${items.reduce((s, d) => s + (d.amount || 0), 0).toLocaleString()}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            `).join('')}

            <table class="preview-table" style="margin-top: 20px;">
                <tbody>
                    <tr class="preview-grand-total">
                        <td>${isGerman ? 'GESAMTE ABZÜGE' : 'TOTAL DEDUCTIONS'}</td>
                        <td class="amount">€${totalDeductions.toLocaleString()}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    `;

    return [page1];
}

// Print Preview Button
export function PrintPreviewButton({ onClick, className = '' }) {
    const { language } = useLanguage();
    const isGerman = language === 'de';

    return (
        <button
            onClick={onClick}
            className={`flex items-center gap-2 px-3 py-1.5 bg-dark-700 hover:bg-dark-600 text-text-secondary hover:text-text-primary rounded-lg transition-colors ${className}`}
        >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
            <span className="text-sm">{isGerman ? 'Vorschau' : 'Preview'}</span>
        </button>
    );
}
