import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { useLanguage } from './LanguageContext';

const AchievementsContext = createContext();

// Achievement definitions
const ACHIEVEMENTS = {
    // Getting Started
    firstLogin: {
        id: 'firstLogin',
        icon: '🎉',
        title: 'Welcome!',
        titleDe: 'Willkommen!',
        description: 'Logged in for the first time',
        descriptionDe: 'Zum ersten Mal eingeloggt',
        points: 10
    },
    profileComplete: {
        id: 'profileComplete',
        icon: '👤',
        title: 'Identity Confirmed',
        titleDe: 'Identität bestätigt',
        description: 'Completed your personal information',
        descriptionDe: 'Persönliche Daten ausgefüllt',
        points: 20
    },
    firstDeduction: {
        id: 'firstDeduction',
        icon: '📝',
        title: 'Deduction Hunter',
        titleDe: 'Abzugsjäger',
        description: 'Added your first deduction',
        descriptionDe: 'Ersten Abzug hinzugefügt',
        points: 15
    },

    // Deduction Milestones
    fiveDeductions: {
        id: 'fiveDeductions',
        icon: '🎯',
        title: 'Getting Serious',
        titleDe: 'Wird ernst',
        description: 'Added 5 deductions',
        descriptionDe: '5 Abzüge hinzugefügt',
        points: 25
    },
    tenDeductions: {
        id: 'tenDeductions',
        icon: '🏆',
        title: 'Tax Expert',
        titleDe: 'Steuerexperte',
        description: 'Added 10 deductions',
        descriptionDe: '10 Abzüge hinzugefügt',
        points: 50
    },
    twentyDeductions: {
        id: 'twentyDeductions',
        icon: '👑',
        title: 'Deduction Master',
        titleDe: 'Abzugsmeister',
        description: 'Added 20 deductions',
        descriptionDe: '20 Abzüge hinzugefügt',
        points: 100
    },

    // Amount Milestones
    saved500: {
        id: 'saved500',
        icon: '💰',
        title: 'Smart Saver',
        titleDe: 'Kluger Sparer',
        description: 'Total deductions reached €500',
        descriptionDe: 'Abzüge erreichten €500',
        points: 30
    },
    saved1000: {
        id: 'saved1000',
        icon: '💎',
        title: 'Money Minded',
        titleDe: 'Geldorientiert',
        description: 'Total deductions reached €1,000',
        descriptionDe: 'Abzüge erreichten €1.000',
        points: 50
    },
    saved5000: {
        id: 'saved5000',
        icon: '🚀',
        title: 'Tax Hero',
        titleDe: 'Steuerheld',
        description: 'Total deductions reached €5,000',
        descriptionDe: 'Abzüge erreichten €5.000',
        points: 100
    },

    // Category Diversity
    threeCategories: {
        id: 'threeCategories',
        icon: '🌈',
        title: 'Diversified',
        titleDe: 'Diversifiziert',
        description: 'Used 3 different categories',
        descriptionDe: '3 verschiedene Kategorien genutzt',
        points: 25
    },
    allCategories: {
        id: 'allCategories',
        icon: '🎨',
        title: 'Full Spectrum',
        titleDe: 'Volles Spektrum',
        description: 'Used all deduction categories',
        descriptionDe: 'Alle Abzugskategorien genutzt',
        points: 75
    },

    // Documentation
    firstReceipt: {
        id: 'firstReceipt',
        icon: '📎',
        title: 'Organized',
        titleDe: 'Organisiert',
        description: 'Attached your first receipt',
        descriptionDe: 'Ersten Beleg angehängt',
        points: 15
    },
    fullyDocumented: {
        id: 'fullyDocumented',
        icon: '📚',
        title: 'Paper Trail Pro',
        titleDe: 'Belegmeister',
        description: 'All deductions have receipts',
        descriptionDe: 'Alle Abzüge haben Belege',
        points: 50
    },

    // Completion
    returnComplete: {
        id: 'returnComplete',
        icon: '✅',
        title: 'Mission Complete',
        titleDe: 'Mission erfüllt',
        description: 'Completed your tax return',
        descriptionDe: 'Steuererklärung abgeschlossen',
        points: 100
    },
    exported: {
        id: 'exported',
        icon: '📤',
        title: 'Ready to File',
        titleDe: 'Bereit zur Einreichung',
        description: 'Exported your tax return',
        descriptionDe: 'Steuererklärung exportiert',
        points: 50
    },

    // Streaks
    twoDayStreak: {
        id: 'twoDayStreak',
        icon: '🔥',
        title: 'On Fire',
        titleDe: 'Am brennen',
        description: '2-day activity streak',
        descriptionDe: '2-Tage-Aktivitätsserie',
        points: 20
    },
    weekStreak: {
        id: 'weekStreak',
        icon: '⚡',
        title: 'Dedicated',
        titleDe: 'Engagiert',
        description: '7-day activity streak',
        descriptionDe: '7-Tage-Aktivitätsserie',
        points: 50
    },

    // Special
    earlyBird: {
        id: 'earlyBird',
        icon: '🐦',
        title: 'Early Bird',
        titleDe: 'Frühaufsteher',
        description: 'Started before March',
        descriptionDe: 'Vor März begonnen',
        points: 30
    },
    nightOwl: {
        id: 'nightOwl',
        icon: '🦉',
        title: 'Night Owl',
        titleDe: 'Nachteule',
        description: 'Working after midnight',
        descriptionDe: 'Nach Mitternacht gearbeitet',
        points: 15
    }
};

