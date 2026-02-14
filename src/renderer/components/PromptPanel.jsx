import React, { useState, useEffect } from 'react';
import { useAppToast } from '../App';

function PromptPanel({ prompt, hasDocuments, geminiInput, onGeminiInputChange, parseError }) {
    const [copied, setCopied] = useState(false);
    const [activeTab, setActiveTab] = useState('prompt');
    const addToast = useAppToast();

    const handleCopyPrompt = async () => {
        if (prompt) {
            await navigator.clipboard.writeText(prompt);
            setCopied(true);
            addToast?.('Prompt copied to clipboard!', 'success');
            setTimeout(() => setCopied(false), 2000);
        }
    };

    // Keyboard shortcut: Ctrl+V auto-switches to response tab
    useEffect(() => {
        const handleKeyDown = (e) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'v' && activeTab === 'prompt') {
                setActiveTab('response');
            }
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [activeTab]);

    return (
        <div className="h-full flex flex-col">
            {/* Tab Bar */}
            <div className="flex border-b border-dark-700 bg-dark-900">
                <button
                    onClick={() => setActiveTab('prompt')}
                    className={`px-6 py-3 text-sm font-medium transition-colors relative ${activeTab === 'prompt'
                        ? 'text-accent-primary'
                        : 'text-text-muted hover:text-text-secondary'
                        }`}
                >
                    1. Copy Prompt
                    {activeTab === 'prompt' && (
                        <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent-primary" />
                    )}
                </button>
                <button
                    onClick={() => setActiveTab('response')}
                    className={`px-6 py-3 text-sm font-medium transition-colors relative ${activeTab === 'response'
                        ? 'text-accent-primary'
                        : 'text-text-muted hover:text-text-secondary'
                        }`}
                >
                    2. Paste Response
                    {activeTab === 'response' && (
                        <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent-primary" />
                    )}
                </button>
            </div>

            {/* Content */}
            <div className="flex-1 overflow-hidden">
                {activeTab === 'prompt' ? (
                    <div className="h-full flex flex-col p-6">
                        {!hasDocuments ? (
                            <div className="flex-1 flex items-center justify-center">
                                <div className="text-center">
                                    <div className="w-16 h-16 rounded-2xl bg-dark-700 flex items-center justify-center mx-auto mb-4">
                                        <svg className="w-8 h-8 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                        </svg>
                                    </div>
                                    <h3 className="text-lg font-medium text-text-primary mb-2">
                                        No documents yet
                                    </h3>
                                    <p className="text-text-muted">
                                        Upload your tax documents to generate the AI prompt
                                    </p>
                                </div>
                            </div>
                        ) : (
                            <>
                                {/* Instructions */}
                                <div className="bg-accent-primary/10 border border-accent-primary/30 rounded-xl p-4 mb-4">
                                    <h3 className="font-medium text-accent-primary mb-2 flex items-center gap-2">
                                        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                        How to use
                                    </h3>
                                    <ol className="text-sm text-text-secondary space-y-1">
                                        <li>1. Click "Copy Prompt" below</li>
                                        <li>2. Open <a href="https://gemini.google.com" target="_blank" rel="noopener" className="text-accent-primary hover:underline">gemini.google.com</a> in your browser</li>
                                        <li>3. Paste the prompt and send it</li>
                                        <li>4. Copy Gemini's JSON response</li>
                                        <li>5. Switch to "Paste Response" tab and paste it</li>
                                    </ol>
                                </div>

                                {/* Copy button */}
                                <button
                                    onClick={handleCopyPrompt}
                                    disabled={!prompt}
                                    className={`w-full py-4 rounded-xl font-medium text-lg transition-all ${copied
                                        ? 'bg-accent-success text-white'
                                        : 'btn-primary shadow-glow hover:shadow-lg'
                                        }`}
                                >
                                    {copied ? (
                                        <>
                                            <svg className="w-5 h-5 inline mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                            </svg>
                                            Copied to Clipboard!
                                        </>
                                    ) : (
                                        <>
                                            <svg className="w-5 h-5 inline mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3" />
                                            </svg>
                                            Copy Prompt for Gemini
                                        </>
                                    )}
                                </button>

                                {/* Prompt preview */}
                                <div className="mt-4 flex-1 overflow-hidden flex flex-col">
                                    <div className="flex items-center justify-between mb-2">
                                        <span className="text-sm text-text-muted">Prompt Preview</span>
                                        <span className="text-xs text-text-muted">
                                            {prompt?.length.toLocaleString()} characters
                                        </span>
                                    </div>
                                    <pre className="flex-1 overflow-y-auto p-4 bg-dark-800 rounded-xl text-xs text-text-secondary font-mono whitespace-pre-wrap">
                                        {prompt}
                                    </pre>
                                </div>
                            </>
                        )}
                    </div>
                ) : (
                    <div className="h-full flex flex-col p-6">
                        <div className="mb-4">
                            <h3 className="font-medium text-text-primary mb-2">
                                Paste Gemini's Response
                            </h3>
                            <p className="text-sm text-text-muted">
                                Paste the JSON response from Gemini below
                            </p>
                        </div>

                        {parseError && (
                            <div className="bg-accent-danger/10 border border-accent-danger/30 rounded-xl p-4 mb-4">
                                <p className="text-sm text-accent-danger flex items-center gap-2">
                                    <svg className="w-4 h-4 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    {parseError}
                                </p>
                                <p className="text-xs text-text-muted mt-2">
                                    Make sure you copy the entire JSON response from Gemini
                                </p>
                            </div>
                        )}

                        <textarea
                            value={geminiInput}
                            onChange={(e) => onGeminiInputChange(e.target.value)}
                            placeholder={`Paste Gemini's JSON response here...\n\nExample:\n{\n  "taxYear": 2024,\n  "income": {\n    "grossSalary": 45000,\n    ...\n  }\n}`}
                            className="flex-1 w-full p-4 bg-dark-800 border border-dark-600 rounded-xl text-text-primary font-mono text-sm resize-none focus:outline-none focus:border-accent-primary focus:ring-1 focus:ring-accent-primary"
                        />

                        {geminiInput && !parseError && (
                            <div className="mt-4 flex items-center gap-2 text-accent-success">
                                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span className="text-sm font-medium">Valid JSON - Check results panel →</span>
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
}

export default PromptPanel;
