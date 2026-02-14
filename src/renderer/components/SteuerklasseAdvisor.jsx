import React, { useState, useMemo } from 'react';

/**
 * Steuerklasse Advisor - Helps married couples choose optimal tax class combination
 *
 * German tax classes:
 * - I: Single, divorced, widowed
 * - II: Single parent with child
 * - III: Married, higher earner (partner has V)
 * - IV: Married, similar income
 * - V: Married, lower earner (partner has III)
 * - VI: Second job
 */
function SteuerklasseAdvisor({ profile }) {
    const [income1, setIncome1] = useState(profile?.annualIncome || 0);
    const [income2, setIncome2] = useState(0);
    const [showAdvanced, setShowAdvanced] = useState(false);

    // Tax class combinations for married couples
    const taxClassCombinations = useMemo(() => {
        const total = income1 + income2;
        if (total === 0) return [];

        const ratio = Math.max(income1, income2) / total;

        // Simplified monthly withholding estimates (2024 values)
        // These are rough estimates for illustration
        const calculateWithholding = (income, taxClass) => {
            if (income <= 0) return 0;

            // Basic allowance 2024: ~11,604 EUR
            const grundfreibetrag = 11604;
            const taxableIncome = Math.max(0, income - grundfreibetrag);

            // Simplified progressive tax calculation
            let tax = 0;
            if (taxableIncome <= 17005) {
                tax = taxableIncome * 0.14;
            } else if (taxableIncome <= 66760) {
                tax = taxableIncome * 0.24;
            } else if (taxableIncome <= 277825) {
                tax = taxableIncome * 0.42;
            } else {
                tax = taxableIncome * 0.45;
            }

            // Apply tax class multipliers (rough estimates)
            switch (taxClass) {
                case 'III':
                    return tax * 0.6; // Lower withholding
                case 'V':
                    return tax * 1.2; // Higher withholding
                case 'IV':
                default:
                    return tax;
            }
        };

        // Calculate for each combination
        const combinations = [
            {
                name: 'III / V',
                description: 'Optimal when one partner earns significantly more (60%+)',
                partner1Class: 'III',
                partner2Class: 'V',
                bestFor: 'Unequal incomes',
                tax1: calculateWithholding(Math.max(income1, income2), 'III'),
                tax2: calculateWithholding(Math.min(income1, income2), 'V'),
            },
            {
                name: 'IV / IV',
                description: 'Best when both partners earn similar amounts',
                partner1Class: 'IV',
                partner2Class: 'IV',
                bestFor: 'Similar incomes',
                tax1: calculateWithholding(income1, 'IV'),
                tax2: calculateWithholding(income2, 'IV'),
            },
            {
                name: 'V / III',
                description: 'Same as III/V but reversed',
                partner1Class: 'V',
                partner2Class: 'III',
                bestFor: 'Partner 2 earns more',
                tax1: calculateWithholding(Math.min(income1, income2), 'V'),
                tax2: calculateWithholding(Math.max(income1, income2), 'III'),
            },
            {
                name: 'IV / IV + Faktor',
                description: 'Equal monthly deductions, no year-end surprises',
                partner1Class: 'IV',
                partner2Class: 'IV',
                factor: true,
                bestFor: 'Predictable payments',
                tax1: calculateWithholding(income1, 'IV'),
                tax2: calculateWithholding(income2, 'IV'),
            },
        ];

        // Add total tax and sort by lowest monthly withholding
        return combinations
            .map(c => ({
                ...c,
                totalTax: c.tax1 + c.tax2,
                monthlyWithholding: (c.tax1 + c.tax2) / 12,
            }))
            .sort((a, b) => a.totalTax - b.totalTax);
    }, [income1, income2]);

    // Recommendation based on income ratio
    const recommendation = useMemo(() => {
        const total = income1 + income2;
        if (total === 0) return null;

        const ratio = Math.max(income1, income2) / total;

        if (ratio >= 0.6) {
            return {
                combo: 'III / V',
                reason: 'With a 60%+ income difference, III/V minimizes monthly tax withholding.',
                icon: '💰',
            };
        } else if (ratio >= 0.55) {
            return {
                combo: 'IV / IV + Faktor',
                reason: 'With a moderate difference, IV/IV with Faktor gives fair withholding and avoids surprises.',
                icon: '⚖️',
            };
        } else {
            return {
                combo: 'IV / IV',
                reason: 'With similar incomes, IV/IV is the simplest and most balanced choice.',
                icon: '✅',
            };
        }
    }, [income1, income2]);

    // Only relevant for married couples
    if (profile?.maritalStatus !== 'married') {
        return (
            <div className="p-4 bg-dark-800 rounded-lg border border-dark-700">
                <div className="flex items-center gap-2 mb-3">
                    <span className="text-xl">💍</span>
                    <h3 className="font-semibold text-text-primary">Steuerklasse Advisor</h3>
                </div>
                <p className="text-sm text-text-muted">
                    This tool helps married couples optimize their tax class combination.
                    It's only relevant if you select "Married" in your profile.
                </p>
                <div className="mt-3 p-3 bg-dark-700 rounded-lg">
                    <p className="text-xs text-text-muted">
                        <strong>Your current status:</strong> {profile?.maritalStatus || 'Not set'}
                    </p>
                    <p className="text-xs text-text-muted mt-1">
                        Single taxpayers use Steuerklasse I (or II with children).
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-4">
            <div className="flex items-center gap-2">
                <span className="text-xl">💍</span>
                <h3 className="font-semibold text-text-primary">Steuerklasse Advisor</h3>
            </div>

            <p className="text-sm text-text-muted">
                Compare tax class combinations to optimize monthly withholding and year-end results.
            </p>

            {/* Income Inputs */}
            <div className="grid grid-cols-2 gap-3">
                <div>
                    <label className="text-xs text-text-muted block mb-1">Your Annual Income</label>
                    <div className="relative">
                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted">€</span>
                        <input
                            type="number"
                            value={income1 || ''}
                            onChange={(e) => setIncome1(Number(e.target.value) || 0)}
                            placeholder="45,000"
                            className="w-full pl-8 pr-3 py-2 bg-dark-700 border border-dark-600 rounded-lg text-text-primary text-sm focus:outline-none focus:border-accent-primary"
                        />
                    </div>
                </div>
                <div>
                    <label className="text-xs text-text-muted block mb-1">Partner's Annual Income</label>
                    <div className="relative">
                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted">€</span>
                        <input
                            type="number"
                            value={income2 || ''}
                            onChange={(e) => setIncome2(Number(e.target.value) || 0)}
                            placeholder="55,000"
                            className="w-full pl-8 pr-3 py-2 bg-dark-700 border border-dark-600 rounded-lg text-text-primary text-sm focus:outline-none focus:border-accent-primary"
                        />
                    </div>
                </div>
            </div>

            {/* Recommendation */}
            {recommendation && income1 > 0 && income2 > 0 && (
                <div className="p-3 bg-gradient-to-r from-accent-primary/10 to-accent-success/10 border border-accent-primary/30 rounded-lg">
                    <div className="flex items-start gap-2">
                        <span className="text-xl">{recommendation.icon}</span>
                        <div>
                            <p className="text-sm font-medium text-text-primary">
                                Recommended: <span className="text-accent-primary">{recommendation.combo}</span>
                            </p>
                            <p className="text-xs text-text-muted mt-1">{recommendation.reason}</p>
                        </div>
                    </div>
                </div>
            )}

            {/* Comparison Table */}
            {taxClassCombinations.length > 0 && income1 > 0 && income2 > 0 && (
                <div className="space-y-2">
                    <button
                        onClick={() => setShowAdvanced(!showAdvanced)}
                        className="text-xs text-accent-primary hover:underline flex items-center gap-1"
                    >
                        {showAdvanced ? '▼' : '▶'} Compare all combinations
                    </button>

                    {showAdvanced && (
                        <div className="overflow-hidden rounded-lg border border-dark-700">
                            <table className="w-full text-xs">
                                <thead className="bg-dark-700">
                                    <tr>
                                        <th className="py-2 px-3 text-left text-text-muted font-medium">Combination</th>
                                        <th className="py-2 px-3 text-right text-text-muted font-medium">Monthly</th>
                                        <th className="py-2 px-3 text-right text-text-muted font-medium">Annual</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {taxClassCombinations.map((combo, idx) => (
                                        <tr
                                            key={combo.name}
                                            className={`border-t border-dark-700 ${idx === 0 ? 'bg-accent-success/5' : ''}`}
                                        >
                                            <td className="py-2 px-3">
                                                <div className="flex items-center gap-2">
                                                    {idx === 0 && <span className="text-accent-success">★</span>}
                                                    <span className={idx === 0 ? 'text-text-primary font-medium' : 'text-text-secondary'}>
                                                        {combo.name}
                                                    </span>
                                                </div>
                                                <p className="text-text-muted text-[10px] mt-0.5">{combo.bestFor}</p>
                                            </td>
                                            <td className="py-2 px-3 text-right text-text-secondary">
                                                €{combo.monthlyWithholding.toLocaleString('de-DE', { maximumFractionDigits: 0 })}
                                            </td>
                                            <td className="py-2 px-3 text-right text-text-secondary">
                                                €{combo.totalTax.toLocaleString('de-DE', { maximumFractionDigits: 0 })}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            )}

            {/* Important Notes */}
            <div className="p-3 bg-dark-800 border border-dark-700 rounded-lg">
                <p className="text-xs font-medium text-text-primary mb-2">💡 Key Points:</p>
                <ul className="text-xs text-text-muted space-y-1">
                    <li>• III/V: More cash monthly, but may owe taxes at year-end</li>
                    <li>• IV/IV: Balanced, typically no surprise at tax time</li>
                    <li>• IV + Faktor: Fairest split, calculated individually</li>
                    <li>• You can change tax class once per year (unlimited from 2020)</li>
                </ul>
            </div>

            {/* ELSTER Hint */}
            <div className="text-xs text-text-muted p-2 bg-dark-700 rounded-lg">
                <span className="text-accent-primary">ELSTER:</span> Apply for tax class change at your local Finanzamt
                or via "Steuerklassenwechsel" form on ELSTER.
            </div>
        </div>
    );
}

export default SteuerklasseAdvisor;
