import React, { useState, useMemo, useCallback } from 'react';

/**
 * SmartExpenseTracker - Track and categorize deductible expenses
 * Helps users log expenses throughout the year with smart categorization
 */
function SmartExpenseTracker({ profile, existingDeductions, onAddExpense }) {
    const [expenses, setExpenses] = useState([]);
    const [newExpense, setNewExpense] = useState({
        description: '',
        amount: '',
        category: 'work-equipment',
        date: new Date().toISOString().split('T')[0],
    });
    const [showAddForm, setShowAddForm] = useState(false);

    // Expense categories with German tax relevance
    const categories = [
        {
            id: 'work-equipment',
            label: 'Work Equipment',
            labelDe: 'Arbeitsmittel',
            icon: '💻',
            hint: 'Laptop, phone, desk, chair, monitors',
            elsterField: 'Anlage N, Zeile 42-44',
            maxDeductible: null, // No limit
        },
        {
            id: 'home-office',
            label: 'Home Office',
            labelDe: 'Homeoffice',
            icon: '🏠',
            hint: 'Daily flat rate or dedicated room costs',
            elsterField: 'Anlage N, Zeile 44',
            maxDeductible: 1260, // 6€ x 210 days
        },
        {
            id: 'commute',
            label: 'Commute',
            labelDe: 'Pendlerpauschale',
            icon: '🚗',
            hint: 'Distance to work (0.30€/km first 20km, 0.38€/km beyond)',
            elsterField: 'Anlage N, Zeile 31-39',
            maxDeductible: null,
        },
        {
            id: 'professional-development',
            label: 'Training & Courses',
            labelDe: 'Fortbildung',
            icon: '📚',
            hint: 'Courses, books, certifications, conferences',
            elsterField: 'Anlage N, Zeile 44',
            maxDeductible: null,
        },
        {
            id: 'work-clothes',
            label: 'Work Clothing',
            labelDe: 'Arbeitskleidung',
            icon: '👔',
            hint: 'Safety gear, uniforms, protective clothing',
            elsterField: 'Anlage N, Zeile 42',
            maxDeductible: null,
        },
        {
            id: 'internet-phone',
            label: 'Internet & Phone',
            labelDe: 'Telefon & Internet',
            icon: '📱',
            hint: 'Work-related portion of bills',
            elsterField: 'Anlage N, Zeile 45',
            maxDeductible: null,
        },
        {
            id: 'donations',
            label: 'Donations',
            labelDe: 'Spenden',
            icon: '❤️',
            hint: 'Registered charities, political parties',
            elsterField: 'Mantelbogen, Zeile 45-56',
            maxDeductible: null, // 20% of income
        },
        {
            id: 'insurance',
            label: 'Insurance',
            labelDe: 'Versicherungen',
            icon: '🛡️',
            hint: 'Liability, accident, disability insurance',
            elsterField: 'Anlage Vorsorgeaufwand',
            maxDeductible: 1900, // Limit for employees
        },
        {
            id: 'moving',
            label: 'Moving Expenses',
            labelDe: 'Umzugskosten',
            icon: '📦',
            hint: 'Job-related relocation costs',
            elsterField: 'Anlage N, Zeile 46',
            maxDeductible: null,
        },
        {
            id: 'other',
            label: 'Other',
            labelDe: 'Sonstiges',
            icon: '📝',
            hint: 'Other work-related expenses',
            elsterField: 'Anlage N',
            maxDeductible: null,
        },
    ];

    // Calculate totals by category
    const totals = useMemo(() => {
        const byCategory = {};
        let grandTotal = 0;

        expenses.forEach(expense => {
            if (!byCategory[expense.category]) {
                byCategory[expense.category] = 0;
            }
            byCategory[expense.category] += expense.amount;
            grandTotal += expense.amount;
        });

        return { byCategory, grandTotal };
    }, [expenses]);

    // Estimated tax savings (at 30% marginal rate)
    const estimatedSavings = useMemo(() => {
        const marginalRate = 0.30;
        return totals.grandTotal * marginalRate;
    }, [totals.grandTotal]);

    // Add new expense
    const handleAddExpense = useCallback(() => {
        if (!newExpense.description || !newExpense.amount) return;

        const expense = {
            id: Date.now(),
            ...newExpense,
            amount: parseFloat(newExpense.amount),
        };

        setExpenses(prev => [...prev, expense]);
        setNewExpense({
            description: '',
            amount: '',
            category: 'work-equipment',
            date: new Date().toISOString().split('T')[0],
        });
        setShowAddForm(false);

        if (onAddExpense) {
            onAddExpense(expense);
        }
    }, [newExpense, onAddExpense]);

    // Delete expense
    const handleDeleteExpense = useCallback((id) => {
        setExpenses(prev => prev.filter(e => e.id !== id));
    }, []);

    // Get category info
    const getCategoryInfo = (categoryId) => {
        return categories.find(c => c.id === categoryId) || categories[categories.length - 1];
    };

    // Quick add buttons for common expenses
    const quickAddItems = [
        { category: 'home-office', description: 'Home Office Day', amount: 6 },
        { category: 'internet-phone', description: 'Monthly Internet (20%)', amount: 8 },
        { category: 'work-equipment', description: 'Office Supplies', amount: 50 },
    ];

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                    <span className="text-xl">📊</span>
                    <h3 className="font-semibold text-text-primary">Expense Tracker</h3>
                </div>
                <button
                    onClick={() => setShowAddForm(!showAddForm)}
                    className="text-xs px-2 py-1 bg-accent-primary text-white rounded hover:bg-accent-primary/80 transition-colors"
                >
                    + Add Expense
                </button>
            </div>

            {/* Summary Cards */}
            <div className="grid grid-cols-2 gap-3">
                <div className="p-3 bg-dark-800 rounded-lg border border-dark-700">
                    <p className="text-xs text-text-muted">Total Tracked</p>
                    <p className="text-xl font-bold text-text-primary">
                        €{totals.grandTotal.toLocaleString('de-DE', { minimumFractionDigits: 2 })}
                    </p>
                </div>
                <div className="p-3 bg-gradient-to-r from-accent-success/10 to-accent-primary/10 rounded-lg border border-accent-success/30">
                    <p className="text-xs text-text-muted">Est. Tax Savings</p>
                    <p className="text-xl font-bold text-accent-success">
                        €{estimatedSavings.toLocaleString('de-DE', { minimumFractionDigits: 2 })}
                    </p>
                </div>
            </div>

            {/* Quick Add Buttons */}
            <div className="flex gap-2 flex-wrap">
                {quickAddItems.map(item => (
                    <button
                        key={item.description}
                        onClick={() => {
                            const expense = {
                                id: Date.now(),
                                ...item,
                                date: new Date().toISOString().split('T')[0],
                            };
                            setExpenses(prev => [...prev, expense]);
                        }}
                        className="text-xs px-2 py-1 bg-dark-700 text-text-secondary rounded hover:bg-dark-600 transition-colors flex items-center gap-1"
                    >
                        {getCategoryInfo(item.category).icon} +€{item.amount}
                    </button>
                ))}
            </div>

            {/* Add Form */}
            {showAddForm && (
                <div className="p-3 bg-dark-800 border border-dark-700 rounded-lg space-y-3">
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <label className="text-xs text-text-muted block mb-1">Category</label>
                            <select
                                value={newExpense.category}
                                onChange={(e) => setNewExpense(prev => ({ ...prev, category: e.target.value }))}
                                className="w-full px-3 py-2 bg-dark-700 border border-dark-600 rounded text-text-primary text-sm focus:outline-none focus:border-accent-primary"
                            >
                                {categories.map(cat => (
                                    <option key={cat.id} value={cat.id}>
                                        {cat.icon} {cat.label}
                                    </option>
                                ))}
                            </select>
                        </div>
                        <div>
                            <label className="text-xs text-text-muted block mb-1">Date</label>
                            <input
                                type="date"
                                value={newExpense.date}
                                onChange={(e) => setNewExpense(prev => ({ ...prev, date: e.target.value }))}
                                className="w-full px-3 py-2 bg-dark-700 border border-dark-600 rounded text-text-primary text-sm focus:outline-none focus:border-accent-primary"
                            />
                        </div>
                    </div>
                    <div>
                        <label className="text-xs text-text-muted block mb-1">Description</label>
                        <input
                            type="text"
                            value={newExpense.description}
                            onChange={(e) => setNewExpense(prev => ({ ...prev, description: e.target.value }))}
                            placeholder="e.g., USB-C Hub for laptop"
                            className="w-full px-3 py-2 bg-dark-700 border border-dark-600 rounded text-text-primary text-sm focus:outline-none focus:border-accent-primary"
                        />
                    </div>
                    <div>
                        <label className="text-xs text-text-muted block mb-1">Amount (€)</label>
                        <input
                            type="number"
                            value={newExpense.amount}
                            onChange={(e) => setNewExpense(prev => ({ ...prev, amount: e.target.value }))}
                            placeholder="29.99"
                            step="0.01"
                            className="w-full px-3 py-2 bg-dark-700 border border-dark-600 rounded text-text-primary text-sm focus:outline-none focus:border-accent-primary"
                        />
                    </div>
                    <div className="flex gap-2">
                        <button
                            onClick={handleAddExpense}
                            className="flex-1 py-2 bg-accent-primary text-white rounded text-sm hover:bg-accent-primary/80 transition-colors"
                        >
                            Add Expense
                        </button>
                        <button
                            onClick={() => setShowAddForm(false)}
                            className="px-4 py-2 bg-dark-700 text-text-secondary rounded text-sm hover:bg-dark-600 transition-colors"
                        >
                            Cancel
                        </button>
                    </div>
                </div>
            )}

            {/* Category Breakdown */}
            {Object.keys(totals.byCategory).length > 0 && (
                <div className="space-y-2">
                    <p className="text-xs text-text-muted font-medium">By Category</p>
                    {Object.entries(totals.byCategory)
                        .sort(([, a], [, b]) => b - a)
                        .map(([categoryId, amount]) => {
                            const cat = getCategoryInfo(categoryId);
                            return (
                                <div key={categoryId} className="flex items-center gap-2">
                                    <span>{cat.icon}</span>
                                    <span className="flex-1 text-sm text-text-secondary">{cat.label}</span>
                                    <span className="text-sm font-medium text-text-primary">
                                        €{amount.toLocaleString('de-DE', { minimumFractionDigits: 2 })}
                                    </span>
                                </div>
                            );
                        })}
                </div>
            )}

            {/* Expense List */}
            {expenses.length > 0 && (
                <div className="space-y-2 max-h-48 overflow-y-auto">
                    <p className="text-xs text-text-muted font-medium">Recent Expenses</p>
                    {expenses
                        .sort((a, b) => new Date(b.date) - new Date(a.date))
                        .slice(0, 10)
                        .map(expense => {
                            const cat = getCategoryInfo(expense.category);
                            return (
                                <div
                                    key={expense.id}
                                    className="flex items-center gap-2 p-2 bg-dark-800 rounded group"
                                >
                                    <span>{cat.icon}</span>
                                    <div className="flex-1 min-w-0">
                                        <p className="text-sm text-text-primary truncate">{expense.description}</p>
                                        <p className="text-xs text-text-muted">{expense.date}</p>
                                    </div>
                                    <span className="text-sm font-medium text-accent-primary">
                                        €{expense.amount.toLocaleString('de-DE', { minimumFractionDigits: 2 })}
                                    </span>
                                    <button
                                        onClick={() => handleDeleteExpense(expense.id)}
                                        className="opacity-0 group-hover:opacity-100 text-text-muted hover:text-red-400 transition-all"
                                    >
                                        ✕
                                    </button>
                                </div>
                            );
                        })}
                </div>
            )}

            {/* Empty State */}
            {expenses.length === 0 && !showAddForm && (
                <div className="text-center py-6 text-text-muted">
                    <p className="text-3xl mb-2">📝</p>
                    <p className="text-sm">Start tracking expenses to see potential tax savings</p>
                    <button
                        onClick={() => setShowAddForm(true)}
                        className="mt-2 text-xs text-accent-primary hover:underline"
                    >
                        Add your first expense
                    </button>
                </div>
            )}

            {/* Tips */}
            <div className="p-2 bg-dark-700 rounded-lg text-xs text-text-muted">
                💡 <strong>Tip:</strong> Keep receipts! Items over €800 must be depreciated over useful life.
            </div>
        </div>
    );
}

export default SmartExpenseTracker;