// Rank definitions based on total points
const RANKS = [
    { min: 0, name: 'Tax Novice', nameDe: 'Steuer-Anfänger', icon: '🌱' },
    { min: 50, name: 'Tax Learner', nameDe: 'Steuer-Lernender', icon: '📖' },
    { min: 100, name: 'Tax Amateur', nameDe: 'Steuer-Amateur', icon: '🎓' },
    { min: 200, name: 'Tax Enthusiast', nameDe: 'Steuer-Enthusiast', icon: '💡' },
    { min: 350, name: 'Tax Pro', nameDe: 'Steuer-Profi', icon: '⭐' },
    { min: 500, name: 'Tax Expert', nameDe: 'Steuer-Experte', icon: '🏅' },
    { min: 750, name: 'Tax Master', nameDe: 'Steuer-Meister', icon: '🏆' },
    { min: 1000, name: 'Tax Legend', nameDe: 'Steuer-Legende', icon: '👑' }
];

export function AchievementsProvider({ children, taxData }) {
    const [unlockedIds, setUnlockedIds] = useState(() => {
        const saved = localStorage.getItem('taxmini-achievements');
        return saved ? JSON.parse(saved) : [];
    });
    const [newUnlock, setNewUnlock] = useState(null);
    const [lastActivity, setLastActivity] = useState(() => {
        return localStorage.getItem('taxmini-last-activity') || null;
    });
    const [streak, setStreak] = useState(() => {
        return parseInt(localStorage.getItem('taxmini-streak') || '0');
    });

    // Check for achievements based on current data
    const checkAchievements = useCallback((data) => {
        if (!data) return;

        const toUnlock = [];
        const deductions = data.deductions || [];
        const totalAmount = deductions.reduce((sum, d) => sum + (d.amount || 0), 0);
        const categories = new Set(deductions.map(d => d.category).filter(Boolean));
        const hasReceipts = deductions.some(d => d.hasReceipt || d.attachments?.length > 0);
        const allHaveReceipts = deductions.length > 0 && deductions.every(d => d.hasReceipt || d.attachments?.length > 0);

        // First login
        if (!unlockedIds.includes('firstLogin')) {
            toUnlock.push('firstLogin');
        }

        // Profile complete
        const personal = data.personalInfo || {};
        if (personal.firstName && personal.lastName && personal.taxId && !unlockedIds.includes('profileComplete')) {
            toUnlock.push('profileComplete');
        }

        // Deduction counts
        if (deductions.length >= 1 && !unlockedIds.includes('firstDeduction')) {
            toUnlock.push('firstDeduction');
        }
        if (deductions.length >= 5 && !unlockedIds.includes('fiveDeductions')) {
            toUnlock.push('fiveDeductions');
        }
        if (deductions.length >= 10 && !unlockedIds.includes('tenDeductions')) {
            toUnlock.push('tenDeductions');
        }
        if (deductions.length >= 20 && !unlockedIds.includes('twentyDeductions')) {
            toUnlock.push('twentyDeductions');
        }

        // Amount milestones
        if (totalAmount >= 500 && !unlockedIds.includes('saved500')) {
            toUnlock.push('saved500');
        }
        if (totalAmount >= 1000 && !unlockedIds.includes('saved1000')) {
            toUnlock.push('saved1000');
        }
        if (totalAmount >= 5000 && !unlockedIds.includes('saved5000')) {
            toUnlock.push('saved5000');
        }

        // Category diversity
        if (categories.size >= 3 && !unlockedIds.includes('threeCategories')) {
            toUnlock.push('threeCategories');
        }
        if (categories.size >= 6 && !unlockedIds.includes('allCategories')) {
            toUnlock.push('allCategories');
        }

        // Receipts
        if (hasReceipts && !unlockedIds.includes('firstReceipt')) {
            toUnlock.push('firstReceipt');
        }
        if (allHaveReceipts && deductions.length >= 3 && !unlockedIds.includes('fullyDocumented')) {
            toUnlock.push('fullyDocumented');
        }

        // Time-based
        const hour = new Date().getHours();
        if (hour >= 0 && hour < 5 && !unlockedIds.includes('nightOwl')) {
            toUnlock.push('nightOwl');
        }

        const month = new Date().getMonth();
        if (month < 2 && !unlockedIds.includes('earlyBird')) {
            toUnlock.push('earlyBird');
        }

        // Return complete
        if (data.reviewed && !unlockedIds.includes('returnComplete')) {
            toUnlock.push('returnComplete');
        }

        // Unlock new achievements
        if (toUnlock.length > 0) {
            const newIds = [...unlockedIds, ...toUnlock];
            setUnlockedIds(newIds);
            localStorage.setItem('taxmini-achievements', JSON.stringify(newIds));

            // Show notification for first new unlock
            setNewUnlock(ACHIEVEMENTS[toUnlock[0]]);
            setTimeout(() => setNewUnlock(null), 4000);
        }
    }, [unlockedIds]);

    // Check achievements when data changes
    useEffect(() => {
        checkAchievements(taxData);
    }, [taxData, checkAchievements]);

    // Update streak
    useEffect(() => {
        const today = new Date().toDateString();
        if (lastActivity !== today) {
            const yesterday = new Date();
            yesterday.setDate(yesterday.getDate() - 1);

            if (lastActivity === yesterday.toDateString()) {
                const newStreak = streak + 1;
                setStreak(newStreak);
                localStorage.setItem('taxmini-streak', String(newStreak));

                // Check streak achievements
                if (newStreak >= 2 && !unlockedIds.includes('twoDayStreak')) {
                    const newIds = [...unlockedIds, 'twoDayStreak'];
                    setUnlockedIds(newIds);
                    localStorage.setItem('taxmini-achievements', JSON.stringify(newIds));
                    setNewUnlock(ACHIEVEMENTS.twoDayStreak);
                    setTimeout(() => setNewUnlock(null), 4000);
                }
                if (newStreak >= 7 && !unlockedIds.includes('weekStreak')) {
                    const newIds = [...unlockedIds, 'weekStreak'];
                    setUnlockedIds(newIds);
                    localStorage.setItem('taxmini-achievements', JSON.stringify(newIds));
                    setNewUnlock(ACHIEVEMENTS.weekStreak);
                    setTimeout(() => setNewUnlock(null), 4000);
                }
            } else {
                setStreak(1);
                localStorage.setItem('taxmini-streak', '1');
            }

            setLastActivity(today);
            localStorage.setItem('taxmini-last-activity', today);
        }
    }, [lastActivity, streak, unlockedIds]);

    // Calculate stats
    const totalPoints = unlockedIds.reduce((sum, id) => sum + (ACHIEVEMENTS[id]?.points || 0), 0);
    const rank = [...RANKS].reverse().find(r => totalPoints >= r.min) || RANKS[0];
    const nextRank = RANKS.find(r => r.min > totalPoints);
    const progressToNextRank = nextRank
        ? ((totalPoints - rank.min) / (nextRank.min - rank.min)) * 100
        : 100;

    const value = {
        achievements: ACHIEVEMENTS,
        unlocked: unlockedIds.map(id => ACHIEVEMENTS[id]).filter(Boolean),
        locked: Object.values(ACHIEVEMENTS).filter(a => !unlockedIds.includes(a.id)),
        totalPoints,
        rank,
        nextRank,
        progressToNextRank,
        streak,
        newUnlock,
        unlockAchievement: (id) => {
            if (!unlockedIds.includes(id) && ACHIEVEMENTS[id]) {
                const newIds = [...unlockedIds, id];
                setUnlockedIds(newIds);
                localStorage.setItem('taxmini-achievements', JSON.stringify(newIds));
                setNewUnlock(ACHIEVEMENTS[id]);
                setTimeout(() => setNewUnlock(null), 4000);
            }
        },
        dismissNewUnlock: () => setNewUnlock(null)
    };

    return (
        <AchievementsContext.Provider value={value}>
            {children}
        </AchievementsContext.Provider>
    );
}

