import React, { useState, useMemo } from 'react';
import { DEADLINES_2026 } from '../utils/taxConstants2026';

/**
 * TaxCalendar - Shows important German tax deadlines
 * Helps users stay on track with their tax obligations
 * Updated for Steuerjahr 2026
 */

// German tax deadlines for tax year 2026
const TAX_DEADLINES = [
    {
        id: 'lohnsteuer_available',
        date: '2027-02-28',
        title: 'Lohnsteuerbescheinigung Available',
        titleDE: 'Lohnsteuerbescheinigung verfügbar',
        description: 'Employers must provide your annual tax certificate (Lohnsteuerbescheinigung) by end of February. Check your payroll portal!',
        type: 'document',
        icon: '📄',
        actionable: 'Request from HR if not received',
    },
    {
        id: 'elster_start',
        date: '2027-03-01',
        title: 'ELSTER Opens for 2026',
        titleDE: 'ELSTER für 2026 verfügbar',
        description: 'ELSTER online portal typically opens for the new tax year in early March. Pre-fill data may be available.',
        type: 'document',
        icon: '🖥️',
        actionable: 'Check elster.de for availability',
    },
    {
        id: 'advance_payment_q1',
        date: '2027-03-10',
        title: 'Q1 Advance Payment Due',
        titleDE: 'Einkommensteuer-Vorauszahlung Q1',
        description: 'Quarterly advance tax payment if you\'re required to make prepayments (Vorauszahlungen).',
        type: 'payment',
        icon: '💰',
        forAdvancePayersOnly: true,
    },
    {
        id: 'advance_payment_q2',
        date: '2027-06-10',
        title: 'Q2 Advance Payment Due',
        titleDE: 'Einkommensteuer-Vorauszahlung Q2',
        description: 'Quarterly advance tax payment if you\'re required to make prepayments.',
        type: 'payment',
        icon: '💰',
        forAdvancePayersOnly: true,
    },
    {
        id: 'filing_deadline_self',
        date: '2027-07-31',
        title: '⚠️ Filing Deadline (Self)',
        titleDE: 'Abgabefrist (ohne Steuerberater)',
        description: 'IMPORTANT: Last day to submit your 2026 tax return if filing yourself without a tax advisor (Steuerberater).',
        type: 'deadline',
        icon: '🚨',
        important: true,
        actionable: 'Submit via ELSTER or mail',
    },
    {
        id: 'advance_payment_q3',
        date: '2027-09-10',
        title: 'Q3 Advance Payment Due',
        titleDE: 'Einkommensteuer-Vorauszahlung Q3',
        description: 'Quarterly advance tax payment if you\'re required to make prepayments.',
        type: 'payment',
        icon: '💰',
        forAdvancePayersOnly: true,
    },
    {
        id: 'advance_payment_q4',
        date: '2027-12-10',
        title: 'Q4 Advance Payment Due',
        titleDE: 'Einkommensteuer-Vorauszahlung Q4',
        description: 'Quarterly advance tax payment if you\'re required to make prepayments.',
        type: 'payment',
        icon: '💰',
        forAdvancePayersOnly: true,
    },
    {
        id: 'filing_deadline_advisor',
        date: '2028-02-28',
        title: 'Filing Deadline (with Advisor)',
        titleDE: 'Abgabefrist (mit Steuerberater)',
        description: 'Extended deadline when using a Steuerberater or Lohnsteuerhilfeverein. Must be registered with them before July 31!',
        type: 'deadline',
        icon: '📅',
        important: true,
        actionable: 'Hire advisor before July 31 deadline',
    },
    {
        id: 'amendment_deadline',
        date: '2028-12-31',
        title: 'Amendment Deadline',
        titleDE: 'Änderungsfrist',
        description: 'Last day to submit corrections or objections (Einspruch) to your 2026 tax assessment.',
        type: 'deadline',
        icon: '✏️',
    },
    {
        id: 'voluntary_filing',
        date: '2030-12-31',
        title: 'Voluntary Filing Deadline',
        titleDE: 'Freiwillige Veranlagung',
        description: 'Last day to file a voluntary return (Antragsveranlagung) for 2026 to claim refunds. 4-year window from end of tax year.',
        type: 'deadline',
        icon: '🕐',
        tip: 'Students often forget they can file up to 4 years later!',
    },
];

