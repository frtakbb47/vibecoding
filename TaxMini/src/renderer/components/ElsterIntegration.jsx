import React, { useState } from 'react';
import { useLanguage } from '../contexts/LanguageContext';
import { useValidation } from '../contexts/ValidationContext';

// ELSTER Integration Component (Mock/Placeholder)
// Note: Real ELSTER integration requires official certification
export function ElsterIntegration({ taxData, onSubmit, className = '' }) {
    const [step, setStep] = useState('info'); // info, login, review, submit, success
    const [isLoading, setIsLoading] = useState(false);
    const [elsterData, setElsterData] = useState({
        username: '',
        certificatePath: '',
        pin: ''
    });
    const { language } = useLanguage();
    const isGerman = language === 'de';
    const { isValid, errorCount } = useValidation();

    const handleSubmit = async () => {
        setIsLoading(true);
        // Simulate submission delay
        await new Promise(resolve => setTimeout(resolve, 2000));
        setIsLoading(false);
        setStep('success');
        onSubmit?.({ timestamp: new Date().toISOString() });
    };

    const renderStep = () => {
        switch (step) {
            case 'info':
                return <InfoStep isGerman={isGerman} onNext={() => setStep('login')} />;
            case 'login':
                return (
                    <LoginStep
                        isGerman={isGerman}
                        data={elsterData}
                        onChange={setElsterData}
                        onNext={() => setStep('review')}
                        onBack={() => setStep('info')}
                    />
                );
            case 'review':
                return (
                    <ReviewStep
                        isGerman={isGerman}
                        taxData={taxData}
                        isValid={isValid}
                        errorCount={errorCount}
                        onNext={handleSubmit}
                        onBack={() => setStep('login')}
                        isLoading={isLoading}
                    />
                );
            case 'success':
                return <SuccessStep isGerman={isGerman} onClose={() => setStep('info')} />;
            default:
                return null;
        }
    };

    return (
        <div className={`bg-dark-800 border border-dark-600 rounded-xl overflow-hidden ${className}`}>
            {/* Header */}
            <div className="p-4 border-b border-dark-600 bg-gradient-to-r from-blue-900/30 to-green-900/30">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
                        <span className="text-2xl">🦅</span>
                    </div>
                    <div>
                        <h3 className="font-semibold text-text-primary">ELSTER</h3>
                        <p className="text-xs text-text-muted">
                            {isGerman
                                ? 'Elektronische Steuererklärung'
                                : 'Electronic Tax Filing'}
                        </p>
                    </div>
                </div>
            </div>

            {/* Step Indicator */}
            <div className="px-4 py-2 border-b border-dark-600 bg-dark-900/50">
                <div className="flex items-center gap-2">
                    {['info', 'login', 'review', 'success'].map((s, idx) => (
                        <React.Fragment key={s}>
                            <div
                                className={`w-2 h-2 rounded-full ${step === s || ['info', 'login', 'review', 'success'].indexOf(step) > idx
                                    ? 'bg-accent-primary'
                                    : 'bg-dark-600'
                                    }`}
                            />
                            {idx < 3 && (
                                <div className={`flex-1 h-0.5 ${['info', 'login', 'review', 'success'].indexOf(step) > idx
                                    ? 'bg-accent-primary'
                                    : 'bg-dark-600'
                                    }`} />
                            )}
                        </React.Fragment>
                    ))}
                </div>
            </div>

            {/* Content */}
            <div className="p-4">
                {renderStep()}
            </div>
        </div>
    );
}

// Info Step
function InfoStep({ isGerman, onNext }) {
    return (
        <div className="space-y-4">
            <div className="text-center mb-6">
                <span className="text-4xl block mb-3">📋</span>
                <h4 className="text-lg font-semibold text-text-primary mb-2">
                    {isGerman ? 'Elektronisch einreichen' : 'Submit Electronically'}
                </h4>
                <p className="text-sm text-text-secondary">
                    {isGerman
                        ? 'Senden Sie Ihre Steuererklärung direkt an das Finanzamt'
                        : 'Send your tax return directly to the tax office'}
                </p>
            </div>

            <div className="space-y-3">
                <InfoItem
                    icon="🔐"
                    title={isGerman ? 'Sichere Übertragung' : 'Secure Transmission'}
                    description={isGerman
                        ? 'Ende-zu-Ende verschlüsselt'
                        : 'End-to-end encrypted'}
                />
                <InfoItem
                    icon="⚡"
                    title={isGerman ? 'Schnelle Bearbeitung' : 'Fast Processing'}
                    description={isGerman
                        ? 'Sofortige Bestätigung'
                        : 'Instant confirmation'}
                />
                <InfoItem
                    icon="📱"
                    title={isGerman ? 'ELSTER-Zertifikat erforderlich' : 'ELSTER Certificate Required'}
                    description={isGerman
                        ? 'Von elster.de herunterladen'
                        : 'Download from elster.de'}
                />
            </div>

            <div className="bg-accent-warning/10 border border-accent-warning/30 rounded-lg p-3 mt-4">
                <div className="flex items-start gap-2">
                    <span>⚠️</span>
                    <div className="text-sm">
                        <strong className="text-accent-warning">
                            {isGerman ? 'Hinweis:' : 'Note:'}
                        </strong>
                        <p className="text-text-secondary mt-1">
                            {isGerman
                                ? 'Dies ist eine Demo. Die echte ELSTER-Integration erfordert eine offizielle Zertifizierung.'
                                : 'This is a demo. Real ELSTER integration requires official certification.'}
                        </p>
                    </div>
                </div>
            </div>

            <button
                onClick={onNext}
                className="w-full py-3 bg-accent-primary hover:bg-accent-hover text-white font-medium rounded-lg transition-colors"
            >
                {isGerman ? 'Weiter zur Anmeldung' : 'Continue to Login'}
            </button>
        </div>
    );
}

