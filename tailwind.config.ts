import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: 'class',
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
    './content/**/*.{md,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#eef6ff',
          100: '#d9eaff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },
      typography: () => ({
        DEFAULT: {
          css: {
            maxWidth: 'none',
            a: {
              color: '#2563eb',
              textDecoration: 'underline',
              '&:hover': { color: '#1d4ed8' },
            },
            code: {
              backgroundColor: 'rgba(148, 163, 184, 0.15)',
              padding: '0.15rem 0.35rem',
              borderRadius: '0.35rem',
              fontWeight: '500',
            },
            'code::before': { content: 'none' },
            'code::after': { content: 'none' },
          },
        },
        invert: {
          css: {
            a: { color: '#60a5fa' },
          },
        },
      }),
    },
  },
  plugins: [require('@tailwindcss/typography')],
}

export default config
