import React, { useState } from 'react';

function DocumentList({ documents, extractedText, onRemove, onRetryOCR }) {
    const [confirmDelete, setConfirmDelete] = useState(null);

    if (documents.length === 0) {
        return (
            <div className="text-center py-8 text-text-muted animate-fade-in">
                <div className="w-16 h-16 rounded-2xl bg-dark-700 flex items-center justify-center mx-auto mb-3">
                    <svg className="w-8 h-8 text-dark-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </div>
                <p className="font-medium">No documents yet</p>
                <p className="text-sm mt-1">Upload your tax documents above</p>
            </div>
        );
    }

    const handleRemove = (index) => {
        if (confirmDelete === index) {
            onRemove(index);
            setConfirmDelete(null);
        } else {
            setConfirmDelete(index);
            // Auto-reset after 3 seconds
            setTimeout(() => setConfirmDelete(null), 3000);
        }
    };

    return (
        <div className="space-y-2">
            {documents.map((doc, index) => {
                const extracted = extractedText[doc.path];
                const hasText = extracted && extracted.text && extracted.text.length > 0;
                const needsOCR = extracted && extracted.needsOCR && !hasText;
                const hasError = extracted?.error;
                const isDeleting = confirmDelete === index;

                return (
                    <div
                        key={doc.path}
                        className={`flex items-center gap-3 p-3 rounded-lg group transition-all animate-slide-up ${isDeleting
                                ? 'bg-accent-danger/10 border border-accent-danger/30'
                                : 'bg-dark-800 hover:bg-dark-700'
                            }`}
                        style={{ animationDelay: `${index * 50}ms` }}
                    >
                        {/* File icon */}
                        <div className={`w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 ${hasText ? 'bg-accent-success/20' : needsOCR ? 'bg-accent-warning/20' : hasError ? 'bg-accent-danger/20' : 'bg-dark-600'
                            }`}>
                            {doc.processing ? (
                                <svg className="w-5 h-5 text-accent-primary animate-spin" fill="none" viewBox="0 0 24 24">
                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                                </svg>
                            ) : hasError ? (
                                <svg className="w-5 h-5 text-accent-danger" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            ) : (
                                <svg className={`w-5 h-5 ${hasText ? 'text-accent-success' : needsOCR ? 'text-accent-warning' : 'text-text-muted'
                                    }`} fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
                                </svg>
                            )}
                        </div>

                        {/* File info */}
                        <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium text-text-primary truncate">
                                {doc.name}
                            </p>
                            <p className="text-xs text-text-muted">
                                {doc.processing ? (
                                    <span className="flex items-center gap-1">
                                        <span className="inline-block w-2 h-2 bg-accent-primary rounded-full animate-pulse"></span>
                                        Processing...
                                    </span>
                                ) : hasText ? (
                                    <span className="text-accent-success flex items-center gap-1">
                                        <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                                        </svg>
                                        {Math.round(extracted.text.length / 1000)}k characters
                                    </span>
                                ) : needsOCR ? (
                                    <span className="text-accent-warning">
                                        Scanned PDF - needs OCR
                                    </span>
                                ) : extracted?.error ? (
                                    <span className="text-accent-danger truncate" title={extracted.error}>
                                        {extracted.error.slice(0, 30)}...
                                    </span>
                                ) : (
                                    'Pending...'
                                )}
                            </p>
                        </div>

                        {/* Actions */}
                        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            {needsOCR && onRetryOCR && (
                                <button
                                    onClick={() => onRetryOCR(doc.path)}
                                    className="p-2 rounded-lg hover:bg-dark-600 text-accent-warning transition-colors"
                                    title="Run OCR"
                                >
                                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                </button>
                            )}
                            <button
                                onClick={() => handleRemove(index)}
                                className={`p-2 rounded-lg transition-colors ${isDeleting
                                        ? 'bg-accent-danger text-white'
                                        : 'hover:bg-dark-600 text-text-muted hover:text-accent-danger'
                                    }`}
                                title={isDeleting ? 'Click again to confirm' : 'Remove'}
                            >
                                {isDeleting ? (
                                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                ) : (
                                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                    </svg>
                                )}
                            </button>
                        </div>
                    </div>
                );
            })}
        </div>
    );
}

export default DocumentList;