// Login Step
function LoginStep({ isGerman, data, onChange, onNext, onBack }) {
    return (
        <div className="space-y-4">
            <h4 className="text-lg font-semibold text-text-primary mb-4">
                {isGerman ? 'ELSTER-Anmeldung' : 'ELSTER Login'}
            </h4>

            <div className="space-y-3">
                <div>
                    <label className="block text-sm text-text-secondary mb-1">
                        {isGerman ? 'ELSTER-Benutzername' : 'ELSTER Username'}
                    </label>
                    <input
                        type="text"
                        value={data.username}
                        onChange={(e) => onChange({ ...data, username: e.target.value })}
                        placeholder="mein.name@example.de"
                        className="w-full bg-dark-700 border border-dark-500 rounded-lg px-3 py-2 text-text-primary placeholder-text-muted focus:outline-none focus:border-accent-primary"
                    />
                </div>

                <div>
                    <label className="block text-sm text-text-secondary mb-1">
                        {isGerman ? 'Zertifikatsdatei (.pfx)' : 'Certificate File (.pfx)'}
                    </label>
                    <div className="flex gap-2">
                        <input
                            type="text"
                            value={data.certificatePath}
                            onChange={(e) => onChange({ ...data, certificatePath: e.target.value })}
                            placeholder={isGerman ? 'Pfad zur Datei...' : 'Path to file...'}
                            className="flex-1 bg-dark-700 border border-dark-500 rounded-lg px-3 py-2 text-text-primary placeholder-text-muted focus:outline-none focus:border-accent-primary"
                        />
                        <button
                            onClick={() => onChange({ ...data, certificatePath: 'elster_certificate.pfx' })}
                            className="px-3 py-2 bg-dark-600 hover:bg-dark-500 text-text-secondary rounded-lg transition-colors"
                        >
                            {isGerman ? 'Durchsuchen' : 'Browse'}
                        </button>
                    </div>
                </div>

                <div>
                    <label className="block text-sm text-text-secondary mb-1">
                        {isGerman ? 'Zertifikats-PIN' : 'Certificate PIN'}
                    </label>
                    <input
                        type="password"
                        value={data.pin}
                        onChange={(e) => onChange({ ...data, pin: e.target.value })}
                        placeholder="••••••"
                        className="w-full bg-dark-700 border border-dark-500 rounded-lg px-3 py-2 text-text-primary placeholder-text-muted focus:outline-none focus:border-accent-primary"
                    />
                </div>
            </div>

            <div className="flex gap-2 mt-6">
                <button
                    onClick={onBack}
                    className="flex-1 py-2 bg-dark-700 hover:bg-dark-600 text-text-secondary rounded-lg transition-colors"
                >
                    {isGerman ? 'Zurück' : 'Back'}
                </button>
                <button
                    onClick={onNext}
                    disabled={!data.username || !data.certificatePath || !data.pin}
                    className="flex-1 py-2 bg-accent-primary hover:bg-accent-hover disabled:bg-dark-600 disabled:cursor-not-allowed text-white font-medium rounded-lg transition-colors"
                >
                    {isGerman ? 'Anmelden' : 'Login'}
                </button>
            </div>
        </div>
    );
}

