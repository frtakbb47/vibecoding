import React, { useState } from 'react';

// Format number with thousand separators for display
function formatNumberInput(value) {
    if (!value) return '';
    const num = value.toString().replace(/\D/g, '');
    return num.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// Parse formatted number back to raw digits
function parseNumberInput(value) {
    return value.replace(/\D/g, '');
}

// Helper component for tooltips
function HelpTooltip({ text }) {
    const [show, setShow] = useState(false);
    return (
        <span className="relative inline-block ml-1">
            <button
                type="button"
                className="text-text-muted hover:text-accent-primary transition-colors"
                onMouseEnter={() => setShow(true)}
                onMouseLeave={() => setShow(false)}
                onClick={(e) => { e.preventDefault(); setShow(!show); }}
            >
                <svg className="w-4 h-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
            </button>
            {show && (
                <div className="absolute z-50 bottom-full left-1/2 -translate-x-1/2 mb-2 w-64 p-3 bg-dark-700 border border-dark-500 rounded-lg text-xs text-text-secondary shadow-xl animate-fade-in">
                    {text}
                    <div className="absolute top-full left-1/2 -translate-x-1/2 -mt-1 border-4 border-transparent border-t-dark-700" />
                </div>
            )}
        </span>
    );
}

// Currency input component with proper styling
function CurrencyInput({ value, onChange, placeholder, id }) {
    const [focused, setFocused] = useState(false);
    const displayValue = formatNumberInput(value);

    return (
        <div className={`relative flex rounded-lg overflow-hidden border transition-all ${focused
            ? 'border-accent-primary ring-1 ring-accent-primary'
            : 'border-dark-600 hover:border-dark-500'
            }`}>
            <div className="flex items-center justify-center px-3 bg-dark-700 border-r border-dark-600">
                <span className="text-text-muted font-medium text-sm">€</span>
            </div>
            <input
                type="text"
                id={id}
                value={displayValue}
                onChange={(e) => onChange(parseNumberInput(e.target.value))}
                onFocus={() => setFocused(true)}
                onBlur={() => setFocused(false)}
                className="flex-1 bg-dark-800 px-3 py-3 text-text-primary placeholder-text-muted focus:outline-none font-mono"
                placeholder={placeholder}
            />
        </div>
    );
}

// Quick refund estimate component
function QuickEstimate({ gross, taxPaid, year }) {
    const constants = TAX_CONSTANTS[year] || TAX_CONSTANTS[2025];
    const arbeitnehmerPauschbetrag = constants.arbeitnehmerPauschbetrag;

    // Very rough estimate: if gross > grundfreibetrag and they have deductions potential
    const potentialRefund = Math.min(taxPaid * 0.15, 1500); // Conservative 15% estimate

    if (!gross || !taxPaid) return null;

    return (
        <div className="bg-gradient-to-r from-accent-success/10 to-emerald-900/10 border border-accent-success/30 rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
                <span className="text-accent-success text-lg">💰</span>
                <span className="text-sm font-medium text-accent-success">Quick Estimate</span>
            </div>
            <div className="flex items-baseline gap-2 mb-2">
                <span className="text-2xl font-bold text-accent-success">
                    €{Math.round(potentialRefund).toLocaleString('de-DE')}
                </span>
                <span className="text-sm text-text-muted">potential refund</span>
            </div>
            <p className="text-xs text-text-muted">
                Based on typical deductions. The €{arbeitnehmerPauschbetrag.toLocaleString('de-DE')} employee lump sum is automatic.
            </p>
        </div>
    );
}

// German Tax Constants for 2025/2026
const TAX_CONSTANTS = {
    2025: {
        grundfreibetrag: 11784,        // Basic tax-free allowance
        arbeitnehmerPauschbetrag: 1230, // Employee lump sum
        homeOfficePerDay: 6,            // €6/day home office
        homeOfficeMaxDays: 210,         // Max 210 days
        pendlerFirst20km: 0.30,         // €0.30/km first 20km
        pendlerBeyond20km: 0.38,        // €0.38/km beyond 20km
        sonderausgabenPauschbetrag: 36, // Special expenses lump sum
        kirchensteuerRate: { bayern: 8, other: 9 }, // Church tax %
    },
    2024: {
        grundfreibetrag: 11604,
        arbeitnehmerPauschbetrag: 1230,
        homeOfficePerDay: 6,
        homeOfficeMaxDays: 210,
        pendlerFirst20km: 0.30,
        pendlerBeyond20km: 0.38,
        sonderausgabenPauschbetrag: 36,
        kirchensteuerRate: { bayern: 8, other: 9 },
    },
    2023: {
        grundfreibetrag: 10908,
        arbeitnehmerPauschbetrag: 1230,
        homeOfficePerDay: 6,
        homeOfficeMaxDays: 210,
        pendlerFirst20km: 0.30,
        pendlerBeyond20km: 0.38,
        sonderausgabenPauschbetrag: 36,
        kirchensteuerRate: { bayern: 8, other: 9 },
    },
};

const WIZARD_STEPS = [
    {
        id: 'year',
        title: 'Tax Year',
        description: 'Which year are you filing for?',
    },
    {
        id: 'status',
        title: 'Personal Status',
        description: 'Tell us about your situation',
    },
    {
        id: 'income',
        title: 'Income Estimate',
        description: 'Approximate numbers help us prepare better',
    },
    {
        id: 'employment',
        title: 'Employment Details',
        description: 'Your work situation in Germany',
    },
    {
        id: 'deductions',
        title: 'Potential Deductions',
        description: 'Common expenses you might deduct',
    },
    {
        id: 'documents',
        title: 'Documents Checklist',
        description: 'What you\'ll need to prepare',
    },
];

function Wizard({ initialData, onComplete, onBack }) {
    const [currentStep, setCurrentStep] = useState(0);
    const [formData, setFormData] = useState({
        year: initialData.year || new Date().getFullYear() - 1,
        profile: initialData.profile || {
            maritalStatus: 'single',
            hasChildren: false,
            isStudent: false,
            isExpat: false,
            arrivalYear: null,
            taxId: '',
            payChurchTax: false,
            churchTaxState: 'other',
        },
        income: initialData.income || {
            estimatedGross: '',
            estimatedTaxPaid: '',
            hadOtherIncome: false,
        },
        employment: initialData.employment || {
            type: 'employed',
            hasMultipleJobs: false,
            workedFromHome: false,
            homeOfficeDays: 0,
            workDaysPerYear: 220,
        },
        deductions: initialData.deductions || {
            workEquipment: false,
            workEquipmentAmount: '',
            professionalLiterature: false,
            workClothing: false,
            commuting: false,
            commuteDistance: 0,
            commuteDays: 220,
            movingExpenses: false,
            insurances: false,
            donations: false,
        },
    });

    const handleNext = () => {
        if (currentStep < WIZARD_STEPS.length - 1) {
            setCurrentStep(currentStep + 1);
        } else {
            onComplete(formData);
        }
    };

    const handlePrev = () => {
        if (currentStep > 0) {
            setCurrentStep(currentStep - 1);
        } else {
            onBack();
        }
    };

    const updateFormData = (section, field, value) => {
        if (section) {
            setFormData((prev) => ({
                ...prev,
                [section]: {
                    ...prev[section],
                    [field]: value,
                },
            }));
        } else {
            setFormData((prev) => ({
                ...prev,
                [field]: value,
            }));
        }
    };

    const renderStep = () => {
        switch (WIZARD_STEPS[currentStep].id) {
            case 'year':
                return (
                    <div className="space-y-6">
                        <div className="grid grid-cols-4 gap-3">
                            {[2025, 2024, 2023, 2022].map((year) => (
                                <button
                                    key={year}
                                    onClick={() => updateFormData(null, 'year', year)}
                                    className={`p-4 rounded-xl border-2 transition-all ${formData.year === year
                                        ? 'border-accent-primary bg-accent-primary/10 text-accent-primary'
                                        : 'border-dark-600 bg-dark-800 text-text-secondary hover:border-dark-500'
                                        }`}
                                >
                                    <span className="text-2xl font-bold">{year}</span>
                                </button>
                            ))}
                        </div>
                        <p className="text-sm text-text-muted">
                            💡 Tip: You can file your tax return up to 4 years retroactively
                        </p>
                    </div>
                );

            case 'status':
                return (
                    <div className="space-y-6">
                        {/* Marital Status */}
                        <div>
                            <label className="block text-sm font-medium text-text-secondary mb-2">
                                Marital Status (Familienstand)
                            </label>
                            <div className="grid grid-cols-3 gap-3">
                                {[
                                    { value: 'single', label: 'Single', emoji: '👤' },
                                    { value: 'married', label: 'Married', emoji: '💑' },
                                    { value: 'separated', label: 'Separated', emoji: '👥' },
                                ].map((option) => (
                                    <button
                                        key={option.value}
                                        onClick={() => updateFormData('profile', 'maritalStatus', option.value)}
                                        className={`p-3 rounded-xl border-2 transition-all ${formData.profile.maritalStatus === option.value
                                            ? 'border-accent-primary bg-accent-primary/10'
                                            : 'border-dark-600 bg-dark-800 hover:border-dark-500'
                                            }`}
                                    >
                                        <span className="text-xl">{option.emoji}</span>
                                        <span className="block text-sm mt-1">{option.label}</span>
                                    </button>
                                ))}
                            </div>
                        </div>

                        {/* Quick toggles */}
                        <div className="space-y-3">
                            <ToggleOption
                                label="I'm a student (Student/in)"
                                checked={formData.profile.isStudent}
                                onChange={(v) => updateFormData('profile', 'isStudent', v)}
                            />
                            <ToggleOption
                                label="I'm an expat (moved to Germany from abroad)"
                                checked={formData.profile.isExpat}
                                onChange={(v) => updateFormData('profile', 'isExpat', v)}
                            />
                            <ToggleOption
                                label="I have children (Kinder)"
                                checked={formData.profile.hasChildren}
                                onChange={(v) => updateFormData('profile', 'hasChildren', v)}
                            />
                        </div>

                        {formData.profile.isExpat && (
                            <div>
                                <label className="block text-sm font-medium text-text-secondary mb-2">
                                    When did you move to Germany?
                                </label>
                                <input
                                    type="number"
                                    min="2000"
                                    max={new Date().getFullYear()}
                                    value={formData.profile.arrivalYear || ''}
                                    onChange={(e) => updateFormData('profile', 'arrivalYear', parseInt(e.target.value))}
                                    className="input w-32"
                                    placeholder="Year"
                                />
                            </div>
                        )}

                        {/* Church Tax */}
                        <div className="pt-4 border-t border-dark-700">
                            <ToggleOption
                                label="I pay church tax (Kirchensteuer)"
                                hint="If you're registered with a church in Germany (Catholic, Protestant, etc.)"
                                checked={formData.profile.payChurchTax}
                                onChange={(v) => updateFormData('profile', 'payChurchTax', v)}
                            />
                            {formData.profile.payChurchTax && (
                                <div className="mt-3 ml-8">
                                    <label className="block text-xs text-text-muted mb-1">State (affects rate)</label>
                                    <select
                                        value={formData.profile.churchTaxState}
                                        onChange={(e) => updateFormData('profile', 'churchTaxState', e.target.value)}
                                        className="input w-48"
                                    >
                                        <option value="bayern">Bavaria (8%)</option>
                                        <option value="other">Other states (9%)</option>
                                    </select>
                                </div>
                            )}
                        </div>

                        {/* Tax ID */}
                        <div>
                            <label className="block text-sm font-medium text-text-secondary mb-2">
                                Tax ID (Steuer-ID)
                                <HelpTooltip text="Your 11-digit German tax ID. You received this by mail when you first registered in Germany. It stays the same for life." />
                            </label>
                            <input
                                type="text"
                                value={formData.profile.taxId || ''}
                                onChange={(e) => updateFormData('profile', 'taxId', e.target.value.replace(/\D/g, '').slice(0, 11))}
                                className="input w-48 font-mono"
                                placeholder="00000000000"
                                maxLength={11}
                            />
                            <p className="text-xs text-text-muted mt-1">Optional for now – needed when filing</p>
                        </div>
                    </div>
                );

            case 'income':
                return (
                    <div className="space-y-6">
                        <div className="bg-gradient-to-r from-dark-800 to-dark-700 rounded-xl p-4 border border-dark-600">
                            <div className="flex items-start gap-3">
                                <span className="text-xl">💡</span>
                                <div>
                                    <p className="text-sm font-medium text-text-primary mb-1">Quick Estimates</p>
                                    <p className="text-sm text-text-secondary">
                                        These help us give better guidance. Exact numbers come from your documents.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label htmlFor="grossSalary" className="block text-sm font-medium text-text-secondary mb-2">
                                    Estimated Gross Salary
                                    <HelpTooltip text="Your total salary before taxes (Bruttolohn). Found on your Lohnsteuerbescheinigung or estimate: monthly salary × 12." />
                                </label>
                                <CurrencyInput
                                    id="grossSalary"
                                    value={formData.income.estimatedGross || ''}
                                    onChange={(val) => updateFormData('income', 'estimatedGross', val)}
                                    placeholder="45,000"
                                />
                                <p className="text-xs text-text-muted mt-1.5">Bruttolohn from your payslip</p>
                            </div>

                            <div>
                                <label htmlFor="taxPaid" className="block text-sm font-medium text-text-secondary mb-2">
                                    Estimated Tax Paid
                                    <HelpTooltip text="Income tax deducted from your salary (Lohnsteuer). This is what you might get back!" />
                                </label>
                                <CurrencyInput
                                    id="taxPaid"
                                    value={formData.income.estimatedTaxPaid || ''}
                                    onChange={(val) => updateFormData('income', 'estimatedTaxPaid', val)}
                                    placeholder="8,000"
                                />
                                <p className="text-xs text-text-muted mt-1.5">Lohnsteuer already withheld</p>
                            </div>
                        </div>

                        {/* Quick estimate display */}
                        <QuickEstimate
                            gross={parseInt(formData.income.estimatedGross) || 0}
                            taxPaid={parseInt(formData.income.estimatedTaxPaid) || 0}
                            year={formData.year}
                        />

                        <ToggleOption
                            label="I had other income (investments, rental, etc.)"
                            hint="This app focuses on employment income only"
                            checked={formData.income.hadOtherIncome}
                            onChange={(v) => updateFormData('income', 'hadOtherIncome', v)}
                        />

                        {
                            formData.income.hadOtherIncome && (
                                <div className="bg-accent-warning/10 border border-accent-warning/30 rounded-xl p-4">
                                    <p className="text-sm text-accent-warning">
                                        ⚠️ This app is designed for simple employment income. For investment or rental income, consider consulting a Steuerberater.
                                    </p>
                                </div>
                            )
                        }
                    </div >
                );

            case 'employment':
                const homeOfficeMax = (TAX_CONSTANTS[formData.year]?.homeOfficePerDay || 6) * (TAX_CONSTANTS[formData.year]?.homeOfficeMaxDays || 210);
                return (
                    <div className="space-y-6">
                        {/* Employment Type */}
                        <div>
                            <label className="block text-sm font-medium text-text-secondary mb-2">
                                Employment Type
                            </label>
                            <div className="grid grid-cols-2 gap-3">
                                {[
                                    { value: 'employed', label: 'Employed (Angestellt)', desc: 'Working for a company' },
                                    { value: 'minijob', label: 'Minijob (€538)', desc: 'Part-time marginal employment' },
                                ].map((option) => (
                                    <button
                                        key={option.value}
                                        onClick={() => updateFormData('employment', 'type', option.value)}
                                        className={`p-4 rounded-xl border-2 text-left transition-all ${formData.employment.type === option.value
                                            ? 'border-accent-primary bg-accent-primary/10'
                                            : 'border-dark-600 bg-dark-800 hover:border-dark-500'
                                            }`}
                                    >
                                        <span className="font-medium">{option.label}</span>
                                        <span className="block text-xs text-text-muted mt-1">{option.desc}</span>
                                    </button>
                                ))}
                            </div>
                        </div>

                        {/* Toggles */}
                        <div className="space-y-3">
                            <ToggleOption
                                label="I had multiple jobs in this year"
                                checked={formData.employment.hasMultipleJobs}
                                onChange={(v) => updateFormData('employment', 'hasMultipleJobs', v)}
                            />
                            <ToggleOption
                                label="I worked from home (Home Office)"
                                hint={`Deduction: €${TAX_CONSTANTS[formData.year]?.homeOfficePerDay || 6}/day, max ${TAX_CONSTANTS[formData.year]?.homeOfficeMaxDays || 210} days = €${homeOfficeMax}`}
                                checked={formData.employment.workedFromHome}
                                onChange={(v) => updateFormData('employment', 'workedFromHome', v)}
                            />
                        </div>

                        {formData.employment.workedFromHome && (
                            <div>
                                <label className="block text-sm font-medium text-text-secondary mb-2">
                                    Approximate home office days in {formData.year}
                                </label>
                                <input
                                    type="number"
                                    min="0"
                                    max="365"
                                    value={formData.employment.homeOfficeDays || ''}
                                    onChange={(e) => updateFormData('employment', 'homeOfficeDays', parseInt(e.target.value) || 0)}
                                    className="input w-32"
                                    placeholder="Days"
                                />
                                <p className="text-xs text-text-muted mt-1">
                                    Potential deduction: €{Math.min(formData.employment.homeOfficeDays || 0, TAX_CONSTANTS[formData.year]?.homeOfficeMaxDays || 210) * (TAX_CONSTANTS[formData.year]?.homeOfficePerDay || 6)}
                                </p>
                            </div>
                        )}
                    </div>
                );

            case 'deductions':
                const constants = TAX_CONSTANTS[formData.year] || TAX_CONSTANTS[2025];
                const distance = formData.deductions.commuteDistance || 0;
                const commuteDays = formData.deductions.commuteDays || 220;
                // Calculate Pendlerpauschale
                const first20km = Math.min(distance, 20) * constants.pendlerFirst20km;
                const beyond20km = Math.max(0, distance - 20) * constants.pendlerBeyond20km;
                const dailyPendler = first20km + beyond20km;
                const yearlyPendler = Math.round(dailyPendler * commuteDays);

                return (
                    <div className="space-y-4">
                        <div className="bg-dark-800 rounded-xl p-4 border border-dark-600">
                            <p className="text-sm text-text-secondary">
                                💡 The employee lump sum (€{constants.arbeitnehmerPauschbetrag}) is automatic. Only add actual expenses if they exceed this amount.
                            </p>
                        </div>

                        <div className="grid grid-cols-2 gap-3">
                            <DeductionCard
                                emoji="💻"
                                title="Work Equipment"
                                desc="Laptop, monitor, desk, chair"
                                checked={formData.deductions.workEquipment}
                                onChange={(v) => updateFormData('deductions', 'workEquipment', v)}
                            />
                            <DeductionCard
                                emoji="📚"
                                title="Professional Literature"
                                desc="Books, courses, subscriptions"
                                checked={formData.deductions.professionalLiterature}
                                onChange={(v) => updateFormData('deductions', 'professionalLiterature', v)}
                            />
                            <DeductionCard
                                emoji="👔"
                                title="Work Clothing"
                                desc="Uniforms, safety gear"
                                checked={formData.deductions.workClothing}
                                onChange={(v) => updateFormData('deductions', 'workClothing', v)}
                            />
                            <DeductionCard
                                emoji="🚗"
                                title="Commuting"
                                desc="Travel to workplace"
                                checked={formData.deductions.commuting}
                                onChange={(v) => updateFormData('deductions', 'commuting', v)}
                            />
                            <DeductionCard
                                emoji="📦"
                                title="Moving Expenses"
                                desc="Job-related relocation"
                                checked={formData.deductions.movingExpenses}
                                onChange={(v) => updateFormData('deductions', 'movingExpenses', v)}
                            />
                            <DeductionCard
                                emoji="🏥"
                                title="Insurance Premiums"
                                desc="Health, liability, etc."
                                checked={formData.deductions.insurances}
                                onChange={(v) => updateFormData('deductions', 'insurances', v)}
                            />
                        </div>

                        {formData.deductions.commuting && (
                            <div className="mt-4 bg-dark-800 rounded-xl p-4 border border-dark-600 space-y-4">
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-text-secondary mb-2">
                                            One-way distance
                                            <HelpTooltip text="Shortest road distance from home to work (one way). Google Maps can help!" />
                                        </label>
                                        <div className="flex items-center gap-2">
                                            <input
                                                type="number"
                                                min="0"
                                                value={formData.deductions.commuteDistance || ''}
                                                onChange={(e) => updateFormData('deductions', 'commuteDistance', parseInt(e.target.value) || 0)}
                                                className="input w-24"
                                                placeholder="0"
                                            />
                                            <span className="text-text-muted">km</span>
                                        </div>
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-text-secondary mb-2">
                                            Work days in {formData.year}
                                            <HelpTooltip text="Typically 220-230 days minus vacation, sick days, home office days" />
                                        </label>
                                        <input
                                            type="number"
                                            min="0"
                                            max="365"
                                            value={formData.deductions.commuteDays || 220}
                                            onChange={(e) => updateFormData('deductions', 'commuteDays', parseInt(e.target.value) || 220)}
                                            className="input w-24"
                                        />
                                    </div>
                                </div>

                                {distance > 0 && (
                                    <div className="bg-accent-success/10 border border-accent-success/30 rounded-lg p-3">
                                        <p className="text-sm text-accent-success font-medium">
                                            Pendlerpauschale: ~€{yearlyPendler.toLocaleString()}
                                        </p>
                                        <p className="text-xs text-text-muted mt-1">
                                            {distance <= 20
                                                ? `${distance}km × €${constants.pendlerFirst20km}/km × ${commuteDays} days`
                                                : `20km × €${constants.pendlerFirst20km} + ${distance - 20}km × €${constants.pendlerBeyond20km} × ${commuteDays} days`
                                            }
                                        </p>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                );

            case 'documents':
                return (
                    <div className="space-y-4">
                        <p className="text-text-secondary mb-4">
                            Based on your answers, you'll need these documents:
                        </p>

                        <div className="space-y-3">
                            <DocumentItem
                                title="Lohnsteuerbescheinigung"
                                desc="Annual tax certificate from your employer"
                                required
                            />

                            {formData.employment.hasMultipleJobs && (
                                <DocumentItem
                                    title="Additional Lohnsteuerbescheinigungen"
                                    desc="One from each employer"
                                    required
                                />
                            )}

                            {formData.deductions.commuting && (
                                <DocumentItem
                                    title="Proof of commute"
                                    desc="Work contract showing workplace address"
                                    required={false}
                                />
                            )}

                            {formData.deductions.workEquipment && (
                                <DocumentItem
                                    title="Receipts for work equipment"
                                    desc="Invoices for laptop, desk, etc."
                                    required={false}
                                />
                            )}

                            {formData.deductions.insurances && (
                                <DocumentItem
                                    title="Insurance certificates"
                                    desc="Annual statements from insurers"
                                    required={false}
                                />
                            )}

                            <DocumentItem
                                title="Tax ID (Steuer-ID)"
                                desc="Your 11-digit German tax identification number"
                                required
                            />
                        </div>

                        <div className="bg-accent-primary/10 border border-accent-primary/30 rounded-xl p-4 mt-6">
                            <p className="text-sm text-accent-primary">
                                💡 Don't have all documents? No problem! Upload what you have and the AI will help identify what's missing.
                            </p>
                        </div>
                    </div>
                );

            default:
                return null;
        }
    };

    return (
        <div className="h-full flex flex-col">
            {/* Progress bar */}
            <div className="px-8 py-4 bg-dark-900 border-b border-dark-700">
                <div className="flex items-center gap-2 max-w-3xl mx-auto">
                    {WIZARD_STEPS.map((step, index) => (
                        <React.Fragment key={step.id}>
                            <div
                                className={`flex items-center gap-2 ${index <= currentStep ? 'text-accent-primary' : 'text-text-muted'
                                    }`}
                            >
                                <div
                                    className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium ${index < currentStep
                                        ? 'bg-accent-primary text-white'
                                        : index === currentStep
                                            ? 'bg-accent-primary/20 text-accent-primary border-2 border-accent-primary'
                                            : 'bg-dark-700 text-text-muted'
                                        }`}
                                >
                                    {index < currentStep ? '✓' : index + 1}
                                </div>
                                <span className="text-sm hidden lg:block">{step.title}</span>
                            </div>
                            {index < WIZARD_STEPS.length - 1 && (
                                <div
                                    className={`flex-1 h-0.5 ${index < currentStep ? 'bg-accent-primary' : 'bg-dark-700'
                                        }`}
                                />
                            )}
                        </React.Fragment>
                    ))}
                </div>
            </div>

            {/* Content */}
            <div className="flex-1 overflow-y-auto p-8">
                <div className="max-w-2xl mx-auto">
                    <h2 className="text-2xl font-bold text-text-primary mb-2">
                        {WIZARD_STEPS[currentStep].title}
                    </h2>
                    <p className="text-text-secondary mb-8">
                        {WIZARD_STEPS[currentStep].description}
                    </p>

                    {renderStep()}
                </div>
            </div>

            {/* Footer */}
            <div className="px-8 py-4 bg-dark-900 border-t border-dark-700">
                <div className="flex justify-between max-w-2xl mx-auto">
                    <button onClick={handlePrev} className="btn btn-secondary">
                        ← Back
                    </button>
                    <button onClick={handleNext} className="btn btn-primary">
                        {currentStep === WIZARD_STEPS.length - 1 ? 'Start Uploading Documents →' : 'Continue →'}
                    </button>
                </div>
            </div>
        </div>
    );
}

// Helper Components
function ToggleOption({ label, hint, checked, onChange }) {
    return (
        <label className="flex items-start gap-3 p-3 rounded-lg bg-dark-800 hover:bg-dark-700 cursor-pointer">
            <input
                type="checkbox"
                checked={checked}
                onChange={(e) => onChange(e.target.checked)}
                className="w-5 h-5 mt-0.5 rounded border-dark-500 text-accent-primary focus:ring-accent-primary focus:ring-offset-dark-800"
            />
            <div className="flex-1">
                <span className="text-text-primary">{label}</span>
                {hint && <p className="text-xs text-text-muted mt-0.5">{hint}</p>}
            </div>
        </label>
    );
}

function DeductionCard({ emoji, title, desc, checked, onChange }) {
    return (
        <button
            onClick={() => onChange(!checked)}
            className={`p-4 rounded-xl border-2 text-left transition-all ${checked
                ? 'border-accent-primary bg-accent-primary/10'
                : 'border-dark-600 bg-dark-800 hover:border-dark-500'
                }`}
        >
            <div className="flex items-start gap-3">
                <span className="text-2xl">{emoji}</span>
                <div>
                    <span className="font-medium text-text-primary">{title}</span>
                    <span className="block text-xs text-text-muted mt-1">{desc}</span>
                </div>
                {checked && (
                    <svg className="w-5 h-5 text-accent-primary ml-auto" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                )}
            </div>
        </button>
    );
}

function DocumentItem({ title, desc, required }) {
    return (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-dark-800">
            <div className={`w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 ${required ? 'bg-accent-danger/20' : 'bg-accent-warning/20'
                }`}>
                <span className="text-xs">{required ? '!' : '?'}</span>
            </div>
            <div>
                <span className="font-medium text-text-primary">{title}</span>
                {required && <span className="text-accent-danger text-xs ml-2">Required</span>}
                <span className="block text-sm text-text-muted mt-0.5">{desc}</span>
            </div>
        </div>
    );
}

export default Wizard;
