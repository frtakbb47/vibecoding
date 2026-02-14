import React, { useState, useCallback } from 'react';
import { useLanguage } from '../contexts/LanguageContext';

// File Attachment Component for Deductions
export function FileAttachment({
    attachments = [],
    onAdd,
    onRemove,
    maxFiles = 5,
    maxSizeMB = 10,
    acceptedTypes = ['.pdf', '.jpg', '.jpeg', '.png', '.gif', '.webp'],
    className = ''
}) {
    const [isDragging, setIsDragging] = useState(false);
    const [error, setError] = useState(null);
    const { language } = useLanguage();
    const isGerman = language === 'de';

    const handleDragOver = useCallback((e) => {
        e.preventDefault();
        setIsDragging(true);
    }, []);

    const handleDragLeave = useCallback((e) => {
        e.preventDefault();
        setIsDragging(false);
    }, []);

    const validateFile = useCallback((file) => {
        // Check file count
        if (attachments.length >= maxFiles) {
            return isGerman
                ? `Maximal ${maxFiles} Dateien erlaubt`
                : `Maximum ${maxFiles} files allowed`;
        }

        // Check file size
        const sizeMB = file.size / (1024 * 1024);
        if (sizeMB > maxSizeMB) {
            return isGerman
                ? `Datei zu groß (max ${maxSizeMB}MB)`
                : `File too large (max ${maxSizeMB}MB)`;
        }

        // Check file type
        const extension = '.' + file.name.split('.').pop().toLowerCase();
        if (!acceptedTypes.includes(extension)) {
            return isGerman
                ? `Dateityp nicht unterstützt`
                : `File type not supported`;
        }

        return null;
    }, [attachments.length, maxFiles, maxSizeMB, acceptedTypes, isGerman]);

    const processFile = useCallback(async (file) => {
        const validationError = validateFile(file);
        if (validationError) {
            setError(validationError);
            setTimeout(() => setError(null), 3000);
            return;
        }

        // Read file as base64 for storage
        const reader = new FileReader();
        reader.onload = () => {
            const attachment = {
                id: Date.now() + Math.random().toString(36).substr(2, 9),
                name: file.name,
                type: file.type,
                size: file.size,
                data: reader.result,
                addedAt: new Date().toISOString()
            };
            onAdd?.(attachment);
        };
        reader.onerror = () => {
            setError(isGerman ? 'Fehler beim Lesen der Datei' : 'Error reading file');
            setTimeout(() => setError(null), 3000);
        };
        reader.readAsDataURL(file);
    }, [validateFile, onAdd, isGerman]);

    const handleDrop = useCallback((e) => {
        e.preventDefault();
        setIsDragging(false);

        const files = Array.from(e.dataTransfer.files);
        files.forEach(processFile);
    }, [processFile]);

    const handleFileSelect = useCallback((e) => {
        const files = Array.from(e.target.files);
        files.forEach(processFile);
        e.target.value = ''; // Reset input
    }, [processFile]);

    const handleRemove = useCallback((id) => {
        onRemove?.(id);
    }, [onRemove]);

    const formatFileSize = (bytes) => {
        if (bytes < 1024) return `${bytes} B`;
        if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
        return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    };

    const getFileIcon = (type) => {
        if (type.startsWith('image/')) return '🖼️';
        if (type === 'application/pdf') return '📄';
        return '📎';
    };

    return (
        <div className={className}>
            {/* Drop Zone */}
            <div
                onDragOver={handleDragOver}
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
                className={`relative border-2 border-dashed rounded-lg p-4 text-center transition-colors ${isDragging
                    ? 'border-accent-primary bg-accent-primary/10'
                    : 'border-dark-500 hover:border-dark-400'
                    }`}
            >
                <input
                    type="file"
                    onChange={handleFileSelect}
                    accept={acceptedTypes.join(',')}
                    multiple
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                />

                <div className="flex flex-col items-center gap-2">
                    <span className="text-2xl">📎</span>
                    <p className="text-sm text-text-secondary">
                        {isDragging
                            ? (isGerman ? 'Dateien hier ablegen' : 'Drop files here')
                            : (isGerman ? 'Belege hierher ziehen oder klicken' : 'Drag receipts here or click')
                        }
                    </p>
                    <p className="text-xs text-text-muted">
                        {isGerman
                            ? `PDF, Bilder · Max ${maxSizeMB}MB · ${attachments.length}/${maxFiles}`
                            : `PDF, Images · Max ${maxSizeMB}MB · ${attachments.length}/${maxFiles}`
                        }
                    </p>
                </div>
            </div>

            {/* Error Message */}
            {error && (
                <div className="mt-2 p-2 bg-accent-danger/10 text-accent-danger text-sm rounded-lg">
                    {error}
                </div>
            )}

            {/* Attachment List */}
            {attachments.length > 0 && (
                <div className="mt-3 space-y-2">
                    {attachments.map((attachment) => (
                        <div
                            key={attachment.id}
                            className="flex items-center gap-3 p-2 bg-dark-700 rounded-lg group"
                        >
                            {/* Preview */}
                            {attachment.type.startsWith('image/') ? (
                                <img
                                    src={attachment.data}
                                    alt={attachment.name}
                                    className="w-10 h-10 object-cover rounded"
                                />
                            ) : (
                                <div className="w-10 h-10 bg-dark-600 rounded flex items-center justify-center text-xl">
                                    {getFileIcon(attachment.type)}
                                </div>
                            )}

                            {/* Info */}
                            <div className="flex-1 min-w-0">
                                <div className="text-sm text-text-primary truncate">
                                    {attachment.name}
                                </div>
                                <div className="text-xs text-text-muted">
                                    {formatFileSize(attachment.size)}
                                </div>
                            </div>

                            {/* Actions */}
                            <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                <button
                                    onClick={() => window.open(attachment.data, '_blank')}
                                    className="p-1.5 text-text-muted hover:text-text-primary hover:bg-dark-600 rounded transition-colors"
                                    title={isGerman ? 'Öffnen' : 'Open'}
                                >
                                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                </button>
                                <button
                                    onClick={() => handleRemove(attachment.id)}
                                    className="p-1.5 text-text-muted hover:text-accent-danger hover:bg-dark-600 rounded transition-colors"
                                    title={isGerman ? 'Entfernen' : 'Remove'}
                                >
                                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                    </svg>
                                </button>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}

// Compact attachment indicator
export function AttachmentBadge({ count, onClick }) {
    if (!count) return null;

    return (
        <button
            onClick={onClick}
            className="inline-flex items-center gap-1 px-1.5 py-0.5 bg-accent-primary/20 text-accent-primary text-xs rounded-full hover:bg-accent-primary/30 transition-colors"
        >
            <span>📎</span>
            <span>{count}</span>
        </button>
    );
}

// Gallery view for viewing all attachments
export function AttachmentGallery({ attachments, onClose }) {
    const [selectedIndex, setSelectedIndex] = useState(0);
    const { language } = useLanguage();
    const isGerman = language === 'de';

    if (!attachments || attachments.length === 0) return null;

    const selected = attachments[selectedIndex];

    return (
        <div className="fixed inset-0 z-50 bg-black/90 flex flex-col">
            {/* Header */}
            <div className="flex items-center justify-between p-4 border-b border-dark-600">
                <div className="text-text-primary">
                    {selectedIndex + 1} / {attachments.length}
                </div>
                <div className="text-text-secondary truncate max-w-md">
                    {selected.name}
                </div>
                <button
                    onClick={onClose}
                    className="p-2 text-text-muted hover:text-text-primary transition-colors"
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>

            {/* Main view */}
            <div className="flex-1 flex items-center justify-center p-4 relative">
                {/* Previous button */}
                {attachments.length > 1 && (
                    <button
                        onClick={() => setSelectedIndex(i => (i - 1 + attachments.length) % attachments.length)}
                        className="absolute left-4 p-3 bg-dark-700 hover:bg-dark-600 rounded-full transition-colors"
                    >
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                    </button>
                )}

                {/* Image/PDF preview */}
                {selected.type.startsWith('image/') ? (
                    <img
                        src={selected.data}
                        alt={selected.name}
                        className="max-w-full max-h-full object-contain"
                    />
                ) : (
                    <div className="bg-dark-800 rounded-xl p-8 text-center">
                        <span className="text-6xl block mb-4">📄</span>
                        <div className="text-text-primary font-medium mb-2">{selected.name}</div>
                        <a
                            href={selected.data}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-accent-primary hover:underline"
                        >
                            {isGerman ? 'PDF öffnen' : 'Open PDF'}
                        </a>
                    </div>
                )}

                {/* Next button */}
                {attachments.length > 1 && (
                    <button
                        onClick={() => setSelectedIndex(i => (i + 1) % attachments.length)}
                        className="absolute right-4 p-3 bg-dark-700 hover:bg-dark-600 rounded-full transition-colors"
                    >
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                )}
            </div>

            {/* Thumbnails */}
            {attachments.length > 1 && (
                <div className="flex justify-center gap-2 p-4 border-t border-dark-600">
                    {attachments.map((att, idx) => (
                        <button
                            key={att.id}
                            onClick={() => setSelectedIndex(idx)}
                            className={`w-16 h-16 rounded-lg overflow-hidden border-2 transition-colors ${idx === selectedIndex
                                ? 'border-accent-primary'
                                : 'border-transparent hover:border-dark-400'
                                }`}
                        >
                            {att.type.startsWith('image/') ? (
                                <img src={att.data} alt="" className="w-full h-full object-cover" />
                            ) : (
                                <div className="w-full h-full bg-dark-700 flex items-center justify-center text-2xl">
                                    📄
                                </div>
                            )}
                        </button>
                    ))}
                </div>
            )}
        </div>
    );
}
