# Личный блог на Next.js (App Router + TypeScript + Tailwind + MDX)

Полноценный личный блог со статической генерацией (SSG), MDX-постами,
тёмной/светлой темой, тегами и поиском по заголовкам.

## Возможности

- 📄 Главная страница со списком постов (заголовок, дата, краткое описание) и пагинацией
- 📝 Страницы постов из `.mdx`-файлов: подсветка синтаксиса кода, изображения, Markdown/GFM
- 🏷 Категории (теги) — страница `/tags` и `/tags/[tag]`
- 🔎 Поиск по заголовкам и тегам на странице `/search`
- 🌗 Светлая/тёмная тема с сохранением выбора в `localStorage` (без мигания при загрузке)
- 📱 Адаптивная вёрстка на Tailwind CSS
- 🚀 Полная статическая генерация (SSG) через `generateStaticParams`
- 🔍 SEO: уникальные метатеги (`generateMetadata`) для каждого поста, `sitemap.xml`, `robots.txt`

## Структура проекта

```
personal-blog/
├── content/
│   └── posts/              # .mdx-файлы постов (frontmatter + контент)
│       ├── hello-world.mdx
│       ├── nextjs-tips.mdx
│       └── tailwind-guide.mdx
├── src/
│   ├── app/
│   │   ├── layout.tsx       # корневой layout, скрипт темы, метаданные
│   │   ├── page.tsx         # главная страница (список + пагинация)
│   │   ├── globals.css      # Tailwind + стили подсветки кода
│   │   ├── sitemap.ts       # генерация sitemap.xml
│   │   ├── robots.ts        # генерация robots.txt
│   │   ├── not-found.tsx    # страница 404
│   │   ├── posts/[slug]/    # страница отдельного поста (SSG + SEO)
│   │   ├── tags/            # список тегов и страница по тегу
│   │   └── search/          # страница поиска
│   ├── components/          # Header, ThemeToggle, PostCard, Pagination, SearchClient…
│   ├── lib/posts.ts          # чтение и обработка .mdx через gray-matter
│   └── types/post.ts
├── package.json
├── tailwind.config.ts
├── tsconfig.json
└── next.config.mjs
```

## Установка

Требуется **Node.js 18.17+** (рекомендуется 20 LTS).

```bash
# 1. Установить зависимости
npm install

# 2. Запустить сервер разработки
npm run dev
```

Открыть [http://localhost:3000](http://localhost:3000).

## Сборка и запуск production-версии

```bash
npm run build   # статическая генерация всех страниц (SSG)
npm run start   # запуск production-сервера
```

После `npm run build` вы увидите в консоли, что страницы постов и тегов
помечены как `●  (SSG)` — они собираются в HTML на этапе сборки.

## Как добавить новый пост

Создайте файл `content/posts/moy-novyy-post.mdx` со следующей структурой:

```mdx
---
title: "Заголовок поста"
date: "2026-05-01"
excerpt: "Краткое описание для списка постов и мета-тега description."
tags: ["nextjs", "заметки"]
cover: "https://example.com/cover.jpg"
---

## Заголовок раздела

Обычный **Markdown**-текст, списки, `код`, а также блоки кода:

\`\`\`ts
const x: number = 42
\`\`\`

![Подпись к изображению](https://example.com/image.jpg)
```

Поле `slug` берётся из имени файла (`moy-novyy-post`). После сохранения
файла пост автоматически появится на главной странице, в поиске и — если
указаны теги — на соответствующих страницах тегов. Дополнительно ничего
регистрировать не нужно: `generateStaticParams` подхватит новый файл
при следующей сборке (`npm run build`) или сразу в режиме разработки.

## Настройка SEO / домена

В файлах `src/app/layout.tsx`, `src/app/sitemap.ts` и `src/app/robots.ts`
замените константу `SITE_URL` (`https://example.com`) на реальный домен
вашего блога — это нужно для корректных `canonical`-ссылок, Open Graph
и `sitemap.xml`.

## Переключение темы

Тема хранится в `localStorage` под ключом `theme` (`light` | `dark`).
Если значения ещё нет, используется системная настройка
`prefers-color-scheme`. Переключатель находится в шапке сайта
(`src/components/ThemeToggle.tsx`).

## Технологии

- [Next.js 14](https://nextjs.org/) (App Router)
- TypeScript
- Tailwind CSS + `@tailwindcss/typography`
- `next-mdx-remote` — рендеринг MDX на сервере (RSC)
- `remark-gfm`, `rehype-highlight`, `rehype-slug` — Markdown-плагины
- `gray-matter` — парсинг frontmatter
- `reading-time` — оценка времени чтения

## Деплой

Проект без изменений разворачивается на [Vercel](https://vercel.com/):
подключите репозиторий — сборка и SSG настроятся автоматически
(`npm run build`). Также подойдёт любой хостинг с поддержкой Node.js
(Netlify, Render, self-hosted через `npm run build && npm run start`).