// Review Step
function ReviewStep({ isGerman, taxData, isValid, errorCount, onNext, onBack, isLoading }) {
    const deductions = taxData?.deductions || [];
    const totalDeductions = deductions.reduce((sum, d) => sum + (d.amount || 0), 0);

    return (
        <div className="space-y-4">
            <h4 className="text-lg font-semibold text-text-primary mb-4">
                {isGerman ? 'Daten überprüfen' : 'Review Your Data'}
            </h4>

            {/* Validation Status */}
            {!isValid && (
                <div className="bg-accent-danger/10 border border-accent-danger/30 rounded-lg p-3">
                    <div className="flex items-center gap-2 text-accent-danger">
                        <span>❌</span>
                        <span className="font-medium">
                            {isGerman
                                ? `${errorCount} Fehler müssen behoben werden`
                                : `${errorCount} errors need to be fixed`}
                        </span>
                    </div>
                </div>
            )}

            {/* Summary */}
            <div className="bg-dark-700 rounded-lg p-4 space-y-3">
                <div className="flex justify-between">
                    <span className="text-text-secondary">{isGerman ? 'Steuerjahr' : 'Tax Year'}</span>
                    <span className="text-text-primary font-medium">{taxData?.taxYear || 2026}</span>
                </div>
                <div className="flex justify-between">
                    <span className="text-text-secondary">{isGerman ? 'Bruttoeinkommen' : 'Gross Income'}</span>
                    <span className="text-text-primary font-medium">
                        €{(taxData?.employment?.grossIncome || 0).toLocaleString()}
                    </span>
                </div>
                <div className="flex justify-between">
                    <span className="text-text-secondary">{isGerman ? 'Anzahl Abzüge' : 'Number of Deductions'}</span>
                    <span className="text-text-primary font-medium">{deductions.length}</span>
                </div>
                <div className="flex justify-between border-t border-dark-600 pt-3">
                    <span className="text-text-secondary">{isGerman ? 'Gesamtabzüge' : 'Total Deductions'}</span>
                    <span className="text-accent-success font-bold">€{totalDeductions.toLocaleString()}</span>
                </div>
            </div>

            {/* Legal Notice */}
            <div className="bg-dark-900 rounded-lg p-3 text-xs text-text-muted">
                <p>
                    {isGerman
                        ? 'Mit dem Absenden bestätigen Sie, dass alle Angaben vollständig und wahrheitsgemäß sind.'
                        : 'By submitting, you confirm that all information is complete and truthful.'}
                </p>
            </div>

            <div className="flex gap-2 mt-6">
                <button
                    onClick={onBack}
                    disabled={isLoading}
                    className="flex-1 py-2 bg-dark-700 hover:bg-dark-600 disabled:opacity-50 text-text-secondary rounded-lg transition-colors"
                >
                    {isGerman ? 'Zurück' : 'Back'}
                </button>
                <button
                    onClick={onNext}
                    disabled={!isValid || isLoading}
                    className="flex-1 py-2 bg-green-600 hover:bg-green-700 disabled:bg-dark-600 disabled:cursor-not-allowed text-white font-medium rounded-lg transition-colors flex items-center justify-center gap-2"
                >
                    {isLoading ? (
                        <>
                            <svg className="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                            </svg>
                            {isGerman ? 'Sende...' : 'Sending...'}
                        </>
                    ) : (
                        <>
                            <span>🚀</span>
                            {isGerman ? 'An ELSTER senden' : 'Send to ELSTER'}
                        </>
                    )}
                </button>
            </div>
        </div>
    );
}

// Success Step
function SuccessStep({ isGerman, onClose }) {
    const referenceNumber = `ELST-${Date.now().toString(36).toUpperCase()}`;

    return (
        <div className="text-center space-y-4">
            <div className="text-6xl animate-bounce-in">🎉</div>

            <h4 className="text-xl font-bold text-accent-success">
                {isGerman ? 'Erfolgreich eingereicht!' : 'Successfully Submitted!'}
            </h4>

            <p className="text-text-secondary">
                {isGerman
                    ? 'Ihre Steuererklärung wurde an das Finanzamt übermittelt.'
                    : 'Your tax return has been transmitted to the tax office.'}
            </p>

            <div className="bg-dark-700 rounded-lg p-4">
                <div className="text-xs text-text-muted mb-1">
                    {isGerman ? 'Referenznummer' : 'Reference Number'}
                </div>
                <div className="text-lg font-mono text-accent-primary">
                    {referenceNumber}
                </div>
            </div>

            <p className="text-sm text-text-muted">
                {isGerman
                    ? 'Sie erhalten eine Bestätigung per Post innerhalb von 2-4 Wochen.'
                    : 'You will receive a confirmation by mail within 2-4 weeks.'}
            </p>

            <button
                onClick={onClose}
                className="w-full py-3 bg-accent-primary hover:bg-accent-hover text-white font-medium rounded-lg transition-colors"
            >
                {isGerman ? 'Fertig' : 'Done'}
            </button>
        </div>
    );
}

// Info Item Component
function InfoItem({ icon, title, description }) {
    return (
        <div className="flex items-start gap-3 p-3 bg-dark-700 rounded-lg">
            <span className="text-xl">{icon}</span>
            <div>
                <div className="font-medium text-text-primary">{title}</div>
                <div className="text-sm text-text-muted">{description}</div>
            </div>
        </div>
    );
}

// ELSTER Button for quick access
export function ElsterButton({ onClick, className = '' }) {
    const { language } = useLanguage();
    const isGerman = language === 'de';

    return (
        <button
            onClick={onClick}
            className={`flex items-center gap-2 px-3 py-1.5 bg-gradient-to-r from-blue-600 to-green-600 hover:from-blue-700 hover:to-green-700 text-white rounded-lg font-medium transition-all ${className}`}
        >
            <span>🦅</span>
            <span className="text-sm">ELSTER</span>
        </button>
    );
}
