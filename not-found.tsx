import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center py-24 text-center">
      <h1 className="text-4xl font-bold">404</h1>
      <p className="mt-2 text-slate-500 dark:text-slate-400">
        Страница не найдена.
      </p>
      <Link href="/" className="mt-6 text-brand-600 hover:underline dark:text-brand-500">
        ← Вернуться на главную
      </Link>
    </div>
  )
}
