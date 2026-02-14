import React, { useState, useMemo } from 'react';
import { WORK_EXPENSES, SPECIAL_EXPENSES, STUDENT_DEDUCTIONS, getMarginalTaxRate, BASIC_ALLOWANCES } from '../utils/taxConstants2026';

/**
 * DeductionOptimizer - Suggests potential deductions the user might be missing
 * Based on their profile, shows personalized tax-saving opportunities
 * Updated for Steuerjahr 2026
 */

// Deduction opportunities database - Updated for 2026
const DEDUCTION_OPPORTUNITIES = [
    {
        id: 'home_office',
        category: 'Werbungskosten',
        name: 'Home Office Pauschale',
        nameDE: 'Homeoffice-Pauschale',
        maxAmount: WORK_EXPENSES.homeOffice.maxAmount, // €1,260 (€6/day × 210 days)
        description: `Deduct €${WORK_EXPENSES.homeOffice.dailyRate}/day for working from home (max ${WORK_EXPENSES.homeOffice.maxDays} days = €${WORK_EXPENSES.homeOffice.maxAmount}/year)`,
        eligibleFor: ['employed', 'student'],
        questions: ['Do you work from home at least occasionally?'],
        tip: 'Keep a simple log of your home office days. No receipts needed! Works even if you have a dedicated office at work.',
        elsterField: 'Anlage N, Zeile 44',
        isNew: false,
    },
    {
        id: 'commute',
        category: 'Werbungskosten',
        name: 'Commuting Allowance',
        nameDE: 'Entfernungspauschale',
        maxAmount: 5500, // Increased for 2026 due to higher rate above 20km
        description: `First 20km: €${WORK_EXPENSES.commuting.rateFirst20km}/km | 21+ km: €${WORK_EXPENSES.commuting.rateAbove20km}/km (one-way distance)`,
        eligibleFor: ['employed', 'student'],
        questions: ['Do you commute to work or university?', 'How far is it?'],
        tip: 'Use Google Maps for exact distance. The higher rate (€0.38) from km 21 saves significant tax!',
        elsterField: 'Anlage N, Zeile 31-35',
        isNew: false,
    },
    {
        id: 'work_equipment',
        category: 'Werbungskosten',
        name: 'Work Equipment',
        nameDE: 'Arbeitsmittel',
        maxAmount: 1500,
        description: `Computers, laptops, monitors, desks, chairs, software. Items up to €${WORK_EXPENSES.workEquipment.immediateDeduction} net = immediate full deduction!`,
        eligibleFor: ['employed', 'student'],
        questions: ['Did you buy equipment for work?'],
        tip: 'Laptops, monitors, office chairs - all work! Items over €800 must be depreciated over 3 years.',
        elsterField: 'Anlage N, Zeile 42',
        isNew: false,
    },
    {
        id: 'professional_development',
        category: 'Werbungskosten',
        name: 'Professional Development',
        nameDE: 'Fortbildungskosten',
        maxAmount: 3000,
        description: 'Courses, certifications, books, conferences, online learning related to your job',
        eligibleFor: ['employed', 'student'],
        questions: ['Did you take any courses or buy professional books?'],
        tip: 'Udemy, Coursera, LinkedIn Learning - all count if job-related! Include travel costs for conferences.',
        elsterField: 'Anlage N, Zeile 43',
        isNew: false,
    },
    {
        id: 'union_dues',
        category: 'Werbungskosten',
        name: 'Union Membership Dues',
        nameDE: 'Gewerkschaftsbeiträge',
        maxAmount: 500,
        description: 'Monthly union membership fees are fully deductible. NEW: Separately listed from 2026!',
        eligibleFor: ['employed'],
        questions: ['Are you a member of a trade union (Gewerkschaft)?'],
        tip: 'IG Metall, ver.di, GEW - all union dues are deductible. Request a yearly statement from your union.',
        elsterField: 'Anlage N, Zeile 41 (separate from 2026)',
        isNew: true, // Changed for 2026
    },
    {
        id: 'double_household',
        category: 'Werbungskosten',
        name: 'Double Household',
        nameDE: 'Doppelte Haushaltsführung',
        maxAmount: 15000,
        description: `Second home for work: max €${WORK_EXPENSES.doubleHousehold.maxRentMonthly}/month in Germany, €${WORK_EXPENSES.doubleHousehold.maxRentAbroadMonthly}/month abroad (NEW 2026!)`,
        eligibleFor: ['employed', 'expat'],
        questions: ['Do you maintain a second home for work?'],
        tip: 'Perfect for expats! Home country apartment counts. Include family visit travel (€0.30/km).',
        elsterField: 'Anlage N, Zeile 61-87',
        isNew: true, // New abroad cap in 2026
    },
    {
        id: 'moving_expenses',
        category: 'Werbungskosten',
        name: 'Job-Related Moving',
        nameDE: 'Umzugskosten',
        maxAmount: 1500,
        description: 'Moving costs when relocating for a new job or to be closer to your workplace',
        eligibleFor: ['employed', 'expat'],
        questions: ['Did you move for work in 2026?'],
        tip: 'Moving company costs + travel + Pauschale for other expenses (€964 single, €1,928 married).',
        elsterField: 'Anlage N, Zeile 47',
        isNew: false,
    },
    {
        id: 'work_clothing',
        category: 'Werbungskosten',
        name: 'Work Clothing',
        nameDE: 'Berufskleidung',
        maxAmount: 600,
        description: 'Uniforms, safety gear, or specific work attire + cleaning costs (not regular clothes)',
        eligibleFor: ['employed'],
        questions: ['Do you need special clothing for work?'],
        tip: 'Lab coats, safety shoes, construction gear. Include cleaning costs (€0.77-1.10/kg estimate).',
        elsterField: 'Anlage N, Zeile 42',
        isNew: false,
    },
    {
        id: 'application_costs',
        category: 'Werbungskosten',
        name: 'Job Application Costs',
        nameDE: 'Bewerbungskosten',
        maxAmount: 500,
        description: `€${WORK_EXPENSES.applicationCosts.perApplication} per application with documents, €${WORK_EXPENSES.applicationCosts.perOnlineApplication} for online applications`,
        eligibleFor: ['employed', 'student', 'expat'],
        questions: ['Did you apply for jobs this year?'],
        tip: 'Includes photos, portfolio printing, travel to interviews. Keep a list of all applications!',
        elsterField: 'Anlage N, Zeile 47',
        isNew: false,
    },
    {
        id: 'bank_account',
        category: 'Werbungskosten',
        name: 'Bank Account for Salary',
        nameDE: 'Kontoführungsgebühren',
        maxAmount: WORK_EXPENSES.bankAccountFees.flatRate,
        description: `Flat rate of €${WORK_EXPENSES.bankAccountFees.flatRate} for your salary account - no receipts needed!`,
        eligibleFor: ['employed', 'student', 'expat'],
        questions: [],
        tip: 'Just claim €16 - everyone with a salary account can do this without any proof.',
        elsterField: 'Anlage N, Zeile 46',
        isNew: false,
    },
    {
        id: 'insurance',
        category: 'Sonderausgaben',
        name: 'Insurance Premiums',
        nameDE: 'Versicherungsbeiträge',
        maxAmount: SPECIAL_EXPENSES.insurance.otherInsurance.maxSingle,
        description: 'Liability insurance, accident insurance, professional indemnity, unemployment insurance',
        eligibleFor: ['employed', 'student', 'expat'],
        questions: ['Do you have private liability or other insurance?'],
        tip: 'Haftpflichtversicherung (liability) is almost always deductible! Also: Rechtsschutz, Unfall.',
        elsterField: 'Anlage Vorsorgeaufwand',
        isNew: false,
    },
    {
        id: 'donations',
        category: 'Sonderausgaben',
        name: 'Charitable Donations',
        nameDE: 'Spenden',
        maxAmount: 5000,
        description: `Donations to registered German charities (up to ${SPECIAL_EXPENSES.donations.maxPercent}% of income). E-sports clubs now eligible!`,
        eligibleFor: ['employed', 'student', 'expat'],
        questions: ['Did you donate to any charities?'],
        tip: 'NEW 2026: E-sports organizations are now gemeinnützig! Get Spendenbescheinigung for donations over €300.',
        elsterField: 'Anlage Sonderausgaben',
        isNew: true,
    },
    {
        id: 'church_tax',
        category: 'Sonderausgaben',
        name: 'Church Tax',
        nameDE: 'Kirchensteuer',
        maxAmount: 3000,
        description: 'Church tax paid (8-9% of income tax) is fully deductible as special expense',
        eligibleFor: ['employed'],
        questions: ['Are you a registered member of a church?'],
        tip: 'Already on your Lohnsteuerbescheinigung - verify the amount matches!',
        elsterField: 'Anlage Sonderausgaben, Zeile 4',
        isNew: false,
    },
    {
        id: 'student_first_degree',
        category: 'Sonderausgaben',
        name: 'First Degree Costs',
        nameDE: 'Erstausbildung (Sonderausgaben)',
        maxAmount: SPECIAL_EXPENSES.firstDegree.maxAmount,
        description: `First degree/Ausbildung: Max €${SPECIAL_EXPENSES.firstDegree.maxAmount}/year. Tuition, books, materials, laptop.`,
        eligibleFor: ['student'],
        questions: ['Is this your FIRST degree (Bachelor, Ausbildung)?'],
        tip: '⚠️ First degree = Sonderausgaben (no loss carryforward). Consider getting a mini-job to use them!',
        elsterField: 'Anlage Sonderausgaben',
        isNew: false,
    },
    {
        id: 'student_second_degree',
        category: 'Werbungskosten',
        name: 'Second Degree Costs',
        nameDE: 'Zweitausbildung (Werbungskosten)',
        maxAmount: 15000,
        description: 'UNLIMITED deduction for second degree (Master, second Bachelor, PhD, training after Ausbildung)!',
        eligibleFor: ['student'],
        questions: ['Is this your SECOND degree (Master, PhD, second Bachelor)?'],
        tip: '🎉 Loss carryforward possible! Accumulate deductions while studying, use them when you start working!',
        elsterField: 'Anlage N',
        isNew: false,
        isHighlight: true,
    },
    {
        id: 'internet_phone',
        category: 'Werbungskosten',
        name: 'Internet & Phone',
        nameDE: 'Internet und Telefon',
        maxAmount: 300,
        description: 'Work-related portion of your internet and phone bills. ~20% usually accepted without proof.',
        eligibleFor: ['employed', 'student'],
        questions: ['Do you use personal internet/phone for work?'],
        tip: 'If working from home, 40-50% may be justified. Keep one month as sample documentation.',
        elsterField: 'Anlage N, Zeile 46',
        isNew: false,
    },
];