export function useAchievements() {
    const context = useContext(AchievementsContext);
    if (!context) {
        return {
            achievements: ACHIEVEMENTS,
            unlocked: [],
            locked: Object.values(ACHIEVEMENTS),
            totalPoints: 0,
            rank: RANKS[0],
            nextRank: RANKS[1],
            progressToNextRank: 0,
            streak: 0,
            newUnlock: null,
            unlockAchievement: () => { },
            dismissNewUnlock: () => { }
        };
    }
    return context;
}

// Achievement Toast Notification
export function AchievementToast() {
    const { newUnlock, dismissNewUnlock } = useAchievements();
    const { language } = useLanguage();
    const isGerman = language === 'de';

    if (!newUnlock) return null;

    return (
        <div className="fixed bottom-20 right-4 z-50 animate-bounce-in">
            <div className="bg-gradient-to-r from-accent-primary to-purple-600 text-white rounded-xl p-4 shadow-2xl max-w-xs">
                <div className="flex items-start gap-3">
                    <span className="text-3xl">{newUnlock.icon}</span>
                    <div className="flex-1">
                        <div className="text-xs text-white/70 uppercase tracking-wider mb-1">
                            {isGerman ? 'Erfolg freigeschaltet!' : 'Achievement Unlocked!'}
                        </div>
                        <div className="font-bold">
                            {isGerman ? newUnlock.titleDe : newUnlock.title}
                        </div>
                        <div className="text-sm text-white/80">
                            {isGerman ? newUnlock.descriptionDe : newUnlock.description}
                        </div>
                        <div className="text-xs text-white/60 mt-1">
                            +{newUnlock.points} {isGerman ? 'Punkte' : 'points'}
                        </div>
                    </div>
                    <button onClick={dismissNewUnlock} className="text-white/60 hover:text-white">
                        ✕
                    </button>
                </div>
            </div>
        </div>
    );
}

