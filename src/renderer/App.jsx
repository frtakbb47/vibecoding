import React, { useState, useEffect, createContext, useContext, useCallback } from 'react';
import Header from './components/Header';
import Wizard from './components/Wizard';
import Workspace from './components/Workspace';
import WelcomeScreen from './components/WelcomeScreen';
import { ToastContainer, useToast } from './components/Toast';
import { LanguageProvider } from './contexts/LanguageContext';
import { ThemeProvider } from './contexts/ThemeContext';
import ErrorBoundary from './components/ErrorBoundary';
import { OfflineIndicator } from './components/OfflineIndicator';

// New feature imports
import { ProgressProvider } from './contexts/ProgressContext';
import { HistoryProvider } from './contexts/HistoryContext';
import { SearchProvider, SearchModal } from './contexts/SearchContext';
import { ValidationProvider } from './contexts/ValidationContext';
import { AchievementsProvider, AchievementToast } from './contexts/AchievementsContext';
import { AccessibilityProvider, SkipLink } from './contexts/AccessibilityContext';
import { OnboardingTutorial } from './components/OnboardingTutorial';

// Toast context for global access
const ToastContext = createContext(null);
export const useAppToast = () => useContext(ToastContext);

// App stages
const STAGES = {
    WELCOME: 'welcome',
    WIZARD: 'wizard',
    WORKSPACE: 'workspace',
};

function App() {
    const [stage, setStage] = useState(STAGES.WELCOME);
    const [lastSaved, setLastSaved] = useState(null);
    const [taxData, setTaxData] = useState({
        year: new Date().getFullYear() - 1,
        profile: {},
        documents: [],
        extractedText: {},
        geminiResult: null,
    });

    // Load saved session on mount
    useEffect(() => {
        const loadSession = async () => {
            if (window.electronAPI) {
                const result = await window.electronAPI.loadData('taxmini-session');
                if (result.success && result.data) {
                    setTaxData(result.data);
                    // If we have data, go to workspace
                    if (result.data.documents?.length > 0) {
                        setStage(STAGES.WORKSPACE);
                    }
                }
            }
        };
        loadSession();
    }, []);

    // Save session with debounce
    const saveSession = useCallback(async () => {
        if (window.electronAPI && taxData.documents.length > 0) {
            await window.electronAPI.saveData('taxmini-session', taxData);
            setLastSaved(new Date());
        }
    }, [taxData]);

    useEffect(() => {
        const timer = setTimeout(saveSession, 2000);
        return () => clearTimeout(timer);
    }, [taxData, saveSession]);

    const handleStartNew = () => {
        setTaxData({
            year: new Date().getFullYear() - 1,
            profile: {},
            documents: [],
            extractedText: {},
            geminiResult: null,
        });
        setStage(STAGES.WIZARD);
    };

    const handleWizardComplete = (wizardData) => {
        setTaxData((prev) => ({
            ...prev,
            ...wizardData,
        }));
        setStage(STAGES.WORKSPACE);
    };

    const handleBackToWizard = () => {
        setStage(STAGES.WIZARD);
    };

    const handleReset = () => {
        setTaxData({
            year: new Date().getFullYear() - 1,
            profile: {},
            documents: [],
            extractedText: {},
            geminiResult: null,
        });
        setLastSaved(null);
        setStage(STAGES.WELCOME);
    };

    // Toast system
    const { toasts, addToast, removeToast } = useToast();

    return (
        <ErrorBoundary onReset={handleReset}>
            <ThemeProvider>
                <LanguageProvider>
                    <AccessibilityProvider>
                        <HistoryProvider initialState={taxData}>
                            <ProgressProvider taxData={taxData}>
                                <ValidationProvider taxData={taxData}>
                                    <AchievementsProvider>
                                        <SearchProvider taxData={taxData}>
                                            <ToastContext.Provider value={addToast}>
                                                <SkipLink />
                                                <div className="min-h-screen bg-dark-950 flex flex-col">
                                                    <Header
                                                        stage={stage}
                                                        onReset={handleReset}
                                                        taxYear={taxData.year}
                                                        lastSaved={lastSaved}
                                                    />

                                                    <main id="main-content" className="flex-1 overflow-hidden">
                                                        {stage === STAGES.WELCOME && (
                                                            <WelcomeScreen onStart={handleStartNew} />
                                                        )}

                                                        {stage === STAGES.WIZARD && (
                                                            <Wizard
                                                                initialData={taxData}
                                                                onComplete={handleWizardComplete}
                                                                onBack={() => setStage(STAGES.WELCOME)}
                                                            />
                                                        )}

                                                        {stage === STAGES.WORKSPACE && (
                                                            <Workspace
                                                                taxData={taxData}
                                                                setTaxData={setTaxData}
                                                                onBackToWizard={handleBackToWizard}
                                                            />
                                                        )}
                                                    </main>

                                                    {/* Toast notifications */}
                                                    <ToastContainer toasts={toasts} removeToast={removeToast} />

                                                    {/* Achievement toast */}
                                                    <AchievementToast />

                                                    {/* Global search modal */}
                                                    <SearchModal />

                                                    {/* Onboarding tutorial */}
                                                    <OnboardingTutorial />

                                                    {/* Offline indicator */}
                                                    <OfflineIndicator />
                                                </div>
                                            </ToastContext.Provider>
                                        </SearchProvider>
                                    </AchievementsProvider>
                                </ValidationProvider>
                            </ProgressProvider>
                        </HistoryProvider>
                    </AccessibilityProvider>
                </LanguageProvider>
            </ThemeProvider>
        </ErrorBoundary>
    );
}

export default App;
