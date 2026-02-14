import React, { useState, useCallback } from 'react';

function DropZone({ onFilesAdded, isProcessing }) {
    const [isDragActive, setIsDragActive] = useState(false);

    const handleDragEnter = useCallback((e) => {
        e.preventDefault();
        e.stopPropagation();
        setIsDragActive(true);
    }, []);

    const handleDragLeave = useCallback((e) => {
        e.preventDefault();
        e.stopPropagation();
        setIsDragActive(false);
    }, []);

    const handleDragOver = useCallback((e) => {
        e.preventDefault();
        e.stopPropagation();
    }, []);

    const handleDrop = useCallback((e) => {
        e.preventDefault();
        e.stopPropagation();
        setIsDragActive(false);

        const files = Array.from(e.dataTransfer.files);
        const validFiles = files.filter(
            (file) => file.type === 'application/pdf' || file.type.startsWith('image/')
        );

        if (validFiles.length > 0) {
            // Get file paths from dropped files
            const filePaths = validFiles.map((file) => file.path);
            onFilesAdded(filePaths);
        }
    }, [onFilesAdded]);

    const handleBrowseClick = async () => {
        if (window.electronAPI) {
            const filePaths = await window.electronAPI.openFiles();
            if (filePaths && filePaths.length > 0) {
                onFilesAdded(filePaths);
            }
        }
    };

    return (
        <div
            onDragEnter={handleDragEnter}
            onDragLeave={handleDragLeave}
            onDragOver={handleDragOver}
            onDrop={handleDrop}
            className={`
        relative border-2 border-dashed rounded-2xl p-8 text-center
        transition-all duration-300 cursor-pointer
        ${isDragActive
                    ? 'border-accent-primary bg-accent-primary/10 drop-zone-active'
                    : 'border-dark-600 hover:border-dark-500 bg-dark-800/50'
                }
        ${isProcessing ? 'opacity-50 pointer-events-none' : ''}
      `}
            onClick={handleBrowseClick}
        >
            {/* Upload Icon */}
            <div className={`
        w-16 h-16 rounded-2xl mx-auto mb-4 flex items-center justify-center
        ${isDragActive ? 'bg-accent-primary/20' : 'bg-dark-700'}
      `}>
                {isProcessing ? (
                    <svg className="w-8 h-8 text-accent-primary animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                ) : (
                    <svg className={`w-8 h-8 ${isDragActive ? 'text-accent-primary' : 'text-text-muted'}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                    </svg>
                )}
            </div>

            {isProcessing ? (
                <div>
                    <p className="text-text-primary font-medium">Processing documents...</p>
                    <p className="text-sm text-text-muted mt-1">Extracting text from your files</p>
                </div>
            ) : (
                <div>
                    <p className="text-text-primary font-medium">
                        {isDragActive ? 'Drop files here' : 'Drag & drop documents'}
                    </p>
                    <p className="text-sm text-text-muted mt-1">
                        or <span className="text-accent-primary hover:underline">browse files</span>
                    </p>
                    <p className="text-xs text-text-muted mt-3">
                        Supports PDF documents and images (PNG, JPG)
                    </p>
                </div>
            )}

            {/* File type badges */}
            <div className="flex justify-center gap-2 mt-4">
                <span className="badge bg-dark-700 text-text-muted">
                    <svg className="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
                    </svg>
                    PDF
                </span>
                <span className="badge bg-dark-700 text-text-muted">
                    <svg className="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
                    </svg>
                    Images
                </span>
            </div>
        </div>
    );
}

export default DropZone;
