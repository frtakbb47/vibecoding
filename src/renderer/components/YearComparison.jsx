import React, { useMemo } from 'react';
import { useLanguage } from '../contexts/LanguageContext';

// Year-over-Year Comparison Component
export function YearComparison({ currentYearData, previousYearData, className = '' }) {
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const comparison = useMemo(() => {
        return calculateComparison(currentYearData, previousYearData);
    }, [currentYearData, previousYearData]);

    if (!previousYearData) {
        return (
            <div className={`bg-dark-800 border border-dark-600 rounded-xl p-4 ${className}`}>
                <div className="flex items-center gap-3 text-text-secondary">
                    <span className="text-2xl">📊</span>
                    <div>
                        <h3 className="font-semibold text-text-primary">
                            {isGerman ? 'Jahresvergleich' : 'Year-over-Year'}
                        </h3>
                        <p className="text-sm">
                            {isGerman
                                ? 'Keine Vorjahresdaten verfügbar'
                                : 'No previous year data available'}
                        </p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={`bg-dark-800 border border-dark-600 rounded-xl overflow-hidden ${className}`}>
            {/* Header */}
            <div className="p-4 border-b border-dark-600 flex items-center justify-between">
                <div className="flex items-center gap-2">
                    <span className="text-xl">📊</span>
                    <h3 className="font-semibold text-text-primary">
                        {isGerman ? 'Jahresvergleich' : 'Year Comparison'}
                    </h3>
                </div>
                <div className="text-sm text-text-muted">
                    {comparison.currentYear} vs {comparison.previousYear}
                </div>
            </div>

            {/* Summary Cards */}
            <div className="grid grid-cols-2 gap-3 p-4 border-b border-dark-600">
                <ComparisonCard
                    label={isGerman ? 'Einkommen' : 'Income'}
                    current={comparison.income.current}
                    previous={comparison.income.previous}
                    change={comparison.income.change}
                    changePercent={comparison.income.changePercent}
                    isGerman={isGerman}
                />
                <ComparisonCard
                    label={isGerman ? 'Abzüge' : 'Deductions'}
                    current={comparison.deductions.current}
                    previous={comparison.deductions.previous}
                    change={comparison.deductions.change}
                    changePercent={comparison.deductions.changePercent}
                    isGerman={isGerman}
                    invertColors // More deductions is good
                />
            </div>

            {/* Category Breakdown */}
            <div className="p-4">
                <h4 className="text-sm font-medium text-text-muted mb-3">
                    {isGerman ? 'Nach Kategorie' : 'By Category'}
                </h4>
                <div className="space-y-2">
                    {comparison.categories.map((cat, idx) => (
                        <CategoryRow
                            key={idx}
                            category={cat}
                            isGerman={isGerman}
                        />
                    ))}
                </div>
            </div>

            {/* Insights */}
            {comparison.insights.length > 0 && (
                <div className="p-4 border-t border-dark-600 bg-dark-900/50">
                    <h4 className="text-sm font-medium text-text-muted mb-2">
                        {isGerman ? 'Erkenntnisse' : 'Insights'}
                    </h4>
                    <div className="space-y-1">
                        {comparison.insights.map((insight, idx) => (
                            <div key={idx} className="flex items-start gap-2 text-sm">
                                <span>{insight.icon}</span>
                                <span className={insight.positive ? 'text-accent-success' : 'text-text-secondary'}>
                                    {isGerman ? insight.messageDe : insight.message}
                                </span>
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}

function ComparisonCard({ label, current, previous, change, changePercent, isGerman, invertColors = false }) {
    const isPositive = invertColors ? change > 0 : change < 0;
    const isNegative = invertColors ? change < 0 : change > 0;

    return (
        <div className="bg-dark-700 rounded-lg p-3">
            <div className="text-xs text-text-muted mb-1">{label}</div>
            <div className="text-lg font-bold text-text-primary">
                €{current.toLocaleString()}
            </div>
            <div className="flex items-center gap-1 mt-1">
                {change !== 0 && (
                    <>
                        <span className={`text-xs ${isPositive ? 'text-accent-success' : isNegative ? 'text-accent-danger' : 'text-text-muted'}`}>
                            {change > 0 ? '↑' : '↓'} €{Math.abs(change).toLocaleString()}
                        </span>
                        <span className={`text-xs ${isPositive ? 'text-accent-success' : isNegative ? 'text-accent-danger' : 'text-text-muted'}`}>
                            ({changePercent > 0 ? '+' : ''}{changePercent}%)
                        </span>
                    </>
                )}
                {change === 0 && (
                    <span className="text-xs text-text-muted">
                        {isGerman ? 'Unverändert' : 'No change'}
                    </span>
                )}
            </div>
        </div>
    );
}

function CategoryRow({ category, isGerman }) {
    const change = category.current - category.previous;
    const changePercent = category.previous > 0
        ? Math.round((change / category.previous) * 100)
        : category.current > 0 ? 100 : 0;

    return (
        <div className="flex items-center justify-between py-1.5 border-b border-dark-700 last:border-0">
            <div className="flex items-center gap-2">
                <span className="text-sm">{category.icon}</span>
                <span className="text-sm text-text-primary">{isGerman ? category.labelDe : category.label}</span>
            </div>
            <div className="flex items-center gap-3">
                <span className="text-sm text-text-secondary">
                    €{category.current.toLocaleString()}
                </span>
                {change !== 0 && (
                    <span className={`text-xs ${change > 0 ? 'text-accent-success' : 'text-accent-danger'}`}>
                        {change > 0 ? '+' : ''}{changePercent}%
                    </span>
                )}
            </div>
        </div>
    );
}

function calculateComparison(currentData, previousData) {
    const currentYear = currentData?.taxYear || new Date().getFullYear();
    const previousYear = previousData?.taxYear || currentYear - 1;

    // Calculate totals
    const currentIncome = currentData?.employment?.grossIncome || 0;
    const previousIncome = previousData?.employment?.grossIncome || 0;

    const currentDeductions = (currentData?.deductions || []).reduce((sum, d) => sum + (d.amount || 0), 0);
    const previousDeductions = (previousData?.deductions || []).reduce((sum, d) => sum + (d.amount || 0), 0);

    // Calculate by category
    const categories = [];
    const categoryDefs = [
        { key: 'commute', icon: '🚗', label: 'Commuting', labelDe: 'Fahrtkosten' },
        { key: 'homeoffice', icon: '🏠', label: 'Home Office', labelDe: 'Homeoffice' },
        { key: 'equipment', icon: '💻', label: 'Equipment', labelDe: 'Arbeitsmittel' },
        { key: 'education', icon: '📚', label: 'Education', labelDe: 'Weiterbildung' },
        { key: 'insurance', icon: '🛡️', label: 'Insurance', labelDe: 'Versicherungen' },
        { key: 'other', icon: '📝', label: 'Other', labelDe: 'Sonstiges' }
    ];

    categoryDefs.forEach(cat => {
        const current = (currentData?.deductions || [])
            .filter(d => d.category === cat.key)
            .reduce((sum, d) => sum + (d.amount || 0), 0);
        const previous = (previousData?.deductions || [])
            .filter(d => d.category === cat.key)
            .reduce((sum, d) => sum + (d.amount || 0), 0);

        if (current > 0 || previous > 0) {
            categories.push({
                ...cat,
                current,
                previous
            });
        }
    });

    // Generate insights
    const insights = [];

    const deductionChange = currentDeductions - previousDeductions;
    if (deductionChange > 500) {
        insights.push({
            icon: '📈',
            positive: true,
            message: `You're claiming €${deductionChange.toLocaleString()} more in deductions`,
            messageDe: `Sie haben €${deductionChange.toLocaleString()} mehr Abzüge`
        });
    } else if (deductionChange < -500) {
        insights.push({
            icon: '📉',
            positive: false,
            message: `Deductions decreased by €${Math.abs(deductionChange).toLocaleString()}`,
            messageDe: `Abzüge sanken um €${Math.abs(deductionChange).toLocaleString()}`
        });
    }

    // Check for missing categories from last year
    const currentCategories = new Set((currentData?.deductions || []).map(d => d.category));
    const previousCategories = (previousData?.deductions || []).map(d => d.category);
    const missingCategories = [...new Set(previousCategories)].filter(c => !currentCategories.has(c));

    if (missingCategories.length > 0) {
        insights.push({
            icon: '💡',
            positive: false,
            message: `You claimed ${missingCategories.length} categories last year that you haven't added yet`,
            messageDe: `Sie hatten letztes Jahr ${missingCategories.length} Kategorien, die noch nicht hinzugefügt wurden`
        });
    }

    return {
        currentYear,
        previousYear,
        income: {
            current: currentIncome,
            previous: previousIncome,
            change: currentIncome - previousIncome,
            changePercent: previousIncome > 0
                ? Math.round(((currentIncome - previousIncome) / previousIncome) * 100)
                : 0
        },
        deductions: {
            current: currentDeductions,
            previous: previousDeductions,
            change: deductionChange,
            changePercent: previousDeductions > 0
                ? Math.round((deductionChange / previousDeductions) * 100)
                : 0
        },
        categories,
        insights
    };
}

// Export for use elsewhere
export { calculateComparison };
