import React, { useState, useEffect, useCallback } from 'react';
import { useLanguage } from '../contexts/LanguageContext';

// Onboarding steps
const ONBOARDING_STEPS = [
    {
        id: 'welcome',
        target: null,
        title: 'Welcome to TaxMini!',
        titleDe: 'Willkommen bei TaxMini!',
        content: 'Your privacy-first German tax return assistant. Let\'s take a quick tour of the main features.',
        contentDe: 'Ihr datenschutzfreundlicher deutscher Steuerassistent. Lassen Sie uns die wichtigsten Funktionen erkunden.',
        icon: '👋',
        position: 'center'
    },
    {
        id: 'privacy',
        target: null,
        title: '100% Private',
        titleDe: '100% Privat',
        content: 'All your data stays on your computer. Nothing is sent to external servers.',
        contentDe: 'Alle Ihre Daten bleiben auf Ihrem Computer. Nichts wird an externe Server gesendet.',
        icon: '🔒',
        position: 'center'
    },
    {
        id: 'ai-assist',
        target: '[data-tour="ai-chat"]',
        title: 'AI Assistant',
        titleDe: 'KI-Assistent',
        content: 'Ask questions about deductions and get personalized suggestions. The AI helps you find tax savings.',
        contentDe: 'Stellen Sie Fragen zu Abzügen und erhalten Sie personalisierte Vorschläge. Die KI hilft Ihnen, Steuern zu sparen.',
        icon: '🤖',
        position: 'left'
    },
    {
        id: 'deductions',
        target: '[data-tour="deductions"]',
        title: 'Track Deductions',
        titleDe: 'Abzüge verfolgen',
        content: 'Add your expenses and the app calculates your potential tax savings automatically.',
        contentDe: 'Fügen Sie Ihre Ausgaben hinzu und die App berechnet automatisch Ihre möglichen Steuerersparnisse.',
        icon: '📝',
        position: 'right'
    },
    {
        id: 'progress',
        target: '[data-tour="progress"]',
        title: 'Track Your Progress',
        titleDe: 'Fortschritt verfolgen',
        content: 'See how complete your tax return is and what steps remain.',
        contentDe: 'Sehen Sie, wie vollständig Ihre Steuererklärung ist und welche Schritte noch fehlen.',
        icon: '📊',
        position: 'bottom'
    },
    {
        id: 'export',
        target: '[data-tour="export"]',
        title: 'Export Anytime',
        titleDe: 'Jederzeit exportieren',
        content: 'Export your data as PDF for filing or save for later.',
        contentDe: 'Exportieren Sie Ihre Daten als PDF zum Einreichen oder speichern Sie sie für später.',
        icon: '📤',
        position: 'left'
    },
    {
        id: 'keyboard',
        target: null,
        title: 'Keyboard Shortcuts',
        titleDe: 'Tastaturkürzel',
        content: 'Press Ctrl+K to search, Ctrl+Z to undo, and ? to see all shortcuts.',
        contentDe: 'Drücken Sie Strg+K zum Suchen, Strg+Z zum Rückgängigmachen und ? für alle Kürzel.',
        icon: '⌨️',
        position: 'center'
    },
    {
        id: 'complete',
        target: null,
        title: 'You\'re Ready!',
        titleDe: 'Sie sind bereit!',
        content: 'Start by entering your personal information, then add your deductions. Good luck with your tax return!',
        contentDe: 'Beginnen Sie mit Ihren persönlichen Daten und fügen Sie dann Ihre Abzüge hinzu. Viel Erfolg bei Ihrer Steuererklärung!',
        icon: '🚀',
        position: 'center'
    }
];

