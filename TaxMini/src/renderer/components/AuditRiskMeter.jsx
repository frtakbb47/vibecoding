import React, { useMemo } from 'react';
import { useLanguage } from '../contexts/LanguageContext';

// Risk level thresholds (based on German tax averages)
const RISK_THRESHOLDS = {
    // Deduction amounts that may trigger audit
    homeOffice: { safe: 900, caution: 1200, high: 1260 },
    commuting: { safe: 2500, caution: 4000, high: 6000 },
    workEquipment: { safe: 500, caution: 1500, high: 3000 },
    education: { safe: 1000, caution: 3000, high: 6000 },
    workClothes: { safe: 200, caution: 500, high: 1000 },
    donations: { safe: 500, caution: 2000, high: 5000 },
    // Overall ratios
    deductionToIncome: { safe: 0.15, caution: 0.25, high: 0.35 }
};

// Calculate risk score and get recommendations
function calculateAuditRisk(taxData) {
    if (!taxData) {
        return { score: 0, level: 'unknown', factors: [], recommendations: [] };
    }

    const deductions = taxData.deductions || [];
    const income = taxData.employment?.grossIncome || 0;
    const factors = [];
    const recommendations = [];
    let riskScore = 0;

    // Calculate totals by category
    const categoryTotals = {};
    deductions.forEach(d => {
        const cat = d.category || 'other';
        categoryTotals[cat] = (categoryTotals[cat] || 0) + (d.amount || 0);
    });

    const totalDeductions = Object.values(categoryTotals).reduce((sum, v) => sum + v, 0);

    // Check each category against thresholds
    Object.entries(categoryTotals).forEach(([category, amount]) => {
        const threshold = RISK_THRESHOLDS[category];
        if (!threshold) return;

        if (amount > threshold.high) {
            riskScore += 30;
            factors.push({
                category,
                amount,
                severity: 'high',
                message: `${category} deductions (€${amount.toLocaleString()}) exceed typical limits`,
                messageDe: `${getCategoryLabel(category)} (€${amount.toLocaleString()}) übersteigt übliche Grenzen`
            });
            recommendations.push({
                category,
                message: `Ensure you have complete documentation for all ${category} expenses`,
                messageDe: `Stellen Sie sicher, dass Sie vollständige Belege für alle ${getCategoryLabel(category)} haben`
            });
        } else if (amount > threshold.caution) {
            riskScore += 15;
            factors.push({
                category,
                amount,
                severity: 'medium',
                message: `${category} deductions are above average`,
                messageDe: `${getCategoryLabel(category)} liegt über dem Durchschnitt`
            });
        }
    });

    // Check deduction-to-income ratio
    if (income > 0) {
        const ratio = totalDeductions / income;
        const ratioThreshold = RISK_THRESHOLDS.deductionToIncome;

        if (ratio > ratioThreshold.high) {
            riskScore += 35;
            factors.push({
                category: 'overall',
                severity: 'high',
                message: `Total deductions are ${Math.round(ratio * 100)}% of income (unusual)`,
                messageDe: `Gesamtabzüge sind ${Math.round(ratio * 100)}% des Einkommens (ungewöhnlich)`
            });
            recommendations.push({
                category: 'overall',
                message: 'Review all deductions and ensure each is well-documented',
                messageDe: 'Überprüfen Sie alle Abzüge und stellen Sie sicher, dass jeder gut dokumentiert ist'
            });
        } else if (ratio > ratioThreshold.caution) {
            riskScore += 15;
            factors.push({
                category: 'overall',
                severity: 'medium',
                message: `Total deductions are ${Math.round(ratio * 100)}% of income`,
                messageDe: `Gesamtabzüge sind ${Math.round(ratio * 100)}% des Einkommens`
            });
        }
    }

    // Check for missing documentation
    const undocumented = deductions.filter(d => !d.hasReceipt && d.amount > 50);
    if (undocumented.length > 0) {
        riskScore += 10;
        factors.push({
            category: 'documentation',
            severity: 'medium',
            message: `${undocumented.length} deductions over €50 without receipts`,
            messageDe: `${undocumented.length} Abzüge über €50 ohne Belege`
        });
        recommendations.push({
            category: 'documentation',
            message: 'Add receipts to strengthen your deduction claims',
            messageDe: 'Fügen Sie Belege hinzu, um Ihre Abzüge zu untermauern'
        });
    }

    // Determine risk level
    let level = 'low';
    if (riskScore >= 50) level = 'high';
    else if (riskScore >= 25) level = 'medium';

    // Cap at 100
    riskScore = Math.min(riskScore, 100);

    return {
        score: riskScore,
        level,
        factors,
        recommendations,
        totalDeductions,
        income
    };
}

function getCategoryLabel(category) {
    const labels = {
        homeOffice: 'Homeoffice',
        commuting: 'Fahrtkosten',
        workEquipment: 'Arbeitsmittel',
        education: 'Weiterbildung',
        workClothes: 'Arbeitskleidung',
        donations: 'Spenden',
        overall: 'Gesamt',
        documentation: 'Dokumentation'
    };
    return labels[category] || category;
}

