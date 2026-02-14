import React, { useState, useEffect, useRef } from 'react';
import { formatCurrency } from '../utils/promptBuilder';

// Confetti component for celebration effect
function Confetti({ active }) {
    const colors = ['#818cf8', '#34d399', '#fbbf24', '#f472b6', '#60a5fa', '#a78bfa'];
    const [pieces, setPieces] = useState([]);

    useEffect(() => {
        if (active) {
            const newPieces = Array.from({ length: 50 }, (_, i) => ({
                id: i,
                left: Math.random() * 100,
                color: colors[Math.floor(Math.random() * colors.length)],
                delay: Math.random() * 0.5,
                size: Math.random() * 8 + 4,
            }));
            setPieces(newPieces);

            // Clear confetti after animation
            const timer = setTimeout(() => setPieces([]), 3500);
            return () => clearTimeout(timer);
        }
    }, [active]);

    if (!active || pieces.length === 0) return null;

    return (
        <div className="fixed inset-0 pointer-events-none z-50 overflow-hidden">
            {pieces.map((piece) => (
                <div
                    key={piece.id}
                    className="confetti-piece"
                    style={{
                        left: `${piece.left}%`,
                        backgroundColor: piece.color,
                        width: piece.size,
                        height: piece.size,
                        animationDelay: `${piece.delay}s`,
                        borderRadius: Math.random() > 0.5 ? '50%' : '2px',
                    }}
                />
            ))}
        </div>
    );
}

// Animated counter hook
function useCountUp(end, duration = 1500, start = 0) {
    const [count, setCount] = useState(start);
    const countRef = useRef(start);

    useEffect(() => {
        const startTime = Date.now();
        const startVal = countRef.current;

        const animate = () => {
            const now = Date.now();
            const progress = Math.min((now - startTime) / duration, 1);
            // Easing function (ease-out)
            const eased = 1 - Math.pow(1 - progress, 3);
            const current = startVal + (end - startVal) * eased;

            setCount(current);
            countRef.current = current;

            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };

        requestAnimationFrame(animate);
    }, [end, duration]);

    return count;
}

