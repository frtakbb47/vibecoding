import React, { useState, useEffect } from 'react';
import WindowControls from './WindowControls';
import { LanguageSwitch, useLanguage } from '../contexts/LanguageContext';
import { ThemeToggle } from '../contexts/ThemeContext';
import { useOnlineStatus } from './OfflineIndicator';
import { SearchButton } from '../contexts/SearchContext';
import { UndoRedoButtons } from '../contexts/HistoryContext';
import { AchievementsBadge } from '../contexts/AchievementsContext';
import { ProgressBar } from '../contexts/ProgressContext';

function Header({ stage, onReset, taxYear, lastSaved }) {
    const [currentTime, setCurrentTime] = useState(new Date());
    const { t, language } = useLanguage();
    const isOnline = useOnlineStatus();

    // Update time every minute
    useEffect(() => {
        const timer = setInterval(() => setCurrentTime(new Date()), 60000);
        return () => clearInterval(timer);
    }, []);

    // Format last saved time
    const formatLastSaved = () => {
        if (!lastSaved) return null;
        const diff = Math.floor((Date.now() - lastSaved.getTime()) / 1000);
        if (diff < 60) return t('header.saved');
        const mins = Math.floor(diff / 60);
        return `${mins}m ago`;
    };

    return (
        <header className="bg-dark-900 border-b border-dark-700 titlebar-drag">
            {/* Progress bar at top */}
            {stage === 'workspace' && (
                <div className="px-6 pt-3">
                    <ProgressBar />
                </div>
            )}
            <div className={`px-6 ${stage === 'workspace' ? 'py-2' : 'py-3'} flex items-center justify-between`}>
                <div className="flex items-center gap-4 titlebar-no-drag">
                    {/* Logo */}
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-accent-primary to-purple-500 flex items-center justify-center shadow-lg">
                            <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                        </div>
                        <div>
                            <div className="flex items-center gap-2">
                                <h1 className="text-xl font-bold text-text-primary">TaxMini</h1>
                                <span className="text-xs px-1.5 py-0.5 rounded bg-accent-primary/20 text-accent-primary font-medium">v1.0</span>
                            </div>
                            <p className="text-xs text-text-muted">{t('header.tagline')}</p>
                        </div>
                    </div>

                    {/* Tax Year Badge */}
                    {stage !== 'welcome' && (
                        <div className="ml-4 px-3 py-1.5 rounded-lg bg-dark-700 border border-dark-600 flex items-center gap-2">
                            <span className="w-2 h-2 rounded-full bg-accent-success animate-pulse" />
                            <span className="text-text-secondary text-sm font-medium">{t('header.taxYear')} {taxYear}</span>
                        </div>
                    )}

                    {/* Auto-save indicator */}
                    {stage !== 'welcome' && lastSaved && (
                        <div className="flex items-center gap-1.5 text-xs text-text-muted">
                            <svg className="w-3.5 h-3.5 text-accent-success" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                            </svg>
                            <span>{formatLastSaved()}</span>
                        </div>
                    )}

                    {/* Offline indicator */}
                    {!isOnline && (
                        <div className="flex items-center gap-1.5 px-2 py-1 rounded bg-accent-warning/20 text-accent-warning text-xs">
                            <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 2.829a4.978 4.978 0 01-1.414-2.83m-1.414 5.658a9 9 0 01-2.167-9.238m7.824 2.167a1 1 0 111.414 1.414m-1.414-1.414L3 3m8.293 8.293l1.414 1.414" />
                            </svg>
                            <span>{t('header.offline')}</span>
                        </div>
                    )}
                </div>

                <div className="flex items-center gap-3 titlebar-no-drag">
                    {/* Undo/Redo (only in workspace) */}
                    {stage === 'workspace' && <UndoRedoButtons />}

                    {/* Search button */}
                    {stage !== 'welcome' && <SearchButton />}

                    {/* Current time */}
                    <span className="text-xs text-text-muted hidden md:block">
                        {currentTime.toLocaleTimeString(language === 'de' ? 'de-DE' : 'en-US', { hour: '2-digit', minute: '2-digit' })}
                    </span>

                    {/* Achievements badge */}
                    {stage !== 'welcome' && <AchievementsBadge />}

                    {/* Stage indicator */}
                    {stage !== 'welcome' && (
                        <div className="flex items-center gap-2 text-sm text-text-muted bg-dark-800 rounded-lg px-3 py-1.5">
                            <StageStep active={stage === 'wizard'} completed={stage === 'workspace'} number={1} label={t('header.setup')} />
                            <svg className="w-3 h-3 text-dark-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                            </svg>
                            <StageStep active={stage === 'workspace'} completed={false} number={2} label={t('header.documents')} />
                            <svg className="w-3 h-3 text-dark-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                            </svg>
                            <StageStep active={false} completed={false} number={3} label={t('header.analysis')} />
                        </div>
                    )}

                    {/* Language Switch */}
                    <LanguageSwitch />

                    {/* Theme Toggle */}
                    <ThemeToggle />

                    {/* Reset button */}
                    {stage !== 'welcome' && (
                        <button
                            onClick={onReset}
                            className="btn btn-ghost text-sm flex items-center gap-1.5 hover:text-accent-danger"
                            title={t('header.newSession')}
                        >
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                            <span className="hidden sm:inline">{t('header.newSession')}</span>
                        </button>
                    )}

                    {/* Window Controls */}
                    <WindowControls />
                </div>
            </div>
        </header>
    );
}

function StageStep({ active, completed, number, label }) {
    return (
        <div className={`flex items-center gap-1.5 ${active ? 'text-accent-primary' : completed ? 'text-accent-success' : 'text-text-muted'}`}>
            {completed ? (
                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
            ) : (
                <span className={`w-4 h-4 rounded-full text-xs flex items-center justify-center ${active ? 'bg-accent-primary text-white' : 'bg-dark-600 text-text-muted'}`}>
                    {number}
                </span>
            )}
            <span className="hidden lg:inline">{label}</span>
        </div>
    );
}

export default Header;