// Achievements Panel Component
export function AchievementsPanel({ className = '' }) {
    const {
        unlocked,
        locked,
        totalPoints,
        rank,
        nextRank,
        progressToNextRank,
        streak
    } = useAchievements();
    const { language } = useLanguage();
    const isGerman = language === 'de';

    return (
        <div className={`bg-dark-800 border border-dark-600 rounded-xl overflow-hidden ${className}`}>
            {/* Header with Rank */}
            <div className="p-4 border-b border-dark-600 bg-gradient-to-r from-accent-primary/20 to-purple-600/20">
                <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                        <span className="text-2xl">{rank.icon}</span>
                        <div>
                            <div className="font-bold text-text-primary">
                                {isGerman ? rank.nameDe : rank.name}
                            </div>
                            <div className="text-xs text-text-muted">
                                {totalPoints} {isGerman ? 'Punkte' : 'points'}
                            </div>
                        </div>
                    </div>
                    {streak > 0 && (
                        <div className="flex items-center gap-1 px-2 py-1 bg-accent-warning/20 text-accent-warning rounded-full text-sm">
                            <span>🔥</span>
                            <span>{streak}</span>
                        </div>
                    )}
                </div>

                {nextRank && (
                    <div>
                        <div className="flex justify-between text-xs text-text-muted mb-1">
                            <span>{isGerman ? 'Nächster Rang' : 'Next rank'}</span>
                            <span>{isGerman ? nextRank.nameDe : nextRank.name}</span>
                        </div>
                        <div className="h-2 bg-dark-700 rounded-full overflow-hidden">
                            <div
                                className="h-full bg-gradient-to-r from-accent-primary to-purple-600 transition-all duration-500"
                                style={{ width: `${progressToNextRank}%` }}
                            />
                        </div>
                    </div>
                )}
            </div>

            {/* Unlocked Achievements */}
            <div className="p-4 border-b border-dark-600">
                <h4 className="text-sm font-medium text-text-muted mb-3">
                    {isGerman ? 'Freigeschaltet' : 'Unlocked'} ({unlocked.length})
                </h4>
                <div className="grid grid-cols-4 gap-2">
                    {unlocked.slice(0, 8).map(achievement => (
                        <div
                            key={achievement.id}
                            className="aspect-square flex items-center justify-center bg-dark-700 rounded-lg text-2xl hover:bg-dark-600 cursor-pointer transition-colors"
                            title={`${isGerman ? achievement.titleDe : achievement.title} (+${achievement.points})`}
                        >
                            {achievement.icon}
                        </div>
                    ))}
                </div>
                {unlocked.length > 8 && (
                    <div className="text-xs text-text-muted text-center mt-2">
                        +{unlocked.length - 8} {isGerman ? 'mehr' : 'more'}
                    </div>
                )}
            </div>

            {/* Locked Achievements (teaser) */}
            <div className="p-4">
                <h4 className="text-sm font-medium text-text-muted mb-3">
                    {isGerman ? 'Noch zu erreichen' : 'Locked'} ({locked.length})
                </h4>
                <div className="grid grid-cols-4 gap-2">
                    {locked.slice(0, 8).map(achievement => (
                        <div
                            key={achievement.id}
                            className="aspect-square flex items-center justify-center bg-dark-700 rounded-lg text-2xl opacity-30 grayscale cursor-pointer hover:opacity-50 transition-opacity"
                            title={`??? - ${isGerman ? achievement.descriptionDe : achievement.description}`}
                        >
                            {achievement.icon}
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

// Mini badge for header
export function AchievementsBadge({ onClick }) {
    const { totalPoints, rank, streak, newUnlock } = useAchievements();

    return (
        <button
            onClick={onClick}
            className={`flex items-center gap-1.5 px-2 py-1 rounded-full text-xs font-medium transition-colors ${newUnlock
                ? 'bg-accent-primary/30 text-accent-primary animate-pulse'
                : 'bg-dark-700 text-text-secondary hover:text-text-primary hover:bg-dark-600'
                }`}
        >
            <span>{rank.icon}</span>
            <span>{totalPoints}</span>
            {streak > 1 && (
                <span className="text-accent-warning">🔥{streak}</span>
            )}
        </button>
    );
}
