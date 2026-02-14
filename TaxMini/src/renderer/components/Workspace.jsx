import React, { useState, useEffect, useCallback, useRef } from 'react';
import DropZone from './DropZone';
import DocumentList from './DocumentList';
import PromptPanel from './PromptPanel';
import ResultsPanel from './ResultsPanel';
import ProgressIndicator from './ProgressIndicator';
import TaxComparison from './TaxComparison';
import ExportModal from './ExportModal';
import KeyboardShortcuts from './KeyboardShortcuts';
import QuickTips from './QuickTips';
import DeductionOptimizer from './DeductionOptimizer';
import DocumentChecklist from './DocumentChecklist';
import TaxCalendar from './TaxCalendar';
import RefundBreakdown from './RefundBreakdown';
import SteuerklasseAdvisor from './SteuerklasseAdvisor';
import SmartExpenseTracker from './SmartExpenseTracker';
import TaxOverview from './TaxOverview';
import { buildTaxPrompt, parseGeminiResponse, detectDocumentType } from '../utils/promptBuilder';
import { useAppToast } from '../App';

// New feature imports
import { AuditRiskMeter } from './AuditRiskMeter';
import { YearComparison } from './YearComparison';
import { ValidationPanel } from '../contexts/ValidationContext';
import { PDFExport } from './PDFExport';
import { PrintPreview } from './PrintPreview';
import { ElsterIntegration } from './ElsterIntegration';
import { ProgressPanel } from '../contexts/ProgressContext';
import { AchievementsPanel } from '../contexts/AchievementsContext';
import { HistoryTimeline } from '../contexts/HistoryContext';

