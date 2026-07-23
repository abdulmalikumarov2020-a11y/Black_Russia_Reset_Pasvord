import type { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { MDXRemote } from 'next-mdx-remote/rsc'
import remarkGfm from 'remark-gfm'
import rehypeHighlight from 'rehype-highlight'
import rehypeSlug from 'rehype-slug'
import Link from 'next/link'
import { getAllSlugs, getPostBySlug } from '@/lib/posts'
import { mdxComponents } from '@/components/MdxComponents'

interface PostPageProps {
  params: { slug: string }
}

// SSG: заранее сообщаем Next.js все существующие посты для статической сборки
export function generateStaticParams() {
  return getAllSlugs().map((slug) => ({ slug }))
}

// Генерация SEO-метатегов индивидуально для каждого поста
export async function generateMetadata({ params }: PostPageProps): Promise<Metadata> {
  const post = getPostBySlug(params.slug)
  if (!post) return {}

  return {
    title: post.title,
    description: post.excerpt,
    keywords: post.tags,
    openGraph: {
      type: 'article',
      title: post.title,
      description: post.excerpt,
      publishedTime: post.date,
      tags: post.tags,
      images: post.cover ? [{ url: post.cover }] : undefined,
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: post.cover ? [post.cover] : undefined,
    },
    alternates: {
      canonical: `/posts/${post.slug}`,
    },
  }
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('ru-RU', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
}

export default function PostPage({ params }: PostPageProps) {
  const post = getPostBySlug(params.slug)
  if (!post) notFound()

  return (
    <article>
      <header className="mb-8">
        <h1 className="text-3xl font-bold leading-tight">{post.title}</h1>
        <div className="mt-2 flex flex-wrap items-center gap-2 text-sm text-slate-500 dark:text-slate-400">
          <time dateTime={post.date}>{formatDate(post.date)}</time>
          <span>·</span>
          <span>{post.readingTime}</span>
        </div>
        {post.tags.length > 0 && (
          <div className="mt-3 flex flex-wrap gap-2">
            {post.tags.map((tag) => (
              <Link
                key={tag}
                href={`/tags/${encodeURIComponent(tag)}`}
                className="rounded-full bg-slate-100 px-2.5 py-0.5 text-xs text-slate-600 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700"
              >
                #{tag}
              </Link>
            ))}
          </div>
        )}
      </header>

      {post.cover && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={post.cover}
          alt={post.title}
          className="mb-8 aspect-video w-full rounded-lg object-cover"
        />
      )}

      <div className="prose prose-slate max-w-none dark:prose-invert">
        <MDXRemote
          source={post.content}
          components={mdxComponents}
          options={{
            mdxOptions: {
              remarkPlugins: [remarkGfm],
              rehypePlugins: [rehypeSlug, rehypeHighlight],
            },
          }}
        />
      </div>

      <div className="mt-10 border-t border-slate-200 pt-6 dark:border-slate-800">
        <Link href="/" className="text-brand-600 hover:underline dark:text-brand-500">
          ← Ко всем постам
        </Link>
      </div>
    </article>
  )
}
