import React, { createContext, useContext, useReducer, useCallback, useEffect } from 'react';

const HistoryContext = createContext();

const MAX_HISTORY_SIZE = 50;

function historyReducer(state, action) {
    switch (action.type) {
        case 'PUSH': {
            // Don't push if data is the same
            const lastEntry = state.past[state.past.length - 1];
            if (lastEntry && JSON.stringify(lastEntry) === JSON.stringify(action.payload)) {
                return state;
            }

            const newPast = [...state.past, action.payload].slice(-MAX_HISTORY_SIZE);
            return {
                past: newPast,
                present: action.payload,
                future: [] // Clear future on new action
            };
        }

        case 'UNDO': {
            if (state.past.length === 0) return state;

            const newPast = state.past.slice(0, -1);
            const previous = state.past[state.past.length - 1];

            return {
                past: newPast,
                present: previous,
                future: [state.present, ...state.future]
            };
        }

        case 'REDO': {
            if (state.future.length === 0) return state;

            const next = state.future[0];
            const newFuture = state.future.slice(1);

            return {
                past: [...state.past, state.present],
                present: next,
                future: newFuture
            };
        }

        case 'CLEAR': {
            return {
                past: [],
                present: action.payload || state.present,
                future: []
            };
        }

        case 'SET_PRESENT': {
            return {
                ...state,
                present: action.payload
            };
        }

        default:
            return state;
    }
}

export function HistoryProvider({ children, initialData, onDataChange }) {
    const [state, dispatch] = useReducer(historyReducer, {
        past: [],
        present: initialData,
        future: []
    });

    const canUndo = state.past.length > 0;
    const canRedo = state.future.length > 0;

    const pushState = useCallback((data) => {
        dispatch({ type: 'PUSH', payload: data });
    }, []);

    const undo = useCallback(() => {
        if (canUndo) {
            dispatch({ type: 'UNDO' });
        }
    }, [canUndo]);

    const redo = useCallback(() => {
        if (canRedo) {
            dispatch({ type: 'REDO' });
        }
    }, [canRedo]);

    const clearHistory = useCallback((newData) => {
        dispatch({ type: 'CLEAR', payload: newData });
    }, []);

    // Notify parent when present changes due to undo/redo
    useEffect(() => {
        if (onDataChange && state.present !== initialData) {
            onDataChange(state.present);
        }
    }, [state.present]);

    // Keyboard shortcuts for undo/redo
    useEffect(() => {
        const handleKeyDown = (e) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
                if (e.shiftKey) {
                    e.preventDefault();
                    redo();
                } else {
                    e.preventDefault();
                    undo();
                }
            }
            if ((e.ctrlKey || e.metaKey) && e.key === 'y') {
                e.preventDefault();
                redo();
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [undo, redo]);

    const value = {
        present: state.present,
        canUndo,
        canRedo,
        undoCount: state.past.length,
        redoCount: state.future.length,
        pushState,
        undo,
        redo,
        clearHistory
    };

    return (
        <HistoryContext.Provider value={value}>
            {children}
        </HistoryContext.Provider>
    );
}

export function useHistory() {
    const context = useContext(HistoryContext);
    if (!context) {
        return {
            present: null,
            canUndo: false,
            canRedo: false,
            undoCount: 0,
            redoCount: 0,
            pushState: () => { },
            undo: () => { },
            redo: () => { },
            clearHistory: () => { }
        };
    }
    return context;
}

// Undo/Redo Buttons Component
export function UndoRedoButtons({ className = '' }) {
    const { canUndo, canRedo, undo, redo, undoCount, redoCount } = useHistory();

    return (
        <div className={`flex items-center gap-1 ${className}`}>
            <button
                onClick={undo}
                disabled={!canUndo}
                className="p-2 rounded-lg text-text-secondary hover:text-text-primary hover:bg-dark-700 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                title={`Undo (Ctrl+Z)${canUndo ? ` - ${undoCount} steps` : ''}`}
                aria-label="Undo"
            >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h10a4 4 0 014 4v2M3 10l4-4m-4 4l4 4" />
                </svg>
            </button>
            <button
                onClick={redo}
                disabled={!canRedo}
                className="p-2 rounded-lg text-text-secondary hover:text-text-primary hover:bg-dark-700 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                title={`Redo (Ctrl+Shift+Z)${canRedo ? ` - ${redoCount} steps` : ''}`}
                aria-label="Redo"
            >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 10H11a4 4 0 00-4 4v2m14-6l-4-4m4 4l-4 4" />
                </svg>
            </button>
        </div>
    );
}

// History Timeline Component (optional, for debugging or power users)
export function HistoryTimeline({ maxVisible = 5 }) {
    const { past, canUndo, undo, undoCount } = useHistory();

    if (!canUndo) return null;

    const visibleHistory = past.slice(-maxVisible).reverse();

    return (
        <div className="bg-dark-800 border border-dark-600 rounded-lg p-3">
            <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-text-secondary">History</span>
                <span className="text-xs text-text-muted">{undoCount} steps</span>
            </div>
            <div className="space-y-1">
                {visibleHistory.map((_, index) => (
                    <button
                        key={index}
                        onClick={() => {
                            // Undo multiple times to get to this point
                            for (let i = 0; i <= index; i++) {
                                undo();
                            }
                        }}
                        className="w-full text-left text-xs text-text-muted hover:text-text-primary p-1 rounded hover:bg-dark-700 transition-colors"
                    >
                        {index === 0 ? 'Previous state' : `${index + 1} steps back`}
                    </button>
                ))}
            </div>
        </div>
    );
}