function TaxCalendar({ taxYear = 2026, showAdvancePayments = false }) {
    const [showAll, setShowAll] = useState(false);
    const [filter, setFilter] = useState('upcoming'); // 'upcoming', 'all', 'important'

    // Process and sort deadlines
    const processedDeadlines = useMemo(() => {
        const currentDate = new Date();

        return TAX_DEADLINES
            .filter(d => showAdvancePayments || !d.forAdvancePayersOnly)
            .map(deadline => {
                const date = new Date(deadline.date);
                const isPast = date < currentDate;
                const daysUntil = Math.ceil((date - currentDate) / (1000 * 60 * 60 * 24));
                const isUpcoming = daysUntil > 0 && daysUntil <= 60;
                const isUrgent = daysUntil > 0 && daysUntil <= 14;

                return {
                    ...deadline,
                    dateObj: date,
                    isPast,
                    daysUntil,
                    isUpcoming,
                    isUrgent,
                };
            })
            .sort((a, b) => a.dateObj - b.dateObj);
    }, [showAdvancePayments]);

    // Apply filter
    const filteredDeadlines = useMemo(() => {
        switch (filter) {
            case 'important':
                return processedDeadlines.filter(d => d.important);
            case 'upcoming':
                return processedDeadlines.filter(d => !d.isPast);
            default:
                return processedDeadlines;
        }
    }, [processedDeadlines, filter]);

    const displayDeadlines = showAll ? filteredDeadlines : filteredDeadlines.slice(0, 5);

    // Find next important deadline
    const nextImportant = processedDeadlines.find(d => d.important && !d.isPast);

    return (
        <div className="space-y-3">
            {/* Header */}
            <div className="flex items-center justify-between">
                <h3 className="font-semibold text-text-primary flex items-center gap-2">
                    <span className="w-6 h-6 rounded bg-accent-danger/20 flex items-center justify-center">
                        <span className="text-sm">📅</span>
                    </span>
                    Tax Calendar
                    <span className="text-xs px-1.5 py-0.5 rounded bg-dark-600 text-text-muted">
                        Steuerjahr {taxYear}
                    </span>
                </h3>
            </div>

            {/* Filter tabs */}
            <div className="flex gap-1 p-0.5 bg-dark-700 rounded-lg text-xs">
                {[
                    { id: 'upcoming', label: 'Upcoming' },
                    { id: 'important', label: '⚠️ Important' },
                    { id: 'all', label: 'All' },
                ].map(tab => (
                    <button
                        key={tab.id}
                        onClick={() => { setFilter(tab.id); setShowAll(false); }}
                        className={`flex-1 px-2 py-1 rounded transition-colors ${filter === tab.id
                                ? 'bg-dark-600 text-text-primary'
                                : 'text-text-muted hover:text-text-secondary'
                            }`}
                    >
                        {tab.label}
                    </button>
                ))}
            </div>

            {/* Deadline List */}
            <div className="space-y-2 max-h-64 overflow-y-auto">
                {displayDeadlines.length === 0 ? (
                    <div className="text-center py-4 text-text-muted text-sm">
                        No deadlines match this filter
                    </div>
                ) : (
                    displayDeadlines.map(deadline => (
                        <div
                            key={deadline.id}
                            className={`p-3 rounded-lg border transition-all ${deadline.isPast
                                    ? 'border-dark-600 opacity-50'
                                    : deadline.isUrgent
                                        ? 'border-accent-danger/50 bg-accent-danger/5'
                                        : deadline.isUpcoming
                                            ? 'border-accent-warning/50 bg-accent-warning/5'
                                            : 'border-dark-600'
                                }`}
                        >
                            <div className="flex items-start gap-3">
                                <span className="text-lg">{deadline.icon}</span>
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-2 flex-wrap">
                                        <p className={`font-medium text-sm ${deadline.isPast ? 'text-text-muted line-through' : 'text-text-primary'}`}>
                                            {deadline.title}
                                        </p>
                                        {deadline.isUrgent && !deadline.isPast && (
                                            <span className="px-2 py-0.5 bg-accent-danger/20 text-accent-danger text-xs rounded-full font-medium animate-pulse">
                                                {deadline.daysUntil} days!
                                            </span>
                                        )}
                                        {deadline.isUpcoming && !deadline.isUrgent && !deadline.isPast && (
                                            <span className="px-2 py-0.5 bg-accent-warning/20 text-accent-warning text-xs rounded-full font-medium">
                                                {deadline.daysUntil} days
                                            </span>
                                        )}
                                        {deadline.isPast && (
                                            <span className="px-2 py-0.5 bg-dark-600 text-text-muted text-xs rounded-full">
                                                Passed
                                            </span>
                                        )}
                                    </div>
                                    <p className="text-xs text-text-muted">
                                        {deadline.dateObj.toLocaleDateString('de-DE', {
                                            weekday: 'short',
                                            day: 'numeric',
                                            month: 'long',
                                            year: 'numeric'
                                        })}
                                    </p>
                                    {(deadline.isUpcoming || deadline.important) && !deadline.isPast && (
                                        <p className="text-xs text-text-secondary mt-1">{deadline.description}</p>
                                    )}
                                    {deadline.actionable && !deadline.isPast && (
                                        <p className="text-xs text-accent-primary mt-1 flex items-center gap-1">
                                            <span>→</span> {deadline.actionable}
                                        </p>
                                    )}
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>

            {/* Show more toggle */}
            {filteredDeadlines.length > 5 && (
                <button
                    onClick={() => setShowAll(!showAll)}
                    className="w-full text-center text-xs text-text-muted hover:text-accent-primary transition-colors py-2"
                >
                    {showAll ? 'Show less' : `Show all ${filteredDeadlines.length} deadlines`}
                </button>
            )}

            {/* Next important deadline highlight */}
            {nextImportant && filter !== 'important' && (
                <div className={`p-3 rounded-lg border ${nextImportant.isUrgent
                        ? 'bg-accent-danger/10 border-accent-danger/30'
                        : 'bg-accent-warning/10 border-accent-warning/30'
                    }`}>
                    <p className={`text-xs font-medium ${nextImportant.isUrgent ? 'text-accent-danger' : 'text-accent-warning'}`}>
                        {nextImportant.isUrgent ? '🚨' : '⚠️'} Next Important Deadline
                    </p>
                    <p className="text-sm text-text-primary mt-1">
                        <strong>{nextImportant.title}</strong>
                    </p>
                    <p className="text-xs text-text-muted">
                        {nextImportant.dateObj.toLocaleDateString('de-DE', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric'
                        })}
                        {' '}({nextImportant.daysUntil} days)
                    </p>
                </div>
            )}

            {/* Student tip */}
            {filter === 'all' && (
                <div className="p-2 bg-dark-700 rounded-lg text-xs text-text-muted">
                    💡 <strong>Students:</strong> You can file voluntarily up to 4 years later to claim refunds on mini-job taxes!
                </div>
            )}
        </div>
    );
}

export default TaxCalendar;
