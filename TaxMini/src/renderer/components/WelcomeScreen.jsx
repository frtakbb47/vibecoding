import React, { useState, useEffect } from 'react';
import { BASIC_ALLOWANCES, STATISTICS } from '../utils/taxConstants2026';
import { useLanguage } from '../contexts/LanguageContext';

function WelcomeScreen({ onStart }) {
    const [hoveredFeature, setHoveredFeature] = useState(null);
    const { t, language } = useLanguage();

    // Keyboard support - Enter to start
    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === 'Enter') {
                onStart();
            }
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [onStart]);

    const features = [
        { icon: '🔒', label: t('welcome.features.private'), desc: t('welcome.features.privateDesc') },
        { icon: '⚡', label: t('welcome.features.fast'), desc: t('welcome.features.fastDesc') },
        { icon: '🎁', label: t('welcome.features.free'), desc: t('welcome.features.freeDesc') },
    ];

    return (
        <div className="h-full flex flex-col items-center justify-center p-8 animate-fade-in">
            <div className="max-w-lg w-full text-center">
                {/* Simple Logo */}
                <div className="mb-6 flex justify-center">
                    <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-accent-primary to-purple-500 flex items-center justify-center shadow-lg">
                        <span className="text-3xl">📋</span>
                    </div>
                </div>

                {/* Clean Title */}
                <h1 className="text-3xl font-bold text-text-primary mb-2">
                    TaxMini
                </h1>
                <p className="text-text-secondary mb-6">
                    {t('welcome.subtitle')}
                </p>

                {/* Year Badge */}
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-accent-success/10 border border-accent-success/30 text-accent-success text-sm mb-8">
                    <span className="w-2 h-2 rounded-full bg-accent-success animate-pulse" />
                    {t('welcome.taxYear')} 2026 • {t('welcome.basicAllowance')} €{BASIC_ALLOWANCES.grundfreibetrag.toLocaleString('de-DE')}
                </div>

                {/* Main CTA - Big and Clear */}
                <button
                    onClick={() => onStart()}
                    className="w-full btn btn-primary text-lg py-4 rounded-xl shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all mb-6 group"
                >
                    <span>{t('welcome.startButton')}</span>
                    <svg className="w-5 h-5 ml-2 inline transition-transform group-hover:translate-x-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                    </svg>
                </button>

                {/* Three Key Points - Minimal */}
                <div className="grid grid-cols-3 gap-3 mb-8">
                    {features.map((item, i) => (
                        <div
                            key={i}
                            className="p-3 rounded-lg bg-dark-800/50 border border-dark-700 hover:border-dark-600 transition-colors"
                            onMouseEnter={() => setHoveredFeature(i)}
                            onMouseLeave={() => setHoveredFeature(null)}
                        >
                            <span className="text-xl block mb-1">{item.icon}</span>
                            <p className="text-sm font-medium text-text-primary">{item.label}</p>
                            <p className={`text-xs text-text-muted transition-opacity ${hoveredFeature === i ? 'opacity-100' : 'opacity-70'}`}>
                                {item.desc}
                            </p>
                        </div>
                    ))}
                </div>

                {/* Who it's for */}
                <div className="flex items-center justify-center gap-4 text-sm text-text-muted mb-6">
                    <span className="flex items-center gap-1.5">
                        <span>🎓</span> {t('welcome.audience.students')}
                    </span>
                    <span className="text-dark-600">•</span>
                    <span className="flex items-center gap-1.5">
                        <span>💼</span> {t('welcome.audience.employees')}
                    </span>
                    <span className="text-dark-600">•</span>
                    <span className="flex items-center gap-1.5">
                        <span>✈️</span> {t('welcome.audience.expats')}
                    </span>
                </div>

                {/* Quick Stats with Source */}
                <div className="p-4 rounded-xl bg-dark-800/30 border border-dark-700">
                    <div className="flex items-center justify-center gap-6 text-sm mb-2">
                        <div>
                            <span className="text-accent-primary font-bold">€{STATISTICS.averageRefund}</span>
                            <span className="text-text-muted ml-1">{t('welcome.stats.avgRefund')}</span>
                        </div>
                        <div className="w-px h-4 bg-dark-600" />
                        <div>
                            <span className="text-accent-success font-bold">{STATISTICS.percentReceiveRefund}%</span>
                            <span className="text-text-muted ml-1">{t('welcome.stats.getMoneyBack')}</span>
                        </div>
                    </div>
                    {/* Transparency: Data source */}
                    <p className="text-[10px] text-text-muted/60 italic">
                        {t('welcome.stats.source')}
                    </p>
                </div>

                {/* Keyboard hint */}
                <p className="text-xs text-text-muted mt-6 flex items-center justify-center gap-1">
                    {language === 'de' ? 'Drücke' : 'Press'} <kbd className="px-1.5 py-0.5 rounded bg-dark-700 border border-dark-600 mx-1">Enter</kbd> {language === 'de' ? 'zum Starten' : 'to start'}
                </p>

                {/* Credits - Transparency */}
                <div className="mt-8 pt-6 border-t border-dark-800">
                    <p className="text-[11px] text-text-muted/50">
                        {t('credits.madeBy')} <span className="text-text-muted/70">Firat Akbaba</span>
                    </p>
                    <p className="text-[10px] text-text-muted/40 mt-1">
                        {t('credits.builtWith')} <span className="text-text-muted/60">GitHub Copilot</span> {t('credits.and')} <span className="text-text-muted/60">{t('credits.model')}</span>
                    </p>
                </div>
            </div>
        </div>
    );
}

export default WelcomeScreen;
