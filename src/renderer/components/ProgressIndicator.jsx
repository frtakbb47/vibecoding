import React from 'react';

function ProgressIndicator({ documents, extractedText }) {
    if (!documents || documents.length === 0) return null;

    const total = documents.length;
    const processed = documents.filter(doc => !doc.processing).length;
    const hasErrors = Object.values(extractedText).some(r => r.success === false);
    const needsOCR = Object.values(extractedText).some(r => r.needsOCR);
    const isComplete = processed === total && !documents.some(d => d.processing);

    const percentage = Math.round((processed / total) * 100);

    return (
        <div className="bg-dark-800 rounded-xl p-4 border border-dark-700">
            {/* Header */}
            <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                    {isComplete ? (
                        <div className="w-6 h-6 rounded-full bg-accent-success/20 flex items-center justify-center">
                            <svg className="w-4 h-4 text-accent-success" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                            </svg>
                        </div>
                    ) : (
                        <div className="w-6 h-6 rounded-full bg-accent-primary/20 flex items-center justify-center animate-pulse">
                            <svg className="w-4 h-4 text-accent-primary animate-spin" fill="none" viewBox="0 0 24 24">
                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                            </svg>
                        </div>
                    )}
                    <span className="text-sm font-medium text-text-primary">
                        {isComplete ? 'Processing Complete' : 'Processing Documents...'}
                    </span>
                </div>
                <span className="text-sm text-text-muted">
                    {processed}/{total}
                </span>
            </div>

            {/* Progress bar */}
            <div className="h-2 bg-dark-700 rounded-full overflow-hidden">
                <div
                    className={`h-full transition-all duration-500 ${hasErrors
                            ? 'bg-gradient-to-r from-accent-warning to-accent-danger'
                            : isComplete
                                ? 'bg-gradient-to-r from-accent-success to-emerald-400'
                                : 'bg-gradient-to-r from-accent-primary to-indigo-400'
                        }`}
                    style={{ width: `${percentage}%` }}
                />
            </div>

            {/* Status messages */}
            <div className="mt-3 space-y-1">
                {needsOCR && (
                    <div className="flex items-center gap-2 text-xs text-accent-warning">
                        <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Some documents are scanned - running OCR...
                    </div>
                )}
                {hasErrors && (
                    <div className="flex items-center gap-2 text-xs text-accent-danger">
                        <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Some documents could not be processed
                    </div>
                )}
                {isComplete && !hasErrors && (
                    <div className="flex items-center gap-2 text-xs text-accent-success">
                        <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        All documents ready for analysis
                    </div>
                )}
            </div>

            {/* Document list */}
            <div className="mt-3 pt-3 border-t border-dark-700 space-y-2 max-h-32 overflow-y-auto">
                {documents.map((doc, index) => {
                    const result = extractedText[doc.path];
                    const status = doc.processing
                        ? 'processing'
                        : result?.success === false
                            ? 'error'
                            : result?.needsOCR
                                ? 'ocr'
                                : 'success';

                    return (
                        <div key={doc.path || index} className="flex items-center gap-2 text-xs">
                            {status === 'processing' && (
                                <div className="w-4 h-4 rounded-full border-2 border-accent-primary border-t-transparent animate-spin" />
                            )}
                            {status === 'success' && (
                                <svg className="w-4 h-4 text-accent-success" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                </svg>
                            )}
                            {status === 'error' && (
                                <svg className="w-4 h-4 text-accent-danger" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            )}
                            {status === 'ocr' && (
                                <svg className="w-4 h-4 text-accent-warning" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                            )}
                            <span className={`truncate flex-1 ${status === 'error' ? 'text-accent-danger' : 'text-text-muted'
                                }`}>
                                {doc.name}
                            </span>
                            {result?.text && (
                                <span className="text-text-muted">
                                    {Math.round(result.text.length / 1000)}k chars
                                </span>
                            )}
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

export default ProgressIndicator;