function DeductionOptimizer({ profile, existingDeductions, taxYear = 2026, onAddDeduction }) {
    const [expandedId, setExpandedId] = useState(null);
    const [checkedDeductions, setCheckedDeductions] = useState({});
    const [filter, setFilter] = useState('all'); // 'all', 'new', 'werbungskosten', 'sonderausgaben'

    // Filter relevant deductions based on profile
    const relevantDeductions = useMemo(() => {
        const userTypes = [];
        if (profile?.isStudent) userTypes.push('student');
        if (profile?.isExpat) userTypes.push('expat');
        if (profile?.employmentType === 'employed' || !profile?.isStudent) userTypes.push('employed');

        let filtered = DEDUCTION_OPPORTUNITIES.filter(deduction =>
            deduction.eligibleFor.some(type => userTypes.includes(type))
        );

        // Apply category filter
        if (filter === 'new') {
            filtered = filtered.filter(d => d.isNew);
        } else if (filter === 'werbungskosten') {
            filtered = filtered.filter(d => d.category === 'Werbungskosten');
        } else if (filter === 'sonderausgaben') {
            filtered = filtered.filter(d => d.category === 'Sonderausgaben');
        }

        return filtered;
    }, [profile, filter]);

    // Calculate potential savings using proper marginal rate
    const potentialSavings = useMemo(() => {
        const checkedItems = relevantDeductions.filter(d => checkedDeductions[d.id]);
        const total = checkedItems.reduce((sum, d) => sum + d.maxAmount, 0);
        // Use actual marginal rate if we have income info
        const income = profile?.annualIncome || 40000;
        const marginalRate = getMarginalTaxRate(income - BASIC_ALLOWANCES.grundfreibetrag) / 100;
        return Math.round(total * marginalRate);
    }, [relevantDeductions, checkedDeductions, profile]);

    const handleToggle = (id) => {
        setCheckedDeductions(prev => ({
            ...prev,
            [id]: !prev[id]
        }));
    };

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h3 className="font-semibold text-text-primary flex items-center gap-2">
                        <span className="w-6 h-6 rounded bg-accent-warning/20 flex items-center justify-center">
                            <span className="text-sm">💡</span>
                        </span>
                        Deduction Finder
                        <span className="text-xs px-1.5 py-0.5 rounded bg-accent-primary/20 text-accent-primary">2026</span>
                    </h3>
                    <p className="text-xs text-text-muted mt-1">
                        Check deductions that apply to you
                    </p>
                </div>
                {potentialSavings > 0 && (
                    <div className="text-right">
                        <p className="text-xs text-text-muted">Potential Savings</p>
                        <p className="text-lg font-bold text-accent-success">~€{potentialSavings.toLocaleString()}</p>
                    </div>
                )}
            </div>

            {/* Filter Tabs */}
            <div className="flex gap-1 p-1 bg-dark-700 rounded-lg">
                {[
                    { id: 'all', label: 'All' },
                    { id: 'new', label: '🆕 New 2026' },
                    { id: 'werbungskosten', label: 'Work Expenses' },
                    { id: 'sonderausgaben', label: 'Special' },
                ].map(tab => (
                    <button
                        key={tab.id}
                        onClick={() => setFilter(tab.id)}
                        className={`flex-1 px-2 py-1.5 rounded text-xs font-medium transition-colors ${filter === tab.id
                            ? 'bg-dark-600 text-text-primary'
                            : 'text-text-muted hover:text-text-secondary'
                            }`}
                    >
                        {tab.label}
                    </button>
                ))}
            </div>

            {/* Deduction List */}
            <div className="space-y-2 max-h-80 overflow-y-auto">
                {relevantDeductions.length === 0 ? (
                    <div className="text-center py-6 text-text-muted text-sm">
                        No deductions match this filter
                    </div>
                ) : (
                    relevantDeductions.map((deduction) => (
                        <div
                            key={deduction.id}
                            className={`border rounded-lg transition-all ${deduction.isHighlight
                                    ? 'border-accent-primary/50 bg-accent-primary/5'
                                    : checkedDeductions[deduction.id]
                                        ? 'border-accent-success/50 bg-accent-success/5'
                                        : 'border-dark-600 hover:border-dark-500'
                                }`}
                        >
                            <div
                                className="p-3 flex items-start gap-3 cursor-pointer"
                                onClick={() => handleToggle(deduction.id)}
                            >
                                {/* Checkbox */}
                                <div className={`w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0 mt-0.5 transition-all ${checkedDeductions[deduction.id]
                                    ? 'bg-accent-success border-accent-success'
                                    : 'border-dark-500'
                                    }`}>
                                    {checkedDeductions[deduction.id] && (
                                        <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                                        </svg>
                                    )}
                                </div>

                                {/* Content */}
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-2 flex-wrap">
                                        <p className="font-medium text-text-primary text-sm">{deduction.name}</p>
                                        {deduction.isNew && (
                                            <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-accent-warning/20 text-accent-warning">
                                                NEW 2026
                                            </span>
                                        )}
                                        {deduction.isHighlight && (
                                            <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-accent-primary/20 text-accent-primary">
                                                ★ BEST FOR STUDENTS
                                            </span>
                                        )}
                                        <span className="text-xs text-accent-primary font-medium ml-auto">
                                            up to €{deduction.maxAmount.toLocaleString()}
                                        </span>
                                    </div>
                                    <p className="text-xs text-text-muted mt-0.5">{deduction.nameDE}</p>
                                </div>

                                {/* Expand button */}
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        setExpandedId(expandedId === deduction.id ? null : deduction.id);
                                    }}
                                    className="p-1 hover:bg-dark-700 rounded transition-colors"
                                >
                                    <svg
                                        className={`w-4 h-4 text-text-muted transition-transform ${expandedId === deduction.id ? 'rotate-180' : ''}`}
                                        fill="none" viewBox="0 0 24 24" stroke="currentColor"
                                    >
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                    </svg>
                                </button>
                            </div>
                            {expandedId === deduction.id && (
                                <div className="px-3 pb-3 pt-0 border-t border-dark-600 mt-1">
                                    <p className="text-xs text-text-secondary mt-3">{deduction.description}</p>

                                    <div className="mt-3 p-2 bg-dark-700 rounded-lg">
                                        <p className="text-xs text-accent-primary flex items-center gap-1">
                                            <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                            </svg>
                                            Pro Tip
                                        </p>
                                        <p className="text-xs text-text-muted mt-1">{deduction.tip}</p>
                                    </div>

                                    <div className="mt-2 flex items-center justify-between">
                                        <span className="text-xs text-text-muted">{deduction.category}</span>
                                        <span className="text-xs text-text-muted">{deduction.elsterField}</span>
                                    </div>
                                </div>
                            )}
                        </div>
                    ))
                )}
            </div>

            {/* Summary */}
            {Object.values(checkedDeductions).some(v => v) && (
                <div className="p-3 bg-accent-success/10 border border-accent-success/30 rounded-lg">
                    <p className="text-sm text-text-primary">
                        <span className="font-medium">{Object.values(checkedDeductions).filter(v => v).length}</span> deductions selected
                    </p>
                    <p className="text-xs text-text-muted mt-1">
                        Make sure to upload receipts or documentation for each
                    </p>
                </div>
            )}
        </div>
    );
}

export default DeductionOptimizer;
