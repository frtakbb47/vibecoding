/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./src/renderer/**/*.{js,jsx,ts,tsx}",
        "./src/renderer/index.html",
    ],
    darkMode: 'class',
    theme: {
        extend: {
            colors: {
                // Theme-aware colors using CSS variables
                dark: {
                    950: 'var(--color-bg-base)',
                    900: 'var(--color-bg-elevated)',
                    800: 'var(--color-bg-card)',
                    700: 'var(--color-bg-hover)',
                    600: 'var(--color-border)',
                    500: 'var(--color-border-hover)',
                },
                // Accent colors
                accent: {
                    primary: 'var(--color-accent-primary)',
                    hover: 'var(--color-accent-hover)',
                    success: 'var(--color-accent-success)',
                    warning: 'var(--color-accent-warning)',
                    danger: 'var(--color-accent-danger)',
                },
                // Text colors
                text: {
                    primary: 'var(--color-text-primary)',
                    secondary: 'var(--color-text-secondary)',
                    muted: 'var(--color-text-muted)',
                },
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
                mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
            },
            boxShadow: {
                'glow': '0 0 20px rgba(129, 140, 248, 0.3)',
                'glow-success': '0 0 20px rgba(52, 211, 153, 0.3)',
            },
            animation: {
                'scale-in': 'scaleIn 0.2s ease-out',
                'fade-in': 'fadeIn 0.2s ease-out',
                'slide-up': 'slideUp 0.3s ease-out',
            },
            keyframes: {
                scaleIn: {
                    '0%': { transform: 'scale(0.95)', opacity: '0' },
                    '100%': { transform: 'scale(1)', opacity: '1' },
                },
                fadeIn: {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                slideUp: {
                    '0%': { transform: 'translateY(10px)', opacity: '0' },
                    '100%': { transform: 'translateY(0)', opacity: '1' },
                },
            },
        },
    },
    plugins: [],
};
