import React from 'react';
import { formatCurrency } from '../utils/promptBuilder';

// German Tax Constants
const TAX_CONSTANTS = {
    2025: { grundfreibetrag: 11784, arbeitnehmerPauschbetrag: 1230 },
    2024: { grundfreibetrag: 11604, arbeitnehmerPauschbetrag: 1230 },
    2023: { grundfreibetrag: 10908, arbeitnehmerPauschbetrag: 1230 },
};

function TaxComparison({ result, taxYear }) {
    if (!result?.deductions?.totalDeductions) return null;

    const constants = TAX_CONSTANTS[taxYear] || TAX_CONSTANTS[2025];
    const actualDeductions = result.deductions.totalDeductions;
    const lumpSum = constants.arbeitnehmerPauschbetrag;
    const usingActual = actualDeductions > lumpSum;
    const benefit = usingActual ? actualDeductions - lumpSum : 0;

    return (
        <div className="bg-dark-800 rounded-xl p-4 border border-dark-700">
            <h4 className="text-sm font-medium text-text-primary mb-3 flex items-center gap-2">
                <span className="text-lg">📊</span>
                Deduction Comparison
            </h4>

            <div className="space-y-3">
                {/* Visual comparison */}
                <div className="relative h-12 bg-dark-700 rounded-lg overflow-hidden">
                    {/* Lump sum bar */}
                    <div
                        className="absolute inset-y-0 left-0 bg-dark-500 flex items-center justify-end pr-2"
                        style={{ width: `${Math.min((lumpSum / Math.max(actualDeductions, lumpSum)) * 100, 100)}%` }}
                    >
                        <span className="text-xs text-text-muted whitespace-nowrap">
                            Pauschbetrag
                        </span>
                    </div>
                    {/* Actual bar (if higher) */}
                    {usingActual && (
                        <div
                            className="absolute inset-y-0 left-0 bg-gradient-to-r from-accent-success/50 to-accent-success flex items-center justify-end pr-2"
                            style={{ width: '100%' }}
                        >
                            <span className="text-xs text-white font-medium whitespace-nowrap">
                                +{formatCurrency(benefit)} extra
                            </span>
                        </div>
                    )}
                </div>

                {/* Comparison details */}
                <div className="grid grid-cols-2 gap-4 text-sm">
                    <div className={`p-3 rounded-lg ${!usingActual ? 'bg-accent-primary/10 border border-accent-primary/30' : 'bg-dark-700'}`}>
                        <p className="text-text-muted text-xs mb-1">Lump Sum (automatic)</p>
                        <p className={`font-mono font-medium ${!usingActual ? 'text-accent-primary' : 'text-text-secondary'}`}>
                            {formatCurrency(lumpSum)}
                        </p>
                        {!usingActual && (
                            <p className="text-xs text-accent-primary mt-1">✓ Being used</p>
                        )}
                    </div>
                    <div className={`p-3 rounded-lg ${usingActual ? 'bg-accent-success/10 border border-accent-success/30' : 'bg-dark-700'}`}>
                        <p className="text-text-muted text-xs mb-1">Your Actual Expenses</p>
                        <p className={`font-mono font-medium ${usingActual ? 'text-accent-success' : 'text-text-secondary'}`}>
                            {formatCurrency(actualDeductions)}
                        </p>
                        {usingActual && (
                            <p className="text-xs text-accent-success mt-1">✓ Being used</p>
                        )}
                    </div>
                </div>

                {/* Explanation */}
                <div className="text-xs text-text-muted bg-dark-900 rounded-lg p-3">
                    {usingActual ? (
                        <>
                            <span className="text-accent-success">Great!</span> Your actual work expenses
                            exceed the automatic €{lumpSum} allowance by{' '}
                            <span className="text-accent-success font-medium">{formatCurrency(benefit)}</span>.
                            This means more tax savings for you!
                        </>
                    ) : (
                        <>
                            Your documented expenses are below the automatic €{lumpSum} Arbeitnehmer-Pauschbetrag.
                            The tax office will use the lump sum instead – no receipts needed for this!
                        </>
                    )}
                </div>
            </div>
        </div>
    );
}

export default TaxComparison;
