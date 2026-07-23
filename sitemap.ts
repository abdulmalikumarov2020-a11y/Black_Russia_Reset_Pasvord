import type { MetadataRoute } from 'next'
import { getAllPosts, getAllTags } from '@/lib/posts'

const SITE_URL = 'https://example.com'

export default function sitemap(): MetadataRoute.Sitemap {
  const posts = getAllPosts()
  const tags = getAllTags()

  const postEntries: MetadataRoute.Sitemap = posts.map((post) => ({
    url: `${SITE_URL}/posts/${post.slug}`,
    lastModified: post.date,
  }))

  const tagEntries: MetadataRoute.Sitemap = tags.map((tag) => ({
    url: `${SITE_URL}/tags/${encodeURIComponent(tag)}`,
  }))

  return [
    { url: SITE_URL },
    { url: `${SITE_URL}/tags` },
    { url: `${SITE_URL}/search` },
    ...postEntries,
    ...tagEntries,
  ]
}
