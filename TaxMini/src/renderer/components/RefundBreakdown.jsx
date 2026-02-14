import React, { useMemo } from 'react';

/**
 * RefundBreakdown - Visual breakdown of where the refund comes from
 * Helps users understand their tax situation better
 */

function RefundBreakdown({ result, taxYear }) {
    if (!result) return null;

    const { income, deductions, calculation } = result;

    // Calculate breakdown components
    const breakdown = useMemo(() => {
        const items = [];

        // Tax paid
        if (income.taxPaid > 0) {
            items.push({
                id: 'tax_paid',
                label: 'Tax Already Paid',
                labelDE: 'Bereits gezahlte Steuer',
                amount: income.taxPaid,
                type: 'paid',
                description: 'This is what your employer withheld from your salary',
            });
        }

        // Deduction savings (rough estimate: 30% marginal rate)
        const marginalRate = 0.30;

        if (deductions?.homeOffice?.amount > 0) {
            items.push({
                id: 'home_office',
                label: 'Home Office',
                labelDE: 'Homeoffice-Pauschale',
                deduction: deductions.homeOffice.amount,
                savings: Math.round(deductions.homeOffice.amount * marginalRate),
                type: 'deduction',
                detail: `${deductions.homeOffice.days} days × €6`,
            });
        }

        if (deductions?.commuting?.amount > 0) {
            items.push({
                id: 'commuting',
                label: 'Commuting',
                labelDE: 'Pendlerpauschale',
                deduction: deductions.commuting.amount,
                savings: Math.round(deductions.commuting.amount * marginalRate),
                type: 'deduction',
                detail: `${deductions.commuting.distance}km × ${deductions.commuting.days} days`,
            });
        }

        if (deductions?.workEquipment?.amount > 0) {
            items.push({
                id: 'work_equipment',
                label: 'Work Equipment',
                labelDE: 'Arbeitsmittel',
                deduction: deductions.workEquipment.amount,
                savings: Math.round(deductions.workEquipment.amount * marginalRate),
                type: 'deduction',
            });
        }

        if (deductions?.professionalDevelopment?.amount > 0) {
            items.push({
                id: 'prof_dev',
                label: 'Professional Development',
                labelDE: 'Fortbildungskosten',
                deduction: deductions.professionalDevelopment.amount,
                savings: Math.round(deductions.professionalDevelopment.amount * marginalRate),
                type: 'deduction',
            });
        }

        if (deductions?.other?.amount > 0) {
            items.push({
                id: 'other',
                label: 'Other Deductions',
                labelDE: 'Sonstige Werbungskosten',
                deduction: deductions.other.amount,
                savings: Math.round(deductions.other.amount * marginalRate),
                type: 'deduction',
            });
        }

        return items;
    }, [income, deductions]);

    const totalDeductions = breakdown
        .filter(i => i.type === 'deduction')
        .reduce((sum, i) => sum + (i.deduction || 0), 0);

    const totalSavings = breakdown
        .filter(i => i.type === 'deduction')
        .reduce((sum, i) => sum + (i.savings || 0), 0);

    const isRefund = calculation.estimatedRefund > 0;

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between">
                <h3 className="font-semibold text-text-primary flex items-center gap-2">
                    <span className="w-6 h-6 rounded bg-accent-success/20 flex items-center justify-center">
                        <span className="text-sm">📊</span>
                    </span>
                    Refund Breakdown
                </h3>
            </div>

            {/* Visual Bar Chart */}
            <div className="space-y-3">
                {breakdown.filter(i => i.type === 'deduction').map((item) => {
                    const maxDeduction = Math.max(...breakdown.filter(i => i.type === 'deduction').map(i => i.deduction));
                    const percentage = (item.deduction / maxDeduction) * 100;

                    return (
                        <div key={item.id} className="space-y-1">
                            <div className="flex items-center justify-between text-sm">
                                <span className="text-text-secondary">{item.label}</span>
                                <div className="text-right">
                                    <span className="text-text-primary font-medium">
                                        €{item.deduction.toLocaleString('de-DE')}
                                    </span>
                                    <span className="text-accent-success text-xs ml-2">
                                        (saves ~€{item.savings.toLocaleString('de-DE')})
                                    </span>
                                </div>
                            </div>
                            <div className="h-2 bg-dark-700 rounded-full overflow-hidden">
                                <div
                                    className="h-full bg-gradient-to-r from-accent-primary to-accent-success rounded-full transition-all duration-500"
                                    style={{ width: `${percentage}%` }}
                                />
                            </div>
                            {item.detail && (
                                <p className="text-xs text-text-muted">{item.detail}</p>
                            )}
                        </div>
                    );
                })}
            </div>

            {/* Summary */}
            <div className="p-4 bg-dark-800 rounded-xl space-y-3">
                <div className="flex justify-between items-center">
                    <span className="text-text-secondary">Total Deductions</span>
                    <span className="text-text-primary font-medium">€{totalDeductions.toLocaleString('de-DE')}</span>
                </div>
                <div className="flex justify-between items-center">
                    <span className="text-text-secondary">Est. Tax Savings (30%)</span>
                    <span className="text-accent-success font-medium">€{totalSavings.toLocaleString('de-DE')}</span>
                </div>
                <div className="border-t border-dark-600 pt-3 flex justify-between items-center">
                    <span className="text-text-primary font-medium">
                        {isRefund ? 'Your Refund' : 'Tax Due'}
                    </span>
                    <span className={`text-xl font-bold ${isRefund ? 'text-accent-success' : 'text-accent-danger'}`}>
                        {isRefund ? '+' : '-'}€{Math.abs(calculation.estimatedRefund).toLocaleString('de-DE')}
                    </span>
                </div>
            </div>

            {/* How refund is calculated */}
            <div className="text-xs text-text-muted space-y-1 p-3 bg-dark-800/50 rounded-lg">
                <p className="font-medium text-text-secondary">How your refund is calculated:</p>
                <p>1. Start with gross income: €{income.grossSalary?.toLocaleString('de-DE') || 0}</p>
                <p>2. Subtract deductions: -€{totalDeductions.toLocaleString('de-DE')}</p>
                <p>3. Calculate tax on reduced income</p>
                <p>4. Compare to tax already paid: €{income.taxPaid?.toLocaleString('de-DE') || 0}</p>
                <p>5. Difference = your refund!</p>
            </div>
        </div>
    );
}

export default RefundBreakdown;
