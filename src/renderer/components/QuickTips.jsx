import React, { useState, useMemo } from 'react';
import { BASIC_ALLOWANCES, WORK_EXPENSES, STUDENT_DEDUCTIONS, EXPAT_PROVISIONS } from '../utils/taxConstants2026';

// Comprehensive tips organized by category - Updated for 2026
const TIPS_BY_CATEGORY = {
    general: [
        {
            emoji: '📄',
            title: 'Lohnsteuerbescheinigung',
            text: 'Your most important document! Employer sends it by February. Contains all income & tax withheld.',
            new: false,
        },
        {
            emoji: '🏠',
            title: 'Home Office Pauschale',
            text: `Deduct €${WORK_EXPENSES.homeOffice.dailyRate}/day, max ${WORK_EXPENSES.homeOffice.maxDays} days (€${WORK_EXPENSES.homeOffice.maxAmount}/year). No receipts needed!`,
            new: false,
        },
        {
            emoji: '🚗',
            title: 'Pendlerpauschale',
            text: `Commute: €${WORK_EXPENSES.commuting.rateFirst20km}/km first 20km, €${WORK_EXPENSES.commuting.rateAbove20km}/km beyond. One-way distance × work days!`,
            new: false,
        },
        {
            emoji: '💻',
            title: 'Work Equipment (GWG)',
            text: `Items up to €${WORK_EXPENSES.workEquipment.immediateDeduction} net = immediate full deduction. Larger items depreciate over 3+ years.`,
            new: false,
        },
        {
            emoji: '📚',
            title: 'Arbeitnehmer-Pauschbetrag',
            text: `€${WORK_EXPENSES.pauschbetrag} automatic lump sum. Only itemize if expenses exceed this!`,
            new: false,
        },
        {
            emoji: '🏦',
            title: 'Bank Account Fees',
            text: `Claim €${WORK_EXPENSES.bankAccountFees.flatRate} for your salary account - no proof needed! Everyone forgets this.`,
            new: false,
        },
        {
            emoji: '🆕',
            title: 'Grundfreibetrag 2026',
            text: `Increased to €${BASIC_ALLOWANCES.grundfreibetrag.toLocaleString('de-DE')} - more income stays tax-free!`,
            new: true,
        },
        {
            emoji: '🏢',
            title: 'Union Dues 2026',
            text: 'NEW: Gewerkschaftsbeiträge now entered separately in ELSTER. Don\'t forget them!',
            new: true,
        },
    ],
    student: [
        {
            emoji: '🎓',
            title: 'Erst- vs. Zweitausbildung',
            text: `CRITICAL: First degree = max €${STUDENT_DEDUCTIONS.firstDegree.maxAnnual}/year (Sonderausgaben). Second degree = UNLIMITED (Werbungskosten)!`,
            important: true,
        },
        {
            emoji: '💰',
            title: 'Loss Carryforward',
            text: 'Doing Master/PhD? Accumulate losses while studying, use them when employed = instant tax savings!',
            important: true,
        },
        {
            emoji: '📖',
            title: 'What Counts as Second?',
            text: 'Master after Bachelor, second Bachelor, PhD, training after Ausbildung = all count as Zweitausbildung!',
        },
        {
            emoji: '💼',
            title: 'Mini-Job Taxes',
            text: 'Paid taxes on a mini-job? You can often get them back through filing! Works 4 years retroactively.',
        },
        {
            emoji: '🏠',
            title: 'Double Household',
            text: 'Studying away from parents? The "student apartment" could be deductible as second household.',
        },
        {
            emoji: '📅',
            title: 'File Up to 4 Years Later',
            text: 'Voluntary filing deadline = December 31, 4 years after tax year. Don\'t miss old refunds!',
        },
        {
            emoji: '🎒',
            title: 'Student Deductions',
            text: 'Laptop, textbooks, semester fees, commute to uni, study trips, internet - all count for second degree!',
        },
    ],
    expat: [
        {
            emoji: '📍',
            title: '183-Day Rule',
            text: `Present in Germany ${EXPAT_PROVISIONS.taxResidency.days183Rule}+ days = tax resident. Or earlier if Germany is your "Lebensmittelpunkt".`,
            important: true,
        },
        {
            emoji: '🌍',
            title: 'Double Taxation Treaties',
            text: 'Germany has treaties with 90+ countries. Foreign income may be exempt or credited!',
        },
        {
            emoji: '🏠',
            title: 'Double Household for Expats',
            text: `Keeping an apartment abroad? NEW 2026: Max €${WORK_EXPENSES.doubleHousehold.maxRentAbroadMonthly}/month deductible (was uncapped)!`,
            new: true,
        },
        {
            emoji: '✈️',
            title: 'Moving to Germany',
            text: 'Job-related relocation costs deductible: shipping, travel, temporary housing, even language courses!',
        },
        {
            emoji: '📊',
            title: 'Progressionsvorbehalt',
            text: 'Even tax-exempt foreign income may affect your German tax rate. Declare it!',
        },
        {
            emoji: '🗓️',
            title: 'Split-Year Taxation',
            text: 'Arrived mid-year? You may have "beschränkte Steuerpflicht" for part of the year - different rules apply.',
        },
        {
            emoji: '🇪🇺',
            title: 'EU Citizens',
            text: 'Family in the EU? You may claim child benefits and family-related deductions even for children abroad.',
        },
        {
            emoji: '💵',
            title: 'Foreign Bank Accounts',
            text: 'Investment income abroad must be declared. No automatic reporting, but penalties if caught!',
        },
    ],
};