// Main Audit Risk Meter Component
export function AuditRiskMeter({ taxData, showDetails = true, className = '' }) {
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const risk = useMemo(() => calculateAuditRisk(taxData), [taxData]);

    const getLevelConfig = (level) => {
        switch (level) {
            case 'high':
                return {
                    color: 'text-accent-danger',
                    bgColor: 'bg-accent-danger',
                    bgLight: 'bg-accent-danger/10',
                    borderColor: 'border-accent-danger/30',
                    icon: '⚠️',
                    label: isGerman ? 'Hohes Risiko' : 'High Risk',
                    description: isGerman
                        ? 'Ihre Abzüge könnten eine Prüfung auslösen'
                        : 'Your deductions may trigger an audit'
                };
            case 'medium':
                return {
                    color: 'text-accent-warning',
                    bgColor: 'bg-accent-warning',
                    bgLight: 'bg-accent-warning/10',
                    borderColor: 'border-accent-warning/30',
                    icon: '⚡',
                    label: isGerman ? 'Mittleres Risiko' : 'Moderate Risk',
                    description: isGerman
                        ? 'Einige Abzüge liegen über dem Durchschnitt'
                        : 'Some deductions are above average'
                };
            default:
                return {
                    color: 'text-accent-success',
                    bgColor: 'bg-accent-success',
                    bgLight: 'bg-accent-success/10',
                    borderColor: 'border-accent-success/30',
                    icon: '✅',
                    label: isGerman ? 'Geringes Risiko' : 'Low Risk',
                    description: isGerman
                        ? 'Ihre Abzüge liegen im normalen Bereich'
                        : 'Your deductions are within normal range'
                };
        }
    };

    const config = getLevelConfig(risk.level);

    return (
        <div className={`${config.bgLight} border ${config.borderColor} rounded-xl p-4 ${className}`}>
            {/* Header */}
            <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                    <span className="text-xl">{config.icon}</span>
                    <h3 className="font-semibold text-text-primary">
                        {isGerman ? 'Prüfungsrisiko' : 'Audit Risk'}
                    </h3>
                </div>
                <span className={`font-bold ${config.color}`}>
                    {config.label}
                </span>
            </div>

            {/* Risk Meter */}
            <div className="relative h-3 bg-dark-700 rounded-full overflow-hidden mb-3">
                <div
                    className={`absolute left-0 top-0 h-full ${config.bgColor} transition-all duration-500`}
                    style={{ width: `${risk.score}%` }}
                />
                {/* Markers */}
                <div className="absolute left-[25%] top-0 w-px h-full bg-dark-500" />
                <div className="absolute left-[50%] top-0 w-px h-full bg-dark-500" />
                <div className="absolute left-[75%] top-0 w-px h-full bg-dark-500" />
            </div>

            <p className="text-sm text-text-secondary mb-3">
                {config.description}
            </p>

            {/* Risk Factors */}
            {showDetails && risk.factors.length > 0 && (
                <div className="space-y-2 mb-3">
                    <h4 className="text-xs font-medium text-text-muted uppercase tracking-wider">
                        {isGerman ? 'Risikofaktoren' : 'Risk Factors'}
                    </h4>
                    {risk.factors.map((factor, idx) => (
                        <div
                            key={idx}
                            className={`text-sm p-2 rounded ${factor.severity === 'high'
                                ? 'bg-accent-danger/10 text-accent-danger'
                                : 'bg-accent-warning/10 text-accent-warning'
                                }`}
                        >
                            {isGerman ? factor.messageDe : factor.message}
                        </div>
                    ))}
                </div>
            )}

            {/* Recommendations */}
            {showDetails && risk.recommendations.length > 0 && (
                <div className="space-y-2">
                    <h4 className="text-xs font-medium text-text-muted uppercase tracking-wider">
                        {isGerman ? 'Empfehlungen' : 'Recommendations'}
                    </h4>
                    {risk.recommendations.map((rec, idx) => (
                        <div
                            key={idx}
                            className="text-sm text-text-secondary p-2 bg-dark-700 rounded flex items-start gap-2"
                        >
                            <span className="text-accent-primary">💡</span>
                            {isGerman ? rec.messageDe : rec.message}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}

// Compact version for header/sidebar
export function AuditRiskBadge({ taxData, onClick }) {
    const { language } = useLanguage();
    const isGerman = language === 'de';
    const risk = useMemo(() => calculateAuditRisk(taxData), [taxData]);

    const getColor = () => {
        switch (risk.level) {
            case 'high': return 'bg-accent-danger/20 text-accent-danger border-accent-danger/30';
            case 'medium': return 'bg-accent-warning/20 text-accent-warning border-accent-warning/30';
            default: return 'bg-accent-success/20 text-accent-success border-accent-success/30';
        }
    };

    const getIcon = () => {
        switch (risk.level) {
            case 'high': return '⚠️';
            case 'medium': return '⚡';
            default: return '✅';
        }
    };

    return (
        <button
            onClick={onClick}
            className={`flex items-center gap-1.5 px-2 py-1 rounded-full border text-xs font-medium transition-colors hover:opacity-80 ${getColor()}`}
            title={isGerman ? 'Prüfungsrisiko anzeigen' : 'View audit risk'}
        >
            <span>{getIcon()}</span>
            <span>{isGerman ? 'Risiko' : 'Risk'}: {risk.score}%</span>
        </button>
    );
}

export { calculateAuditRisk };
