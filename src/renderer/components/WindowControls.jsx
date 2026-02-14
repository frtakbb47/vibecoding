import React from 'react';

function WindowControls() {
    const handleMinimize = () => {
        window.electronAPI?.minimizeWindow?.();
    };

    const handleMaximize = () => {
        window.electronAPI?.maximizeWindow?.();
    };

    const handleClose = () => {
        window.electronAPI?.closeWindow?.();
    };

    // Only show on Windows (macOS has native controls)
    if (window.electronAPI?.platform === 'darwin') {
        return null;
    }

    return (
        <div className="flex items-center gap-1 titlebar-no-drag">
            {/* Minimize */}
            <button
                onClick={handleMinimize}
                className="w-10 h-8 flex items-center justify-center hover:bg-dark-600 transition-colors"
                title="Minimize"
            >
                <svg className="w-4 h-4 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
                </svg>
            </button>

            {/* Maximize */}
            <button
                onClick={handleMaximize}
                className="w-10 h-8 flex items-center justify-center hover:bg-dark-600 transition-colors"
                title="Maximize"
            >
                <svg className="w-3.5 h-3.5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <rect x="4" y="4" width="16" height="16" rx="1" strokeWidth={2} />
                </svg>
            </button>

            {/* Close */}
            <button
                onClick={handleClose}
                className="w-10 h-8 flex items-center justify-center hover:bg-red-600 transition-colors group"
                title="Close"
            >
                <svg className="w-4 h-4 text-text-muted group-hover:text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>
        </div>
    );
}

export default WindowControls;