function Workspace({ taxData, setTaxData, onBackToWizard }) {
    const [isProcessing, setIsProcessing] = useState(false);
    const [generatedPrompt, setGeneratedPrompt] = useState('');
    const [geminiInput, setGeminiInput] = useState('');
    const [parseError, setParseError] = useState(null);
    const [showExport, setShowExport] = useState(false);
    const [showShortcuts, setShowShortcuts] = useState(false);
    const [lastSaved, setLastSaved] = useState(null);
    const [activeLeftTab, setActiveLeftTab] = useState('documents'); // documents, checklist, optimizer, calendar, expenses
    const [activeRightTab, setActiveRightTab] = useState('results'); // results, overview, advisor
    const addToast = useAppToast();
    const processingQueue = useRef([]);
    const isProcessingRef = useRef(false);

    // Keyboard shortcuts
    useEffect(() => {
        const handleKeyDown = (e) => {
            // Ctrl+? or Ctrl+/ for shortcuts
            if ((e.ctrlKey || e.metaKey) && (e.key === '?' || e.key === '/')) {
                e.preventDefault();
                setShowShortcuts(true);
            }
            // Escape to close modals
            if (e.key === 'Escape') {
                setShowExport(false);
                setShowShortcuts(false);
            }
            // Ctrl+E for export (when results available)
            if ((e.ctrlKey || e.metaKey) && e.key === 'e' && taxData.geminiResult) {
                e.preventDefault();
                setShowExport(true);
            }
            // Ctrl+S to manually save
            if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                e.preventDefault();
                saveSession();
            }
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [taxData.geminiResult]);

    // Generate prompt when extracted text changes
    useEffect(() => {
        const prompt = buildTaxPrompt(taxData);
        if (prompt) {
            setGeneratedPrompt(prompt);
        }
    }, [taxData]);

    // Auto-save with debounce
    const saveSession = useCallback(async () => {
        if (window.electronAPI && taxData.documents.length > 0) {
            await window.electronAPI.saveData('taxmini-session', taxData);
            setLastSaved(new Date());
        }
    }, [taxData]);

    useEffect(() => {
        const timer = setTimeout(saveSession, 2000); // Debounce 2 seconds
        return () => clearTimeout(timer);
    }, [taxData, saveSession]);

    // Check for duplicate files
    const isDuplicateFile = useCallback((filePath) => {
        const fileName = filePath.split(/[/\\]/).pop().toLowerCase();
        return taxData.documents.some(doc =>
            doc.path.split(/[/\\]/).pop().toLowerCase() === fileName
        );
    }, [taxData.documents]);

    // Process file queue sequentially to avoid race conditions
    const processFileQueue = useCallback(async () => {
        if (isProcessingRef.current || processingQueue.current.length === 0) {
            return;
        }

        isProcessingRef.current = true;
        setIsProcessing(true);

        while (processingQueue.current.length > 0) {
            const filePath = processingQueue.current.shift();

            try {
                // Try PDF parsing first
                const result = await window.electronAPI.parsePDF(filePath);

                // Detect document type
                const docType = detectDocumentType(
                    filePath.split(/[/\\]/).pop(),
                    result.text || ''
                );

                setTaxData((prev) => ({
                    ...prev,
                    documents: prev.documents.map((doc) =>
                        doc.path === filePath
                            ? { ...doc, processing: false, docType: docType.type, docLabel: docType.label }
                            : doc
                    ),
                    extractedText: {
                        ...prev.extractedText,
                        [filePath]: { ...result, docType },
                    },
                }));

                // If scanned PDF with no text, try OCR
                if (result.success && result.needsOCR) {
                    await handleOCR(filePath);
                }

                // Show success notification
                if (result.success && result.text?.length > 100) {
                    addToast?.(`Processed: ${filePath.split(/[/\\]/).pop()}`, 'success');
                }
            } catch (error) {
                setTaxData((prev) => ({
                    ...prev,
                    documents: prev.documents.map((doc) =>
                        doc.path === filePath ? { ...doc, processing: false, error: true } : doc
                    ),
                    extractedText: {
                        ...prev.extractedText,
                        [filePath]: { success: false, error: error.message },
                    },
                }));
                addToast?.(`Failed to process: ${filePath.split(/[/\\]/).pop()}`, 'error');
            }
        }

        isProcessingRef.current = false;
        setIsProcessing(false);
    }, [setTaxData, addToast]);

    // Handle file uploads with deduplication
    const handleFilesAdded = useCallback(async (filePaths) => {
        // Filter out duplicates
        const newFilePaths = filePaths.filter(path => {
            if (isDuplicateFile(path)) {
                addToast?.(`Skipped duplicate: ${path.split(/[/\\]/).pop()}`, 'warning');
                return false;
            }
            return true;
        });

        if (newFilePaths.length === 0) {
            return;
        }

        // Add files to document list immediately
        const newDocs = newFilePaths.map((path) => ({
            path,
            name: path.split(/[/\\]/).pop(),
            processing: true,
            addedAt: Date.now(),
        }));

        setTaxData((prev) => ({
            ...prev,
            documents: [...prev.documents, ...newDocs],
        }));

        // Add to processing queue
        processingQueue.current.push(...newFilePaths);
        processFileQueue();
    }, [setTaxData, isDuplicateFile, addToast, processFileQueue]);

    // Handle OCR for scanned documents
    const handleOCR = async (filePath) => {
        try {
            setTaxData((prev) => ({
                ...prev,
                documents: prev.documents.map((doc) =>
                    doc.path === filePath ? { ...doc, processing: true, ocrInProgress: true } : doc
                ),
            }));

            const result = await window.electronAPI.processOCR(filePath);

            // Detect document type from OCR text
            const docType = detectDocumentType(
                filePath.split(/[/\\]/).pop(),
                result.text || ''
            );

            setTaxData((prev) => ({
                ...prev,
                documents: prev.documents.map((doc) =>
                    doc.path === filePath
                        ? { ...doc, processing: false, ocrInProgress: false, docType: docType.type, docLabel: docType.label }
                        : doc
                ),
                extractedText: {
                    ...prev.extractedText,
                    [filePath]: {
                        ...prev.extractedText[filePath],
                        ...result,
                        docType,
                        needsOCR: false,
                    },
                },
            }));

            if (result.success) {
                addToast?.('OCR completed successfully', 'success');
            }
        } catch (error) {
            console.error('OCR error:', error);
            addToast?.('OCR processing failed', 'error');
        }
    };

    // Handle document removal
    const handleRemoveDocument = (index) => {
        setTaxData((prev) => {
            const doc = prev.documents[index];
            const newExtractedText = { ...prev.extractedText };
            delete newExtractedText[doc.path];

            return {
                ...prev,
                documents: prev.documents.filter((_, i) => i !== index),
                extractedText: newExtractedText,
            };
        });
        addToast?.('Document removed', 'info');
    };

    // Handle Gemini response with improved parsing
    const handleGeminiResponse = useCallback((response) => {
        setGeminiInput(response);
        setParseError(null);

        if (!response.trim()) {
            return;
        }

        const result = parseGeminiResponse(response);

        if (result.success) {
            setTaxData((prev) => ({
                ...prev,
                geminiResult: result.data,
            }));
            setParseError(null);

            // Show success with summary
            if (result.data.calculation?.estimatedRefund > 0) {
                addToast?.(`🎉 Estimated refund: €${result.data.calculation.estimatedRefund.toLocaleString('de-DE')}`, 'success');
            } else if (result.data.calculation?.estimatedRefund < 0) {
                addToast?.(`Tax due: €${Math.abs(result.data.calculation.estimatedRefund).toLocaleString('de-DE')}`, 'warning');
            } else {
                addToast?.('Tax analysis completed!', 'success');
            }

            // Show warnings if any
            if (result.data.warnings?.length > 0) {
                setTimeout(() => {
                    addToast?.(`${result.data.warnings.length} warning(s) - check results`, 'warning');
                }, 1500);
            }
        } else {
            setParseError(result.error);
            setTaxData((prev) => ({
                ...prev,
                geminiResult: null,
            }));
            addToast?.('Failed to parse response. Check the format.', 'error');
        }
    }, [setTaxData, addToast]);

    // Clear results and try again
    const handleClearResults = useCallback(() => {
        setGeminiInput('');
        setParseError(null);
        setTaxData((prev) => ({
            ...prev,
            geminiResult: null,
        }));
        addToast?.('Results cleared. Paste a new response.', 'info');
    }, [setTaxData, addToast]);

    // Check if we have any extracted text
    const hasExtractedText = Object.values(taxData.extractedText).some(
        (data) => data.text && data.text.length > 0
    );

    // Calculate total extracted characters
    const totalChars = Object.values(taxData.extractedText).reduce(
        (sum, data) => sum + (data.text?.length || 0), 0
    );

    return (
        <div className="h-full flex">
            {/* Left Column - Documents & Tools */}
            <div className="w-96 border-r border-dark-700 flex flex-col bg-dark-900">
                {/* Tab Navigation */}
                <div className="flex border-b border-dark-700">
                    {[
                        { id: 'documents', label: '📄 Docs', title: 'Documents' },
                        { id: 'checklist', label: '✅ Check', title: 'Checklist' },
                        { id: 'optimizer', label: '💡 Find', title: 'Find Deductions' },
                        { id: 'expenses', label: '💰 Track', title: 'Expense Tracker' },
                        { id: 'calendar', label: '📅', title: 'Tax Calendar' },
                    ].map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveLeftTab(tab.id)}
                            title={tab.title}
                            className={`flex-1 py-2.5 text-xs font-medium transition-colors relative ${activeLeftTab === tab.id
                                ? 'text-accent-primary'
                                : 'text-text-muted hover:text-text-secondary'
                                }`}
                        >
                            {tab.label}
                            {activeLeftTab === tab.id && (
                                <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent-primary" />
                            )}
                        </button>
                    ))}
                </div>

                {/* Tab Content */}
                {activeLeftTab === 'documents' && (
                    <>
                        <div className="p-4 border-b border-dark-700">
                            <div className="flex items-center justify-between mb-2">
                                <h2 className="font-semibold text-text-primary">Documents</h2>
                                <button
                                    onClick={onBackToWizard}
                                    className="text-xs text-text-muted hover:text-text-secondary"
                                >
                                    ← Edit Profile
                                </button>
                            </div>
                            <p className="text-xs text-text-muted">
                                Upload your tax documents
                            </p>
                        </div>

                        <div className="p-4">
                            <DropZone
                                onFilesAdded={handleFilesAdded}
                                isProcessing={isProcessing}
                            />
                        </div>

                        {/* Progress Indicator */}
                        {taxData.documents.length > 0 && (
                            <div className="px-4 pb-4">
                                <ProgressIndicator
                                    documents={taxData.documents}
                                    extractedText={taxData.extractedText}
                                />
                            </div>
                        )}

                        <div className="flex-1 overflow-y-auto p-4 pt-0">
                            <DocumentList
                                documents={taxData.documents}
                                extractedText={taxData.extractedText}
                                onRemove={handleRemoveDocument}
                                onRetryOCR={handleOCR}
                            />
                        </div>

                        {/* Quick stats */}
                        <div className="p-4 border-t border-dark-700 bg-dark-800 space-y-4">
                            <div className="grid grid-cols-2 gap-2 text-center">
                                <div>
                                    <p className="text-2xl font-bold text-accent-primary">
                                        {taxData.documents.length}
                                    </p>
                                    <p className="text-xs text-text-muted">Documents</p>
                                </div>
                                <div>
                                    <p className="text-2xl font-bold text-accent-success">
                                        {Object.values(taxData.extractedText).filter(d => d.text?.length > 0).length}
                                    </p>
                                    <p className="text-xs text-text-muted">Processed</p>
                                </div>
                            </div>

                            {/* Total characters extracted */}
                            {totalChars > 0 && (
                                <div className="text-center py-2 bg-dark-700 rounded-lg">
                                    <p className="text-sm text-text-secondary">
                                        {totalChars > 1000
                                            ? `${(totalChars / 1000).toFixed(1)}k`
                                            : totalChars} chars extracted
                                    </p>
                                </div>
                            )}

                            {/* Auto-save indicator */}
                            {lastSaved && (
                                <div className="flex items-center justify-center gap-1 text-xs text-text-muted">
                                    <svg className="w-3 h-3 text-accent-success" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                    Saved {lastSaved.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' })}
                                </div>
                            )}
                        </div>
                    </>
                )}

                {activeLeftTab === 'checklist' && (
                    <div className="flex-1 overflow-y-auto p-4">
                        <DocumentChecklist
                            profile={taxData.profile}
                            deductions={taxData.deductions}
                            documents={taxData.documents}
                            extractedText={taxData.extractedText}
                        />
                    </div>
                )}

                {activeLeftTab === 'optimizer' && (
                    <div className="flex-1 overflow-y-auto p-4">
                        <DeductionOptimizer
                            profile={taxData.profile}
                            existingDeductions={taxData.deductions}
                            taxYear={taxData.year}
                        />
                    </div>
                )}

                {activeLeftTab === 'expenses' && (
                    <div className="flex-1 overflow-y-auto p-4">
                        <SmartExpenseTracker
                            profile={taxData.profile}
                            existingDeductions={taxData.deductions}
                        />
                    </div>
                )}

                {activeLeftTab === 'calendar' && (
                    <div className="flex-1 overflow-y-auto p-4">
                        <TaxCalendar taxYear={taxData.year} />
                        <div className="mt-6">
                            <QuickTips />
                        </div>
                    </div>
                )}
            </div>

            {/* Center Column - Prompt & Response */}
            <div className="flex-1 flex flex-col overflow-hidden">
                <PromptPanel
                    prompt={generatedPrompt}
                    hasDocuments={hasExtractedText}
                    geminiInput={geminiInput}
                    onGeminiInputChange={handleGeminiResponse}
                    parseError={parseError}
                    onClearResults={handleClearResults}
                    hasResults={!!taxData.geminiResult}
                />
            </div>

            {/* Right Column - Results & Tools */}
            <div className="w-96 border-l border-dark-700 bg-dark-900 flex flex-col">
                {/* Right Tab Navigation */}
                <div className="flex border-b border-dark-700">
                    {[
                        { id: 'results', label: '📊', title: 'AI Results' },
                        { id: 'overview', label: '📈', title: 'Tax Overview' },
                        { id: 'advisor', label: '💍', title: 'Steuerklasse' },
                        { id: 'validate', label: '✓', title: 'Validation' },
                        { id: 'export', label: '📄', title: 'Export' },
                    ].map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveRightTab(tab.id)}
                            title={tab.title}
                            className={`flex-1 py-2.5 text-xs font-medium transition-colors relative ${activeRightTab === tab.id
                                ? 'text-accent-primary'
                                : 'text-text-muted hover:text-text-secondary'
                                }`}
                        >
                            {tab.label}
                            {activeRightTab === tab.id && (
                                <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-accent-primary" />
                            )}
                        </button>
                    ))}
                </div>

                <div className="flex-1 overflow-y-auto">
                    {/* Results Tab */}
                    {activeRightTab === 'results' && (
                        <>
                            <ResultsPanel
                                result={taxData.geminiResult}
                                taxYear={taxData.year}
                            />

                            {/* Refund Breakdown */}
                            {taxData.geminiResult?.calculation?.breakdown && (
                                <div className="p-4 border-t border-dark-700">
                                    <RefundBreakdown
                                        breakdown={taxData.geminiResult.calculation.breakdown}
                                        totalRefund={taxData.geminiResult.calculation.estimatedRefund}
                                    />
                                </div>
                            )}

                            {/* Tax Comparison */}
                            {taxData.geminiResult && (
                                <div className="p-4 border-t border-dark-700">
                                    <TaxComparison
                                        result={taxData.geminiResult}
                                        taxYear={taxData.year}
                                    />
                                </div>
                            )}

                            {/* Export Button */}
                            {taxData.geminiResult && (
                                <div className="p-4 border-t border-dark-700 space-y-3">
                                    <button
                                        onClick={() => setShowExport(true)}
                                        className="w-full btn btn-primary flex items-center justify-center gap-2"
                                    >
                                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                                        </svg>
                                        Export Report
                                    </button>
                                    <button
                                        onClick={handleClearResults}
                                        className="w-full btn btn-ghost text-sm flex items-center justify-center gap-2"
                                    >
                                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                                        </svg>
                                        Re-analyze
                                    </button>
                                    <p className="text-xs text-text-muted text-center">
                                        <kbd className="px-1 py-0.5 bg-dark-700 rounded text-xs">Ctrl+E</kbd> Export
                                        <span className="mx-2">•</span>
                                        <kbd className="px-1 py-0.5 bg-dark-700 rounded text-xs">Ctrl+S</kbd> Save
                                    </p>
                                </div>
                            )}
                        </>
                    )}

                    {/* Overview Tab */}
                    {activeRightTab === 'overview' && (
                        <div className="p-4">
                            <TaxOverview
                                profile={taxData.profile}
                                deductions={taxData.deductions}
                                geminiResult={taxData.geminiResult}
                                taxYear={taxData.year}
                            />
                        </div>
                    )}

                    {/* Steuerklasse Advisor Tab */}
                    {activeRightTab === 'advisor' && (
                        <div className="p-4">
                            <SteuerklasseAdvisor profile={taxData.profile} />
                        </div>
                    )}

                    {/* Validation Tab */}
                    {activeRightTab === 'validate' && (
                        <div className="p-4 space-y-6">
                            <ValidationPanel />
                            <AuditRiskMeter
                                deductions={taxData.deductions || []}
                                income={taxData.profile?.grossIncome || 0}
                            />
                            <ProgressPanel />
                            <AchievementsPanel />
                        </div>
                    )}

                    {/* Export Tab */}
                    {activeRightTab === 'export' && (
                        <div className="p-4 space-y-6">
                            <PDFExport
                                taxData={taxData}
                            />
                            <PrintPreview
                                taxData={taxData}
                            />
                            <ElsterIntegration
                                taxData={taxData}
                            />
                        </div>
                    )}
                </div>
            </div>

            {/* Modals */}
            <ExportModal
                isOpen={showExport}
                onClose={() => setShowExport(false)}
                result={taxData.geminiResult}
                taxYear={taxData.year}
                profile={taxData.profile}
            />
            <KeyboardShortcuts
                isOpen={showShortcuts}
                onClose={() => setShowShortcuts(false)}
            />
        </div>
    );
}

export default Workspace;
