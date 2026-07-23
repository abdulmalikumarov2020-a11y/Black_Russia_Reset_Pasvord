import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import Header from '@/components/Header'

const inter = Inter({ subsets: ['latin', 'cyrillic'] })

const SITE_URL = 'https://example.com'
const SITE_NAME = 'Мой блог'
const SITE_DESCRIPTION =
  'Личный блог о разработке: Next.js, React, TypeScript и Tailwind CSS.'

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: SITE_NAME,
    template: `%s · ${SITE_NAME}`,
  },
  description: SITE_DESCRIPTION,
  openGraph: {
    type: 'website',
    locale: 'ru_RU',
    siteName: SITE_NAME,
    title: SITE_NAME,
    description: SITE_DESCRIPTION,
  },
  twitter: {
    card: 'summary_large_image',
    title: SITE_NAME,
    description: SITE_DESCRIPTION,
  },
}

// Скрипт применяет сохранённую тему ДО первой отрисовки, чтобы избежать
// мигания (FOUC) между светлой и тёмной темой при загрузке страницы.
const THEME_INIT_SCRIPT = `
(function () {
  try {
    var theme = localStorage.getItem('theme');
    var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    if (theme === 'dark' || (!theme && prefersDark)) {
      document.documentElement.classList.add('dark');
    }
  } catch (e) {}
})();
`

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ru" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: THEME_INIT_SCRIPT }} />
      </head>
      <body className={inter.className}>
        <Header />
        <main className="mx-auto min-h-screen max-w-3xl px-4 py-8">{children}</main>
        <footer className="border-t border-slate-200 py-8 text-center text-sm text-slate-500 dark:border-slate-800 dark:text-slate-400">
          © {new Date().getFullYear()} {SITE_NAME}. Сделано на Next.js.
        </footer>
      </body>
    </html>
  )
}
