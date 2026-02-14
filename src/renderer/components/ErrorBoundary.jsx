import React from 'react';

class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null, errorInfo: null };
    }

    static getDerivedStateFromError(error) {
        return { hasError: true };
    }

    componentDidCatch(error, errorInfo) {
        this.setState({
            error: error,
            errorInfo: errorInfo
        });
        // Log error to console in development
        console.error('ErrorBoundary caught an error:', error, errorInfo);
    }

    handleReload = () => {
        window.location.reload();
    };

    handleGoBack = () => {
        this.setState({ hasError: false, error: null, errorInfo: null });
        if (this.props.onReset) {
            this.props.onReset();
        }
    };

    render() {
        if (this.state.hasError) {
            return (
                <div className="min-h-screen bg-dark-950 flex items-center justify-center p-8">
                    <div className="max-w-md w-full text-center">
                        {/* Error Icon */}
                        <div className="mb-6 flex justify-center">
                            <div className="w-20 h-20 rounded-2xl bg-accent-danger/20 flex items-center justify-center">
                                <svg className="w-10 h-10 text-accent-danger" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                                </svg>
                            </div>
                        </div>

                        {/* Error Message */}
                        <h1 className="text-2xl font-bold text-text-primary mb-2">
                            Something went wrong
                        </h1>
                        <p className="text-text-secondary mb-6">
                            An unexpected error occurred. Your data is safe - try refreshing the app.
                        </p>

                        {/* Error Details (collapsible in dev) */}
                        {process.env.NODE_ENV === 'development' && this.state.error && (
                            <details className="mb-6 text-left">
                                <summary className="text-sm text-text-muted cursor-pointer hover:text-text-secondary">
                                    Technical Details
                                </summary>
                                <pre className="mt-2 p-3 bg-dark-800 rounded-lg text-xs text-accent-danger overflow-auto max-h-40">
                                    {this.state.error.toString()}
                                    {this.state.errorInfo?.componentStack}
                                </pre>
                            </details>
                        )}

                        {/* Action Buttons */}
                        <div className="flex gap-3 justify-center">
                            <button
                                onClick={this.handleGoBack}
                                className="btn btn-ghost px-6 py-2"
                            >
                                Go Back
                            </button>
                            <button
                                onClick={this.handleReload}
                                className="btn btn-primary px-6 py-2"
                            >
                                Reload App
                            </button>
                        </div>

                        {/* Support Info */}
                        <p className="text-xs text-text-muted mt-8">
                            If the problem persists, please save your work and restart the application.
                        </p>
                    </div>
                </div>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;