function ResultsPanel({ result, taxYear }) {
    const [showConfetti, setShowConfetti] = useState(false);
    const hasShownConfetti = useRef(false);

    // Trigger confetti on first refund display
    useEffect(() => {
        if (result && result.calculation?.estimatedRefund > 0 && !hasShownConfetti.current) {
            hasShownConfetti.current = true;
            setShowConfetti(true);
        }
    }, [result]);

    if (!result) {
        return (
            <div className="h-full flex flex-col">
                <div className="p-4 border-b border-dark-700">
                    <h2 className="font-semibold text-text-primary">Tax Summary</h2>
                    <p className="text-xs text-text-muted">Steuerjahr {taxYear}</p>
                </div>

                <div className="flex-1 flex items-center justify-center p-6">
                    <div className="text-center">
                        <div className="w-20 h-20 rounded-2xl bg-dark-700 flex items-center justify-center mx-auto mb-4 animate-float">
                            <svg className="w-10 h-10 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                        </div>
                        <h3 className="text-lg font-medium text-text-primary mb-2">
                            Awaiting Analysis
                        </h3>
                        <p className="text-sm text-text-muted max-w-xs">
                            Upload documents, copy the prompt to Gemini, and paste the response to see your tax summary
                        </p>

                        {/* Helpful tips while waiting */}
                        <div className="mt-6 p-4 bg-dark-800 rounded-xl text-left">
                            <p className="text-xs font-medium text-text-secondary mb-2">💡 Did you know?</p>
                            <p className="text-xs text-text-muted">
                                The average German employee gets a tax refund of €1,095. With the right deductions, you could get more!
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    const { income, deductions, specialExpenses, calculation, missingDocuments, warnings, summary } = result;
    const isRefund = calculation.estimatedRefund > 0;

    // Animated refund amount
    const animatedRefund = useCountUp(Math.abs(calculation.estimatedRefund), 1500, 0);

    return (
        <div className="h-full flex flex-col">
            {/* Confetti celebration */}
            <Confetti active={showConfetti} />

            {/* Header */}
            <div className="p-4 border-b border-dark-700">
                <div className="flex items-center justify-between">
                    <div>
                        <h2 className="font-semibold text-text-primary">Tax Summary</h2>
                        <p className="text-xs text-text-muted">Steuerjahr {taxYear}</p>
                    </div>
                    {isRefund && (
                        <span className="badge badge-success animate-bounce-in">
                            🎉 Refund!
                        </span>
                    )}
                </div>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-4">
                {/* Refund Hero Card */}
                <div className={`p-6 rounded-2xl animate-success-pop relative overflow-hidden ${isRefund
                    ? 'bg-gradient-to-br from-accent-success/20 to-emerald-900/20 border border-accent-success/30'
                    : 'bg-gradient-to-br from-accent-danger/20 to-red-900/20 border border-accent-danger/30'
                    }`}>
                    {/* Shimmer effect */}
                    <div className="absolute inset-0 animate-shimmer" />

                    <p className="text-sm text-text-secondary mb-1 relative">
                        {isRefund ? '🎉 Estimated Refund' : 'Estimated Tax Due'}
                    </p>
                    <p className={`text-4xl font-bold animate-count-glow relative ${isRefund ? 'text-accent-success' : 'text-accent-danger'}`}>
                        {isRefund ? '+' : '-'}€{animatedRefund.toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </p>
                    <p className="text-xs text-text-muted mt-2 relative">
                        Steuererstattung / Nachzahlung
                    </p>

                    {/* ELSTER hint */}
                    <div className="mt-4 pt-3 border-t border-white/10 relative">
                        <p className="text-xs text-text-muted flex items-center gap-1">
                            <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            ELSTER: This appears in your Steuerbescheid
                        </p>
                    </div>
                </div>

                {/* Summary */}
                {summary && (
                    <div className="card">
                        <p className="text-sm text-text-secondary">{summary}</p>
                    </div>
                )}

                {/* Income Section */}
                <div className="card">
                    <h3 className="font-medium text-text-primary mb-4 flex items-center gap-2">
                        <span className="w-6 h-6 rounded bg-accent-primary/20 flex items-center justify-center">
                            <span className="text-xs">💰</span>
                        </span>
                        Income (Einkommen)
                        <span className="ml-auto text-xs text-text-muted font-normal">Anlage N</span>
                    </h3>

                    <div className="space-y-2">
                        <ResultRow label="Gross Salary (Bruttolohn)" value={formatCurrency(income.grossSalary)} elsterField="Zeile 6" />
                        <ResultRow label="Tax Paid (Lohnsteuer)" value={formatCurrency(income.taxPaid)} highlight="danger" elsterField="Zeile 7" />
                        <ResultRow label="Social Security" value={formatCurrency(
                            (income.socialSecurity?.health || 0) +
                            (income.socialSecurity?.pension || 0) +
                            (income.socialSecurity?.unemployment || 0) +
                            (income.socialSecurity?.care || 0)
                        )} />
                        {income.churchTax > 0 && (
                            <ResultRow label="Church Tax" value={formatCurrency(income.churchTax)} elsterField="Zeile 8" />
                        )}
                    </div>
                </div>

                {/* Deductions Section */}
                <div className="card">
                    <h3 className="font-medium text-text-primary mb-4 flex items-center gap-2">
                        <span className="w-6 h-6 rounded bg-accent-success/20 flex items-center justify-center">
                            <span className="text-xs">📝</span>
                        </span>
                        Deductions (Werbungskosten)
                    </h3>

                    <div className="space-y-2">
                        {deductions.homeOffice?.amount > 0 && (
                            <ResultRow
                                label={`Home Office (${deductions.homeOffice.days} days)`}
                                value={formatCurrency(deductions.homeOffice.amount)}
                                highlight="success"
                            />
                        )}
                        {deductions.commuting?.amount > 0 && (
                            <ResultRow
                                label={`Commuting (${deductions.commuting.distance}km × ${deductions.commuting.days}d)`}
                                value={formatCurrency(deductions.commuting.amount)}
                                highlight="success"
                            />
                        )}
                        {deductions.workEquipment?.amount > 0 && (
                            <ResultRow
                                label="Work Equipment"
                                value={formatCurrency(deductions.workEquipment.amount)}
                                highlight="success"
                            />
                        )}
                        {deductions.professionalDevelopment?.amount > 0 && (
                            <ResultRow
                                label="Professional Development"
                                value={formatCurrency(deductions.professionalDevelopment.amount)}
                                highlight="success"
                            />
                        )}
                        {deductions.other?.amount > 0 && (
                            <ResultRow
                                label="Other Deductions"
                                value={formatCurrency(deductions.other.amount)}
                                highlight="success"
                            />
                        )}
                        <div className="pt-2 mt-2 border-t border-dark-600">
                            <ResultRow
                                label="Total Deductions"
                                value={formatCurrency(deductions.totalDeductions)}
                                bold
                                highlight="success"
                            />
                        </div>
                    </div>
                </div>

                {/* Special Expenses */}
                {specialExpenses?.totalSpecialExpenses > 0 && (
                    <div className="card">
                        <h3 className="font-medium text-text-primary mb-4 flex items-center gap-2">
                            <span className="w-6 h-6 rounded bg-accent-warning/20 flex items-center justify-center">
                                <span className="text-xs">🏥</span>
                            </span>
                            Special Expenses (Sonderausgaben)
                        </h3>

                        <div className="space-y-2">
                            {specialExpenses.insurances?.amount > 0 && (
                                <ResultRow
                                    label="Insurance Premiums"
                                    value={formatCurrency(specialExpenses.insurances.amount)}
                                />
                            )}
                            {specialExpenses.donations?.amount > 0 && (
                                <ResultRow
                                    label="Donations"
                                    value={formatCurrency(specialExpenses.donations.amount)}
                                />
                            )}
                            <div className="pt-2 mt-2 border-t border-dark-600">
                                <ResultRow
                                    label="Total Special Expenses"
                                    value={formatCurrency(specialExpenses.totalSpecialExpenses)}
                                    bold
                                />
                            </div>
                        </div>
                    </div>
                )}

                {/* Calculation Steps */}
                {calculation.steps && calculation.steps.length > 0 && (
                    <div className="card">
                        <h3 className="font-medium text-text-primary mb-4 flex items-center gap-2">
                            <span className="w-6 h-6 rounded bg-dark-600 flex items-center justify-center">
                                <span className="text-xs">🧮</span>
                            </span>
                            Calculation Steps
                        </h3>

                        <div className="space-y-2">
                            {calculation.steps.map((step, index) => (
                                <p key={index} className="text-sm text-text-secondary">
                                    {index + 1}. {step}
                                </p>
                            ))}
                        </div>
                    </div>
                )}

                {/* Warnings */}
                {warnings && warnings.length > 0 && (
                    <div className="bg-accent-warning/10 border border-accent-warning/30 rounded-xl p-4">
                        <h3 className="font-medium text-accent-warning mb-2 flex items-center gap-2">
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            Warnings
                        </h3>
                        <ul className="space-y-1">
                            {warnings.map((warning, index) => (
                                <li key={index} className="text-sm text-text-secondary">• {warning}</li>
                            ))}
                        </ul>
                    </div>
                )}

                {/* Missing Documents */}
                {missingDocuments && missingDocuments.length > 0 && (
                    <div className="bg-accent-danger/10 border border-accent-danger/30 rounded-xl p-4">
                        <h3 className="font-medium text-accent-danger mb-2 flex items-center gap-2">
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                            Missing Documents
                        </h3>
                        <ul className="space-y-1">
                            {missingDocuments.map((doc, index) => (
                                <li key={index} className="text-sm text-text-secondary">• {doc}</li>
                            ))}
                        </ul>
                    </div>
                )}

                {/* Next Steps */}
                <div className="card bg-dark-750">
                    <h3 className="font-medium text-text-primary mb-3 flex items-center gap-2">
                        <span className="text-xs">📋</span>
                        Next Steps
                    </h3>
                    <div className="space-y-2 text-sm text-text-secondary">
                        <div className="flex items-start gap-2">
                            <span className="w-5 h-5 rounded-full bg-accent-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                                <span className="text-xs text-accent-primary">1</span>
                            </span>
                            <span>Review your deductions and add any missing receipts</span>
                        </div>
                        <div className="flex items-start gap-2">
                            <span className="w-5 h-5 rounded-full bg-accent-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                                <span className="text-xs text-accent-primary">2</span>
                            </span>
                            <span>Export your summary using the Export button</span>
                        </div>
                        <div className="flex items-start gap-2">
                            <span className="w-5 h-5 rounded-full bg-accent-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                                <span className="text-xs text-accent-primary">3</span>
                            </span>
                            <span>File via <a href="https://www.elster.de" target="_blank" rel="noopener" className="text-accent-primary hover:underline">ELSTER</a> or consult a Steuerberater</span>
                        </div>
                    </div>
                </div>

                {/* Disclaimer */}
                <div className="text-xs text-text-muted text-center p-4 border-t border-dark-700 mt-4">
                    ⚠️ This is an estimate only. For official tax filing, consult a Steuerberater or use ELSTER.
                </div>
            </div>
        </div>
    );
}

function ResultRow({ label, value, highlight, bold, elsterField }) {
    const valueColor = highlight === 'success'
        ? 'text-accent-success'
        : highlight === 'danger'
            ? 'text-accent-danger'
            : 'text-text-primary';

    return (
        <div className="flex justify-between items-center group">
            <span className={`text-sm ${bold ? 'font-medium text-text-primary' : 'text-text-secondary'} flex items-center gap-2`}>
                {label}
                {elsterField && (
                    <span className="opacity-0 group-hover:opacity-100 transition-opacity text-xs text-text-muted bg-dark-700 px-1.5 py-0.5 rounded">
                        {elsterField}
                    </span>
                )}
            </span>
            <span className={`text-sm font-mono ${bold ? 'font-bold' : 'font-medium'} ${valueColor}`}>
                {value}
            </span>
        </div>
    );
}

export default ResultsPanel;
