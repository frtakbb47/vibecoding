import React, { useMemo } from 'react';
import {
    BASIC_ALLOWANCES,
    WORK_EXPENSES,
    TAX_YEAR,
    calculateTax2026,
    getMarginalTaxRate
} from '../utils/taxConstants2026';

/**
 * TaxOverview - Visual summary of income, deductions, and tax calculation
 * Provides a clear breakdown with visual progress bars
 * Updated for Steuerjahr 2026
 */
function TaxOverview({ profile, deductions, geminiResult, taxYear = TAX_YEAR }) {
    // German tax constants - now imported from centralized file
    const constants = {
        grundfreibetrag: BASIC_ALLOWANCES.grundfreibetrag,
        arbeitnehmerPauschbetrag: WORK_EXPENSES.pauschbetrag,
        homeOfficeCap: WORK_EXPENSES.homeOffice.maxAmount,
        sonderausgabenPauschbetrag: 36, // Fixed Sonderausgaben-Pauschbetrag
    };

    // Calculate all the values
    const calculations = useMemo(() => {
        const grossIncome = profile?.annualIncome || 0;

        // Calculate total deductions
        const workExpenses = (deductions?.workEquipment || 0) +
            (deductions?.homeOffice || 0) +
            (deductions?.commuting || 0) +
            (deductions?.professionalDevelopment || 0);

        const specialExpenses = (deductions?.insurance || 0) +
            (deductions?.donations || 0) +
            (deductions?.churchTax || 0);

        // Use Pauschbetrag if actual deductions are lower
        const effectiveWorkDeductions = Math.max(workExpenses, constants.arbeitnehmerPauschbetrag);
        const effectiveSpecialDeductions = Math.max(specialExpenses, constants.sonderausgabenPauschbetrag);

        const totalDeductions = effectiveWorkDeductions + effectiveSpecialDeductions;

        // Calculate taxable income (income - deductions - Grundfreibetrag is handled in calculateTax2026)
        const incomeAfterDeductions = Math.max(0, grossIncome - totalDeductions);

        // Use the centralized 2026 tax calculation
        const estimatedTax = calculateTax2026(incomeAfterDeductions);

        // Tax withheld vs tax owed
        const taxWithheld = geminiResult?.calculation?.taxWithheld || (grossIncome * 0.22); // More realistic estimate
        const refundOrOwed = taxWithheld - estimatedTax;

        // Taxable income for display (after Grundfreibetrag)
        const taxableIncome = Math.max(0, incomeAfterDeductions - constants.grundfreibetrag);

        return {
            grossIncome,
            workExpenses,
            specialExpenses,
            effectiveWorkDeductions,
            effectiveSpecialDeductions,
            totalDeductions,
            grundfreibetrag: constants.grundfreibetrag,
            taxableIncome,
            estimatedTax: Math.round(estimatedTax),
            taxWithheld: Math.round(taxWithheld),
            refundOrOwed: Math.round(refundOrOwed),
            effectiveTaxRate: grossIncome > 0 ? (estimatedTax / grossIncome * 100) : 0,
            marginalTaxRate: getMarginalTaxRate(incomeAfterDeductions),
            pauschbetragUsed: workExpenses < constants.arbeitnehmerPauschbetrag,
            potentialAdditionalSavings: Math.max(0, constants.arbeitnehmerPauschbetrag - workExpenses),
        };
    }, [profile, deductions, geminiResult, constants]);

    // Progress bar component
    const ProgressBar = ({ value, max, color = 'accent-primary', label }) => {
        const percentage = max > 0 ? Math.min(100, (value / max) * 100) : 0;
        return (
            <div className="relative h-2 bg-dark-700 rounded-full overflow-hidden">
                <div
                    className={`absolute inset-y-0 left-0 bg-${color} transition-all duration-500`}
                    style={{ width: `${percentage}%` }}
                />
            </div>
        );
    };

    // Format currency
    const formatCurrency = (value) => {
        return `€${Math.abs(value).toLocaleString('de-DE', { maximumFractionDigits: 0 })}`;
    };

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                    <span className="text-xl">📈</span>
                    <h3 className="font-semibold text-text-primary">Tax Overview</h3>
                    <span className="text-xs px-1.5 py-0.5 rounded bg-accent-primary/20 text-accent-primary">
                        {taxYear}
                    </span>
                </div>
                <div className="text-right text-xs">
                    <span className="text-text-muted">Grundfreibetrag: </span>
                    <span className="text-accent-success font-medium">€{constants.grundfreibetrag.toLocaleString('de-DE')}</span>
                </div>
            </div>

            {/* Income Flow Visualization */}
            <div className="p-4 bg-dark-800 rounded-lg border border-dark-700">
                <div className="space-y-4">
                    {/* Gross Income */}
                    <div>
                        <div className="flex justify-between items-center mb-1">
                            <span className="text-xs text-text-muted">Gross Income</span>
                            <span className="text-sm font-bold text-text-primary">{formatCurrency(calculations.grossIncome)}</span>
                        </div>
                        <div className="h-3 bg-accent-primary rounded-full" />
                    </div>

                    {/* Deductions Arrow */}
                    <div className="flex items-center gap-2 py-1">
                        <div className="flex-1 border-t border-dashed border-dark-600" />
                        <span className="text-xs text-red-400">− {formatCurrency(calculations.totalDeductions)}</span>
                        <div className="flex-1 border-t border-dashed border-dark-600" />
                    </div>

                    {/* Grundfreibetrag */}
                    <div className="flex items-center gap-2 py-1">
                        <div className="flex-1 border-t border-dashed border-dark-600" />
                        <span className="text-xs text-green-400">− {formatCurrency(calculations.grundfreibetrag)} (tax-free)</span>
                        <div className="flex-1 border-t border-dashed border-dark-600" />
                    </div>

                    {/* Taxable Income */}
                    <div>
                        <div className="flex justify-between items-center mb-1">
                            <span className="text-xs text-text-muted">Taxable Income</span>
                            <span className="text-sm font-bold text-text-primary">{formatCurrency(calculations.taxableIncome)}</span>
                        </div>
                        <div className="relative h-3 bg-dark-700 rounded-full overflow-hidden">
                            <div
                                className="absolute inset-y-0 left-0 bg-accent-secondary transition-all duration-500"
                                style={{ width: `${(calculations.taxableIncome / calculations.grossIncome) * 100}%` }}
                            />
                        </div>
                    </div>
                </div>
            </div>

            {/* Deductions Breakdown */}
            <div className="p-4 bg-dark-800 rounded-lg border border-dark-700">
                <p className="text-xs text-text-muted font-medium mb-3">Deductions Breakdown</p>

                <div className="space-y-3">
                    {/* Work Expenses */}
                    <div>
                        <div className="flex justify-between items-center mb-1">
                            <span className="text-xs text-text-secondary">📋 Werbungskosten</span>
                            <div className="flex items-center gap-2">
                                <span className="text-xs text-text-muted">
                                    {calculations.workExpenses < constants.arbeitnehmerPauschbetrag && '(Pauschale used)'}
                                </span>
                                <span className="text-sm text-text-primary">{formatCurrency(calculations.effectiveWorkDeductions)}</span>
                            </div>
                        </div>
                        <ProgressBar
                            value={calculations.effectiveWorkDeductions}
                            max={calculations.totalDeductions}
                            color="accent-primary"
                        />
                    </div>

                    {/* Special Expenses */}
                    <div>
                        <div className="flex justify-between items-center mb-1">
                            <span className="text-xs text-text-secondary">🎁 Sonderausgaben</span>
                            <span className="text-sm text-text-primary">{formatCurrency(calculations.effectiveSpecialDeductions)}</span>
                        </div>
                        <ProgressBar
                            value={calculations.effectiveSpecialDeductions}
                            max={calculations.totalDeductions}
                            color="accent-secondary"
                        />
                    </div>

                    {/* Tax-Free Amount */}
                    <div>
                        <div className="flex justify-between items-center mb-1">
                            <span className="text-xs text-text-secondary">🛡️ Grundfreibetrag</span>
                            <span className="text-sm text-text-primary">{formatCurrency(calculations.grundfreibetrag)}</span>
                        </div>
                        <ProgressBar
                            value={calculations.grundfreibetrag}
                            max={calculations.grossIncome}
                            color="accent-success"
                        />
                    </div>
                </div>
            </div>

            {/* Tax Rates */}
            <div className="grid grid-cols-2 gap-3">
                <div className="p-3 bg-dark-800 rounded-lg border border-dark-700">
                    <p className="text-xs text-text-muted">Effective Tax Rate</p>
                    <p className="text-lg font-bold text-text-primary">{calculations.effectiveTaxRate.toFixed(1)}%</p>
                </div>
                <div className="p-3 bg-dark-800 rounded-lg border border-dark-700">
                    <p className="text-xs text-text-muted">Marginal Rate</p>
                    <p className="text-lg font-bold text-text-primary">{calculations.marginalTaxRate}%</p>
                </div>
            </div>

            {/* Refund/Owed Box */}
            <div className={`p-4 rounded-lg border ${calculations.refundOrOwed >= 0
                ? 'bg-gradient-to-r from-accent-success/10 to-green-500/5 border-accent-success/30'
                : 'bg-gradient-to-r from-red-500/10 to-orange-500/5 border-red-500/30'
                }`}>
                <div className="flex items-center justify-between">
                    <div>
                        <p className="text-xs text-text-muted">
                            {calculations.refundOrOwed >= 0 ? 'Estimated Refund' : 'Estimated Tax Due'}
                        </p>
                        <p className={`text-2xl font-bold ${calculations.refundOrOwed >= 0 ? 'text-accent-success' : 'text-red-400'
                            }`}>
                            {calculations.refundOrOwed >= 0 ? '+' : '-'}{formatCurrency(calculations.refundOrOwed)}
                        </p>
                    </div>
                    <span className="text-4xl">
                        {calculations.refundOrOwed >= 0 ? '🎉' : '💳'}
                    </span>
                </div>

                <div className="mt-3 pt-3 border-t border-dark-600/50 grid grid-cols-2 gap-2 text-xs">
                    <div className="flex justify-between">
                        <span className="text-text-muted">Tax Withheld:</span>
                        <span className="text-text-secondary">{formatCurrency(calculations.taxWithheld)}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-text-muted">Tax Owed:</span>
                        <span className="text-text-secondary">{formatCurrency(calculations.estimatedTax)}</span>
                    </div>
                </div>
            </div>

            {/* Note */}
            <p className="text-xs text-text-muted text-center">
                * Estimates based on simplified tax calculation. Actual results may vary.
            </p>
        </div>
    );
}

export default TaxOverview;