function QuickTips({ userType }) {
    const [category, setCategory] = useState('general');
    const [currentTip, setCurrentTip] = useState(0);
    const [isExpanded, setIsExpanded] = useState(false);

    // Get tips for current category
    const tips = useMemo(() => {
        return TIPS_BY_CATEGORY[category] || TIPS_BY_CATEGORY.general;
    }, [category]);

    // Reset tip index when category changes
    const handleCategoryChange = (newCategory) => {
        setCategory(newCategory);
        setCurrentTip(0);
    };

    const nextTip = () => setCurrentTip((prev) => (prev + 1) % tips.length);
    const prevTip = () => setCurrentTip((prev) => (prev - 1 + tips.length) % tips.length);

    const tip = tips[currentTip];

    return (
        <div className="bg-dark-800 rounded-xl border border-dark-700 overflow-hidden">
            {/* Header */}
            <button
                onClick={() => setIsExpanded(!isExpanded)}
                className="w-full p-4 flex items-center justify-between hover:bg-dark-700/50 transition-colors"
            >
                <div className="flex items-center gap-2">
                    <span className="text-lg">💡</span>
                    <span className="font-medium text-text-primary">German Tax Tips</span>
                    <span className="text-xs text-text-muted bg-dark-600 px-2 py-0.5 rounded-full">
                        {currentTip + 1}/{tips.length}
                    </span>
                    {tip?.new && (
                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-accent-warning/20 text-accent-warning font-medium">
                            NEW 2026
                        </span>
                    )}
                </div>
                <svg
                    className={`w-5 h-5 text-text-muted transition-transform ${isExpanded ? 'rotate-180' : ''}`}
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
            </button>

            {/* Content */}
            {isExpanded && (
                <div className="p-4 pt-0 animate-slide-up">
                    {/* Category Tabs */}
                    <div className="flex gap-1 p-1 bg-dark-700 rounded-lg mb-3">
                        {[
                            { id: 'general', label: '📋 General', count: TIPS_BY_CATEGORY.general.length },
                            { id: 'student', label: '🎓 Students', count: TIPS_BY_CATEGORY.student.length },
                            { id: 'expat', label: '✈️ Expats', count: TIPS_BY_CATEGORY.expat.length },
                        ].map(tab => (
                            <button
                                key={tab.id}
                                onClick={() => handleCategoryChange(tab.id)}
                                className={`flex-1 px-2 py-1.5 rounded text-xs font-medium transition-colors ${category === tab.id
                                        ? 'bg-dark-600 text-text-primary'
                                        : 'text-text-muted hover:text-text-secondary'
                                    }`}
                            >
                                {tab.label}
                            </button>
                        ))}
                    </div>

                    {/* Tip Card */}
                    <div className={`rounded-lg p-4 mb-3 ${tip?.important
                            ? 'bg-accent-primary/10 border border-accent-primary/30'
                            : tip?.new
                                ? 'bg-accent-warning/10 border border-accent-warning/30'
                                : 'bg-dark-700'
                        }`}>
                        <div className="flex items-start gap-3">
                            <span className="text-2xl">{tip?.emoji}</span>
                            <div>
                                <div className="flex items-center gap-2 mb-1">
                                    <h4 className="font-medium text-text-primary">{tip?.title}</h4>
                                    {tip?.important && (
                                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-accent-primary/20 text-accent-primary">
                                            IMPORTANT
                                        </span>
                                    )}
                                    {tip?.new && (
                                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-accent-warning/20 text-accent-warning">
                                            NEW
                                        </span>
                                    )}
                                </div>
                                <p className="text-sm text-text-secondary">{tip?.text}</p>
                            </div>
                        </div>
                    </div>

                    {/* Navigation */}
                    <div className="flex items-center justify-between">
                        <button
                            onClick={prevTip}
                            className="p-2 rounded-lg hover:bg-dark-700 text-text-muted hover:text-text-primary transition-colors"
                        >
                            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                            </svg>
                        </button>

                        {/* Dots */}
                        <div className="flex gap-1 flex-wrap justify-center max-w-[200px]">
                            {tips.map((t, index) => (
                                <button
                                    key={index}
                                    onClick={() => setCurrentTip(index)}
                                    className={`w-2 h-2 rounded-full transition-colors ${index === currentTip
                                            ? 'bg-accent-primary'
                                            : t.important
                                                ? 'bg-accent-primary/50'
                                                : t.new
                                                    ? 'bg-accent-warning/50'
                                                    : 'bg-dark-600 hover:bg-dark-500'
                                        }`}
                                />
                            ))}
                        </div>

                        <button
                            onClick={nextTip}
                            className="p-2 rounded-lg hover:bg-dark-700 text-text-muted hover:text-text-primary transition-colors"
                        >
                            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                            </svg>
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
}

export default QuickTips;