export function OnboardingTutorial({ onComplete }) {
    const [currentStep, setCurrentStep] = useState(0);
    // Check localStorage first - don't show if already completed
    const [isVisible, setIsVisible] = useState(() => {
        if (typeof window !== 'undefined') {
            return localStorage.getItem('taxmini-onboarding-complete') !== 'true';
        }
        return false;
    });
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const step = ONBOARDING_STEPS[currentStep];
    const isLastStep = currentStep === ONBOARDING_STEPS.length - 1;
    const isFirstStep = currentStep === 0;

    const handleNext = useCallback(() => {
        if (isLastStep) {
            setIsVisible(false);
            localStorage.setItem('taxmini-onboarding-complete', 'true');
            onComplete?.();
        } else {
            setCurrentStep(s => s + 1);
        }
    }, [isLastStep, onComplete]);

    const handlePrev = useCallback(() => {
        if (!isFirstStep) {
            setCurrentStep(s => s - 1);
        }
    }, [isFirstStep]);

    const handleSkip = useCallback(() => {
        setIsVisible(false);
        localStorage.setItem('taxmini-onboarding-complete', 'true');
        onComplete?.();
    }, [onComplete]);

    // Keyboard navigation
    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === 'Escape') {
                handleSkip();
            } else if (e.key === 'ArrowRight' || e.key === 'Enter') {
                handleNext();
            } else if (e.key === 'ArrowLeft') {
                handlePrev();
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [handleNext, handlePrev, handleSkip]);

    // Highlight target element
    useEffect(() => {
        if (step.target) {
            const element = document.querySelector(step.target);
            if (element) {
                element.classList.add('tour-highlight');
                element.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
            return () => {
                if (element) {
                    element.classList.remove('tour-highlight');
                }
            };
        }
    }, [step.target]);

    if (!isVisible) return null;

    return (
        <>
            {/* Overlay */}
            <div className="fixed inset-0 z-[100] bg-black/70" onClick={handleSkip} />

            {/* Modal */}
            <div className={`fixed z-[101] ${getPositionClasses(step.position)}`}>
                <div className="bg-dark-800 border border-dark-500 rounded-2xl shadow-2xl max-w-md w-full mx-4 overflow-hidden animate-scale-in">
                    {/* Progress bar */}
                    <div className="h-1 bg-dark-700">
                        <div
                            className="h-full bg-accent-primary transition-all duration-300"
                            style={{ width: `${((currentStep + 1) / ONBOARDING_STEPS.length) * 100}%` }}
                        />
                    </div>

                    {/* Content */}
                    <div className="p-6">
                        <div className="text-center mb-4">
                            <span className="text-5xl">{step.icon}</span>
                        </div>

                        <h2 className="text-xl font-bold text-text-primary text-center mb-2">
                            {isGerman ? step.titleDe : step.title}
                        </h2>

                        <p className="text-text-secondary text-center mb-6">
                            {isGerman ? step.contentDe : step.content}
                        </p>

                        {/* Step indicators */}
                        <div className="flex justify-center gap-1.5 mb-6">
                            {ONBOARDING_STEPS.map((_, idx) => (
                                <button
                                    key={idx}
                                    onClick={() => setCurrentStep(idx)}
                                    className={`w-2 h-2 rounded-full transition-colors ${idx === currentStep
                                        ? 'bg-accent-primary'
                                        : idx < currentStep
                                            ? 'bg-accent-primary/50'
                                            : 'bg-dark-600'
                                        }`}
                                />
                            ))}
                        </div>

                        {/* Navigation */}
                        <div className="flex items-center justify-between">
                            <button
                                onClick={handleSkip}
                                className="text-sm text-text-muted hover:text-text-secondary transition-colors"
                            >
                                {isGerman ? 'Überspringen' : 'Skip'}
                            </button>

                            <div className="flex items-center gap-2">
                                {!isFirstStep && (
                                    <button
                                        onClick={handlePrev}
                                        className="px-4 py-2 text-text-secondary hover:text-text-primary transition-colors"
                                    >
                                        ←
                                    </button>
                                )}
                                <button
                                    onClick={handleNext}
                                    className="px-6 py-2 bg-accent-primary hover:bg-accent-hover text-white rounded-lg font-medium transition-colors"
                                >
                                    {isLastStep
                                        ? (isGerman ? 'Loslegen!' : 'Get Started!')
                                        : (isGerman ? 'Weiter' : 'Next')}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
}

function getPositionClasses(position) {
    switch (position) {
        case 'top':
            return 'top-20 left-1/2 -translate-x-1/2';
        case 'bottom':
            return 'bottom-20 left-1/2 -translate-x-1/2';
        case 'left':
            return 'top-1/2 left-20 -translate-y-1/2';
        case 'right':
            return 'top-1/2 right-20 -translate-y-1/2';
        case 'center':
        default:
            return 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2';
    }
}

// Hook to check if onboarding should show
export function useOnboarding() {
    const [shouldShow, setShouldShow] = useState(false);

    useEffect(() => {
        const completed = localStorage.getItem('taxmini-onboarding-complete');
        setShouldShow(!completed);
    }, []);

    const resetOnboarding = () => {
        localStorage.removeItem('taxmini-onboarding-complete');
        setShouldShow(true);
    };

    const completeOnboarding = () => {
        localStorage.setItem('taxmini-onboarding-complete', 'true');
        setShouldShow(false);
    };

    return {
        shouldShow,
        resetOnboarding,
        completeOnboarding
    };
}

// Tooltip component for individual feature highlights
export function FeatureTooltip({ target, title, content, position = 'bottom', show = true }) {
    const [targetElement, setTargetElement] = useState(null);
    const { language } = useLanguage();

    useEffect(() => {
        if (target) {
            const el = document.querySelector(target);
            setTargetElement(el);
        }
    }, [target]);

    if (!show || !targetElement) return null;

    const rect = targetElement.getBoundingClientRect();

    const style = {
        position: 'fixed',
        zIndex: 1000,
        ...getTooltipPosition(rect, position)
    };

    return (
        <div style={style} className="bg-dark-800 border border-dark-500 rounded-lg p-3 shadow-xl max-w-xs">
            <div className="font-medium text-text-primary mb-1">{title}</div>
            <div className="text-sm text-text-secondary">{content}</div>
        </div>
    );
}

function getTooltipPosition(rect, position) {
    switch (position) {
        case 'top':
            return { bottom: window.innerHeight - rect.top + 10, left: rect.left + rect.width / 2, transform: 'translateX(-50%)' };
        case 'bottom':
            return { top: rect.bottom + 10, left: rect.left + rect.width / 2, transform: 'translateX(-50%)' };
        case 'left':
            return { top: rect.top + rect.height / 2, right: window.innerWidth - rect.left + 10, transform: 'translateY(-50%)' };
        case 'right':
            return { top: rect.top + rect.height / 2, left: rect.right + 10, transform: 'translateY(-50%)' };
        default:
            return { top: rect.bottom + 10, left: rect.left };
    }
}

// CSS to add to index.css for tour highlight
// .tour-highlight {
//     position: relative;
//     z-index: 102;
//     box-shadow: 0 0 0 4px rgba(129, 140, 248, 0.5), 0 0 20px rgba(129, 140, 248, 0.3);
//     border-radius: 8px;
// }
