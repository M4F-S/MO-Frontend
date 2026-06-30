# SEO and Web Standards Reference

> Comprehensive guide to SEO and web standards for frontend applications. Covers meta tags, Open Graph, Twitter Cards, structured data, sitemaps, robots.txt, semantic URLs, performance SEO, internationalization, image SEO, social sharing, and Next.js SEO implementation.

---

## Table of Contents

1. [Meta Tags](#1-meta-tags)
2. [Open Graph](#2-open-graph)
3. [Twitter Cards](#3-twitter-cards)
4. [Structured Data](#4-structured-data)
5. [Sitemap](#5-sitemap)
6. [Robots.txt](#6-robotstxt)
7. [Semantic URLs](#7-semantic-urls)
8. [Performance SEO](#8-performance-seo)
9. [International SEO](#9-international-seo)
10. [Image SEO](#10-image-seo)
11. [Social Sharing](#11-social-sharing)
12. [Next.js SEO](#12-nextjs-seo)

---

## 1. Meta Tags

### 1.1 Essential Meta Tags

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <!-- Character encoding -->
  <meta charset="UTF-8" />
  
  <!-- Viewport for responsive design -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0" />
  
  <!-- Page title (50-60 chars optimal) -->
  <title>Complete Guide to React Performance Optimization | MyApp</title>
  
  <!-- Meta description (150-160 chars optimal) -->
  <meta name="description" content="Learn proven techniques to optimize React app performance. Covers code splitting, lazy loading, memoization, and more." />
  
  <!-- Canonical URL (prevents duplicate content issues) -->
  <link rel="canonical" href="https://www.myapp.com/blog/react-performance" />
  
  <!-- Robots directive -->
  <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
  
  <!-- Author and copyright -->
  <meta name="author" content="MyApp Team" />
  <meta name="copyright" content="MyApp Inc." />
  
  <!-- Theme color for mobile browsers -->
  <meta name="theme-color" content="#0f172a" media="(prefers-color-scheme: dark)" />
  <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)" />
  
  <!-- Format detection (prevent iOS from auto-detecting) -->
  <meta name="format-detection" content="telephone=no, date=no, address=no" />
</head>
</html>
```

### 1.2 Meta Tag Reference Table

| Tag | Purpose | Recommendation |
|-----|---------|---------------|
| `title` | Page title in search results | 50-60 chars, unique per page |
| `description` | Snippet in search results | 150-160 chars, compelling CTA |
| `robots` | Crawler instructions | `index, follow` for content; `noindex` for admin |
| `canonical` | Preferred URL version | Always set, especially with query params |
| `viewport` | Mobile rendering | `width=device-width, initial-scale=1` |
| `charset` | Character encoding | Always `UTF-8` |
| `theme-color` | Browser UI color | Match brand, support dark/light |

---

## 2. Open Graph

### 2.1 Open Graph Protocol

```html
<!-- Basic Open Graph tags -->
<meta property="og:title" content="Complete Guide to React Performance" />
<meta property="og:description" content="Learn proven techniques to optimize React app performance." />
<meta property="og:type" content="article" />
<meta property="og:url" content="https://www.myapp.com/blog/react-performance" />
<meta property="og:image" content="https://www.myapp.com/og-images/react-performance.jpg" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:image:alt" content="React performance optimization diagram" />
<meta property="og:site_name" content="MyApp" />
<meta property="og:locale" content="en_US" />

<!-- Article specific -->
<meta property="article:published_time" content="2024-01-15T10:00:00+00:00" />
<meta property="article:modified_time" content="2024-01-20T15:30:00+00:00" />
<meta property="article:author" content="https://www.myapp.com/authors/jane-doe" />
<meta property="article:section" content="Development" />
<meta property="article:tag" content="React" />
<meta property="article:tag" content="Performance" />
<meta property="article:tag" content="JavaScript" />
```

### 2.2 Open Graph Types

```html
<!-- Website (default) -->
<meta property="og:type" content="website" />

<!-- Article (for blog posts) -->
<meta property="og:type" content="article" />
<meta property="article:published_time" content="2024-01-15T00:00:00Z" />

<!-- Product (for e-commerce) -->
<meta property="og:type" content="product" />
<meta property="product:price:amount" content="29.99" />
<meta property="product:price:currency" content="USD" />
<meta property="product:availability" content="instock" />

<!-- Profile -->
<meta property="og:type" content="profile" />
<meta property="profile:first_name" content="Jane" />
<meta property="profile:last_name" content="Doe" />
<meta property="profile:username" content="janedoe" />

<!-- Video -->
<meta property="og:type" content="video.other" />
<meta property="og:video" content="https://myapp.com/video.mp4" />
<meta property="og:video:width" content="1280" />
<meta property="og:video:height" content="720" />
```

### 2.3 Open Graph Image Best Practices

```typescript
// Open Graph image requirements:
// - Minimum: 200x200px
// - Recommended: 1200x630px (1.91:1 ratio)
// - Maximum: 8MB file size
// - Format: JPEG, PNG, or GIF
// - Safe zone: Keep text within 100px from edges

// Dynamic OG image generation (Next.js)
// app/blog/[slug]/opengraph-image.tsx
import { ImageResponse } from 'next/og';

export const runtime = 'edge';
export const alt = 'Blog post preview';
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';

export default async function Image({ params }: { params: { slug: string } }) {
  const post = await getPost(params.slug);
  
  return new ImageResponse(
    (
      <div
        style={{
          background: 'linear-gradient(to bottom, #1a1a2e, #16213e)',
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '60px',
        }}
      >
        <h1 style={{ fontSize: 60, color: 'white', textAlign: 'center' }}>
          {post.title}
        </h1>
        <p style={{ fontSize: 30, color: '#a0a0a0', marginTop: 20 }}>
          {post.author} · {post.readTime} min read
        </p>
      </div>
    ),
    { ...size }
  );
}
```

---

## 3. Twitter Cards

### 3.1 Twitter Card Types

```html
<!-- Summary Card (default) -->
<meta name="twitter:card" content="summary" />
<meta name="twitter:site" content="@myapp" />
<meta name="twitter:creator" content="@jane_doe" />
<meta name="twitter:title" content="Complete Guide to React Performance" />
<meta name="twitter:description" content="Learn proven techniques to optimize React app performance." />
<meta name="twitter:image" content="https://www.myapp.com/og-images/react-performance.jpg" />
<meta name="twitter:image:alt" content="React performance optimization diagram" />

<!-- Summary Card with Large Image -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="Complete Guide to React Performance" />
<meta name="twitter:description" content="Learn proven techniques to optimize React app performance." />
<meta name="twitter:image" content="https://www.myapp.com/og-images/react-performance-large.jpg" />
<!-- Image: minimum 300x157, recommended 1200x628 -->

<!-- App Card (for mobile apps) -->
<meta name="twitter:card" content="app" />
<meta name="twitter:app:id:iphone" content="123456789" />
<meta name="twitter:app:id:ipad" content="123456789" />
<meta name="twitter:app:id:googleplay" content="com.myapp" />
<meta name="twitter:app:country" content="US" />

<!-- Player Card (for video/audio) -->
<meta name="twitter:card" content="player" />
<meta name="twitter:player" content="https://www.myapp.com/embed/video" />
<meta name="twitter:player:width" content="1280" />
<meta name="twitter:player:height" content="720" />
```

### 3.2 Twitter Card Checklist

```typescript
// Twitter Card requirements:
// - title: max 70 chars
// - description: max 200 chars
// - image: 
//   - summary: 144x144 min, 4096x4096 max, 5MB max
//   - summary_large_image: 300x157 min, 4096x4096 max, 5MB max
//   - Must be less than 5MB (JPG/PNG/GIF/WebP)
// - card type: summary, summary_large_image, app, player

// Validate with: https://cards-dev.twitter.com/validator
```

---

## 4. Structured Data

### 4.1 JSON-LD Basics

```html
<!-- Article structured data -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Complete Guide to React Performance",
  "description": "Learn proven techniques to optimize React app performance.",
  "image": "https://www.myapp.com/images/react-performance.jpg",
  "author": {
    "@type": "Person",
    "name": "Jane Doe",
    "url": "https://www.myapp.com/authors/jane-doe"
  },
  "publisher": {
    "@type": "Organization",
    "name": "MyApp",
    "logo": {
      "@type": "ImageObject",
      "url": "https://www.myapp.com/logo.png"
    }
  },
  "datePublished": "2024-01-15T10:00:00+00:00",
  "dateModified": "2024-01-20T15:30:00+00:00",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://www.myapp.com/blog/react-performance"
  }
}
</script>
```

### 4.2 Common Schema Types

```html
<!-- Organization -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "MyApp",
  "url": "https://www.myapp.com",
  "logo": "https://www.myapp.com/logo.png",
  "sameAs": [
    "https://twitter.com/myapp",
    "https://github.com/myapp",
    "https://linkedin.com/company/myapp"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-555-5555",
    "contactType": "customer service"
  }
}
</script>

<!-- Product (E-commerce) -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Premium Plan",
  "image": "https://www.myapp.com/images/premium-plan.jpg",
  "description": "Everything you need for team collaboration",
  "brand": {
    "@type": "Brand",
    "name": "MyApp"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://www.myapp.com/pricing",
    "price": "29.99",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock",
    "priceValidUntil": "2024-12-31"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "1247"
  }
}
</script>

<!-- BreadcrumbList -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://www.myapp.com"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Blog",
      "item": "https://www.myapp.com/blog"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "React Performance",
      "item": "https://www.myapp.com/blog/react-performance"
    }
  ]
}
</script>

<!-- FAQPage -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the best way to optimize React?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The best approach combines code splitting, memoization, and efficient state management."
      }
    }
  ]
}
</script>
```

### 4.3 Schema.org Types Reference

| Type | Use Case | Required Properties |
|------|----------|---------------------|
| `Article` | Blog posts, news | `headline`, `datePublished` |
| `Organization` | Company info | `name`, `url` |
| `Product` | E-commerce items | `name`, `offers` |
| `BreadcrumbList` | Navigation breadcrumbs | `itemListElement` |
| `FAQPage` | FAQ sections | `mainEntity` |
| `SoftwareApplication` | App listings | `name`, `applicationCategory` |
| `WebSite` | Site search | `url`, `potentialAction` |
| `LocalBusiness` | Physical locations | `name`, `address` |
| `Event` | Events, webinars | `name`, `startDate`, `location` |
| `Course` | Educational content | `name`, `provider` |

---

## 5. Sitemap

### 5.1 XML Sitemap

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <!-- Homepage -->
  <url>
    <loc>https://www.myapp.com/</loc>
    <lastmod>2024-01-15</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  
  <!-- Blog index -->
  <url>
    <loc>https://www.myapp.com/blog</loc>
    <lastmod>2024-01-15</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.9</priority>
  </url>
  
  <!-- Blog posts -->
  <url>
    <loc>https://www.myapp.com/blog/react-performance</loc>
    <lastmod>2024-01-15</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
  
  <!-- Product pages -->
  <url>
    <loc>https://www.myapp.com/pricing</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
  
  <!-- Lower priority pages -->
  <url>
    <loc>https://www.myapp.com/privacy</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>yearly</changefreq>
    <priority>0.3</priority>
  </url>
</urlset>
```

### 5.2 Dynamic Sitemap Generation (Next.js)

```tsx
// app/sitemap.ts
import { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = 'https://www.myapp.com';
  
  // Fetch dynamic routes
  const posts = await fetchPosts();
  const products = await fetchProducts();
  
  const staticRoutes = [
    { url: baseUrl, lastModified: new Date(), changeFrequency: 'daily' as const, priority: 1 },
    { url: `${baseUrl}/blog`, lastModified: new Date(), changeFrequency: 'daily', priority: 0.9 },
    { url: `${baseUrl}/pricing`, lastModified: new Date(), changeFrequency: 'weekly', priority: 0.8 },
  ];
  
  const postRoutes = posts.map((post) => ({
    url: `${baseUrl}/blog/${post.slug}`,
    lastModified: new Date(post.updatedAt),
    changeFrequency: 'monthly' as const,
    priority: 0.7,
  }));
  
  const productRoutes = products.map((product) => ({
    url: `${baseUrl}/products/${product.slug}`,
    lastModified: new Date(product.updatedAt),
    changeFrequency: 'weekly' as const,
    priority: 0.8,
  }));
  
  return [...staticRoutes, ...postRoutes, ...productRoutes];
}

// Sitemap index for large sites (Next.js 13+)
// app/sitemap.xml/route.ts
import { getServerSideSitemap } from 'next-sitemap';

export async function GET() {
  return getServerSideSitemap([
    { loc: 'https://www.myapp.com/sitemap-pages.xml' },
    { loc: 'https://www.myapp.com/sitemap-posts.xml' },
    { loc: 'https://www.myapp.com/sitemap-products.xml' },
  ]);
}
```

### 5.3 Sitemap Index

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>https://www.myapp.com/sitemap-pages.xml</loc>
    <lastmod>2024-01-15</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://www.myapp.com/sitemap-blog.xml</loc>
    <lastmod>2024-01-15</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://www.myapp.com/sitemap-products.xml</loc>
    <lastmod>2024-01-15</lastmod>
  </sitemap>
</sitemapindex>
```

---

## 6. Robots.txt

### 6.1 Basic Robots.txt

```text
# robots.txt
User-agent: *
Allow: /

# Disallow admin and private areas
Disallow: /admin/
Disallow: /api/
Disallow: /internal/
Disallow: /drafts/

# Disallow search parameters
Disallow: /*?sort=
Disallow: /*?filter=
Disallow: /*?page= 

# Crawl delay (optional, use sparingly)
Crawl-delay: 1

# Sitemap location
Sitemap: https://www.myapp.com/sitemap.xml

# Google-specific
User-agent: Googlebot
Allow: /
Disallow: /no-google/

# Block image indexing for specific paths
User-agent: Googlebot-Image
Disallow: /private-images/
```

### 6.2 Robots.txt Rules Reference

| Directive | Description | Example |
|-----------|-------------|---------|
| `User-agent` | Target crawler | `User-agent: *` (all) or `Googlebot` |
| `Allow` | Allow specific path | `Allow: /public/` |
| `Disallow` | Block specific path | `Disallow: /admin/` |
| `Sitemap` | Sitemap location | `Sitemap: https://.../sitemap.xml` |
| `Crawl-delay` | Delay between requests | `Crawl-delay: 10` |
| `Host` | Preferred domain (Yandex) | `Host: www.example.com` |

### 6.3 Meta Robots Tag

```html
<!-- Index this page, follow links (default) -->
<meta name="robots" content="index, follow" />

<!-- No index, no follow (private pages) -->
<meta name="robots" content="noindex, nofollow" />

<!-- Index but don't follow links -->
<meta name="robots" content="index, nofollow" />

<!-- No index but follow links (useful for filtered pages) -->
<meta name="robots" content="noindex, follow" />

<!-- Advanced directives -->
<meta name="robots" content="noindex, nofollow, noarchive, nosnippet, max-snippet:-1, max-image-preview:large" />

<!-- Google-specific -->
<meta name="googlebot" content="noindex, nofollow" />
<meta name="googlebot-news" content="noindex, nosnippet" />
```

---

## 7. Semantic URLs

### 7.1 URL Best Practices

```typescript
// Good URL structure
// /blog/react-performance-optimization
// /products/macbook-pro-16
// /categories/electronics/laptops
// /users/john-doe
// /search?q=react+hooks

// Bad URL structure
// /blog?id=12345
// /page.php?category=5&product=12
// /index.html#!/products/123
// /blog/My_Post_Title
// /products/item_12345

// Next.js dynamic routes
// app/blog/[slug]/page.tsx
// app/products/[category]/[product]/page.tsx
// app/users/[username]/page.tsx

// Generate clean URLs
function generateSlug(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

// Example: "React Performance Optimization!" -> "react-performance-optimization"
```

### 7.2 URL Structure Guidelines

| Rule | Good | Bad |
|------|------|-----|
| Use hyphens | `/blog/my-post` | `/blog/my_post` |
| Lowercase | `/products/laptop` | `/Products/Laptop` |
| No file extensions | `/about` | `/about.html` |
| No query params for content | `/products/laptop` | `/products?id=123` |
| Limit path depth | `/blog/category/post` | `/blog/2024/01/15/category/post` |
| Canonical trailing slash | `/blog/` (consistent) | Mixed `/blog` and `/blog/` |

---

## 8. Performance SEO

### 8.1 Core Web Vitals as Ranking Factors

```html
<!-- Preload critical resources for LCP -->
<link rel="preload" href="/fonts/Inter.woff2" as="font" type="font/woff2" crossorigin />
<link rel="preload" href="/images/hero.jpg" as="image" />
<link rel="preload" href="/critical.css" as="style" />

<!-- Preconnect to third-party domains -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="preconnect" href="https://cdn.myapp.com" />
<link rel="dns-prefetch" href="https://analytics.myapp.com" />

<!-- Prefetch next likely page -->
<link rel="prefetch" href="/pricing" />
<link rel="prefetch" href="/about" />
```

### 8.2 Mobile-First Indexing

```html
<!-- Responsive meta tag (essential) -->
<meta name="viewport" content="width=device-width, initial-scale=1.0" />

<!-- Mobile-friendly practices -->
<!-- 1. Tap targets minimum 48x48px -->
<!-- 2. Font size minimum 16px (prevents iOS zoom) -->
<!-- 3. Responsive images with srcset -->
<!-- 4. Avoid horizontal scroll -->
<!-- 5. Test with Google Mobile-Friendly Test -->

<!-- Responsive breakpoints -->
<style>
  /* Mobile first approach */
  .container { padding: 16px; }
  
  @media (min-width: 768px) {
    .container { padding: 24px; }
  }
  
  @media (min-width: 1024px) {
    .container { padding: 32px; max-width: 1200px; margin: 0 auto; }
  }
</style>
```

### 8.3 Page Speed Checklist

```typescript
// SEO Performance Checklist
// [ ] LCP < 2.5s (Largest Contentful Paint)
// [ ] CLS < 0.1 (Cumulative Layout Shift)
// [ ] INP < 200ms (Interaction to Next Paint)
// [ ] FCP < 1.8s (First Contentful Paint)
// [ ] TTFB < 800ms (Time to First Byte)
// [ ] Mobile speed score > 90 (PageSpeed Insights)
// [ ] Compress images (WebP/AVIF)
// [ ] Lazy load below-fold images
// [ ] Minimize render-blocking resources
// [ ] Use CDN for static assets
// [ ] Enable text compression (Brotli/Gzip)
// [ ] Implement browser caching
```

---

## 9. International SEO

### 9.1 Hreflang Implementation

```html
<!-- HTML link tags -->
<link rel="alternate" hreflang="en" href="https://www.myapp.com/blog/react-performance" />
<link rel="alternate" hreflang="en-gb" href="https://www.myapp.com/en-gb/blog/react-performance" />
<link rel="alternate" hreflang="de" href="https://www.myapp.com/de/blog/react-performance" />
<link rel="alternate" hreflang="fr" href="https://www.myapp.com/fr/blog/react-performance" />
<link rel="alternate" hreflang="x-default" href="https://www.myapp.com/blog/react-performance" />

<!-- HTTP header -->
<!-- Link: <https://www.myapp.com/de/>; rel="alternate"; hreflang="de" -->

<!-- Sitemap -->
<url>
  <loc>https://www.myapp.com/blog/react-performance</loc>
  <xhtml:link rel="alternate" hreflang="en" href="https://www.myapp.com/blog/react-performance" />
  <xhtml:link rel="alternate" hreflang="de" href="https://www.myapp.com/de/blog/react-performance" />
  <xhtml:link rel="alternate" hreflang="x-default" href="https://www.myapp.com/blog/react-performance" />
</url>
```

### 9.2 Next.js Internationalization

```tsx
// next.config.js
module.exports = {
  i18n: {
    locales: ['en', 'en-GB', 'de', 'fr'],
    defaultLocale: 'en',
    domains: [
      { domain: 'myapp.com', defaultLocale: 'en' },
      { domain: 'myapp.co.uk', defaultLocale: 'en-GB' },
      { domain: 'myapp.de', defaultLocale: 'de' },
      { domain: 'myapp.fr', defaultLocale: 'fr' },
    ],
  },
};

// App Router: Middleware for locale detection
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  const locale = request.headers.get('accept-language')?.split(',')[0]?.split('-')[0] ?? 'en';
  const supportedLocales = ['en', 'de', 'fr'];
  const finalLocale = supportedLocales.includes(locale) ? locale : 'en';
  
  return NextResponse.rewrite(new URL(`/${finalLocale}${request.nextUrl.pathname}`, request.url));
}

// Metadata per locale
// app/[lang]/layout.tsx
export async function generateMetadata({ params }: { params: { lang: string } }) {
  const translations = {
    en: { title: 'MyApp - Build Better Software', description: '...' },
    de: { title: 'MyApp - Bessere Software Bauen', description: '...' },
    fr: { title: 'MyApp - Construire de Meilleurs Logiciels', description: '...' },
  };
  
  return {
    title: translations[params.lang].title,
    description: translations[params.lang].description,
    alternates: {
      canonical: `https://www.myapp.com/${params.lang}`,
      languages: {
        'en': 'https://www.myapp.com/en',
        'de': 'https://www.myapp.com/de',
        'fr': 'https://www.myapp.com/fr',
      },
    },
  };
}
```

### 9.3 Language-Specific Content

```html
<!-- HTML lang attribute -->
<html lang="en">

<!-- Date formatting per locale -->
<time datetime="2024-01-15">January 15, 2024</time>
<!-- For German: <time datetime="2024-01-15">15. Januar 2024</time> -->

<!-- Currency formatting -->
<span data-currency="USD">$29.99</span>
<!-- For German: <span data-currency="EUR">29,99 €</span> -->

<!-- RTL support -->
<html lang="ar" dir="rtl">
```

---

## 10. Image SEO

### 10.1 Image Optimization for SEO

```html
<!-- Descriptive filename (not IMG_1234.jpg) -->
<img src="react-performance-optimization-guide.jpg" alt="React performance optimization diagram showing code splitting and lazy loading" />

<!-- Alt text best practices -->
<!-- Good: Descriptive, concise, includes keywords naturally -->
<img src="dashboard.jpg" alt="MyApp analytics dashboard showing user engagement metrics and conversion funnel" />

<!-- Bad: Vague, keyword-stuffed, or missing -->
<img src="dashboard.jpg" alt="image" /> <!-- Too vague -->
<img src="dashboard.jpg" alt="dashboard analytics metrics conversion funnel user engagement MyApp best software" /> <!-- Keyword stuffed -->
<img src="dashboard.jpg" alt="" /> <!-- Empty when image is content -->

<!-- Contextual images (decorative) can have empty alt -->
<img src="decorative-wave.svg" alt="" role="presentation" />

<!-- Structured data for images -->
<figure>
  <img src="product.jpg" alt="MacBook Pro 16-inch in Space Gray" />
  <figcaption>MacBook Pro 16 with M3 Max chip</figcaption>
</figure>
```

### 10.2 Image Sitemap

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
  <url>
    <loc>https://www.myapp.com/blog/react-performance</loc>
    <image:image>
      <image:loc>https://www.myapp.com/images/react-performance-hero.jpg</image:loc>
      <image:title>React Performance Optimization Guide</image:title>
      <image:caption>Learn how to optimize React applications with code splitting and lazy loading</image:caption>
    </image:image>
  </url>
</urlset>
```

---

## 11. Social Sharing

### 11.1 Dynamic Meta Tags

```tsx
// components/SEO.tsx
interface SEOProps {
  title: string;
  description: string;
  image?: string;
  type?: 'website' | 'article' | 'product';
  publishedAt?: string;
  modifiedAt?: string;
  author?: string;
  tags?: string[];
}

export function SEO({
  title,
  description,
  image = '/default-og.jpg',
  type = 'website',
  publishedAt,
  modifiedAt,
  author,
  tags = [],
}: SEOProps) {
  const siteUrl = 'https://www.myapp.com';
  const fullImageUrl = image.startsWith('http') ? image : `${siteUrl}${image}`;
  
  return (
    <>
      {/* Basic */}
      <title>{title}</title>
      <meta name="description" content={description} />
      
      {/* Open Graph */}
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      <meta property="og:type" content={type} />
      <meta property="og:image" content={fullImageUrl} />
      <meta property="og:image:width" content="1200" />
      <meta property="og:image:height" content="630" />
      
      {/* Twitter */}
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={title} />
      <meta name="twitter:description" content={description} />
      <meta name="twitter:image" content={fullImageUrl} />
      
      {/* Article specific */}
      {type === 'article' && (
        <>
          <meta property="article:published_time" content={publishedAt} />
          <meta property="article:modified_time" content={modifiedAt} />
          <meta property="article:author" content={author} />
          {tags.map((tag) => (
            <meta key={tag} property="article:tag" content={tag} />
          ))}
        </>
      )}
    </>
  );
}
```

### 11.2 Social Share Buttons

```tsx
// components/ShareButtons.tsx
interface ShareButtonsProps {
  url: string;
  title: string;
  description: string;
}

export function ShareButtons({ url, title, description }: ShareButtonsProps) {
  const encodedUrl = encodeURIComponent(url);
  const encodedTitle = encodeURIComponent(title);
  const encodedDesc = encodeURIComponent(description);
  
  const shareLinks = {
    twitter: `https://twitter.com/intent/tweet?url=${encodedUrl}&text=${encodedTitle}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}`,
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`,
    reddit: `https://reddit.com/submit?url=${encodedUrl}&title=${encodedTitle}`,
    email: `mailto:?subject=${encodedTitle}&body=${encodedDesc}%0A%0A${encodedUrl}`,
  };
  
  return (
    <div className="share-buttons">
      <a href={shareLinks.twitter} target="_blank" rel="noopener noreferrer" aria-label="Share on Twitter">
        Twitter
      </a>
      <a href={shareLinks.facebook} target="_blank" rel="noopener noreferrer" aria-label="Share on Facebook">
        Facebook
      </a>
      <a href={shareLinks.linkedin} target="_blank" rel="noopener noreferrer" aria-label="Share on LinkedIn">
        LinkedIn
      </a>
      <a href={shareLinks.email} aria-label="Share via email">
        Email
      </a>
    </div>
  );
}

// Native Web Share API (mobile)
function NativeShareButton({ title, text, url }: { title: string; text: string; url: string }) {
  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({ title, text, url });
      } catch (err) {
        // User cancelled or share failed
      }
    }
  };
  
  if (!navigator.share) return null;
  
  return <button onClick={handleShare}>Share</button>;
}
```

---

## 12. Next.js SEO

### 12.1 Metadata API

```tsx
// app/layout.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: {
    template: '%s | MyApp',
    default: 'MyApp - Build Better Software',
  },
  description: 'MyApp helps teams build better software faster.',
  keywords: ['software', 'development', 'tools'],
  authors: [{ name: 'MyApp Team', url: 'https://myapp.com' }],
  creator: 'MyApp Inc.',
  publisher: 'MyApp Inc.',
  
  metadataBase: new URL('https://www.myapp.com'),
  alternates: {
    canonical: '/',
    languages: {
      'en': '/en',
      'de': '/de',
      'fr': '/fr',
    },
  },
  
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://www.myapp.com',
    siteName: 'MyApp',
    images: [
      {
        url: '/og-default.jpg',
        width: 1200,
        height: 630,
        alt: 'MyApp - Build Better Software',
      },
    ],
  },
  
  twitter: {
    card: 'summary_large_image',
    site: '@myapp',
    creator: '@myapp',
    images: ['/twitter-card.jpg'],
  },
  
  robots: {
    index: true,
    follow: true,
    nocache: true,
    googleBot: {
      index: true,
      follow: true,
      noimageindex: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  
  verification: {
    google: 'google-site-verification-code',
    yandex: 'yandex-verification-code',
  },
  
  icons: {
    icon: '/favicon.ico',
    shortcut: '/favicon-16x16.png',
    apple: '/apple-touch-icon.png',
    other: [
      { rel: 'mask-icon', url: '/safari-pinned-tab.svg', color: '#0f172a' },
    ],
  },
  
  manifest: '/manifest.json',
  
  category: 'software',
  
  other: {
    'msapplication-TileColor': '#0f172a',
    'msapplication-config': '/browserconfig.xml',
  },
};
```

### 12.2 Dynamic Metadata

```tsx
// app/blog/[slug]/page.tsx
import { Metadata } from 'next';
import { getPost } from '@/lib/posts';

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const post = await getPost(params.slug);
  
  if (!post) {
    return { title: 'Post Not Found' };
  }
  
  return {
    title: post.title,
    description: post.excerpt,
    authors: [{ name: post.author.name }],
    openGraph: {
      title: post.title,
      description: post.excerpt,
      type: 'article',
      publishedTime: post.publishedAt,
      modifiedTime: post.updatedAt,
      authors: [post.author.name],
      tags: post.tags,
      images: [
        {
          url: post.coverImage,
          width: 1200,
          height: 630,
          alt: post.title,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
    },
    alternates: {
      canonical: `/blog/${post.slug}`,
    },
  };
}

export default async function BlogPost({ params }: { params: { slug: string } }) {
  const post = await getPost(params.slug);
  return <article>{/* Post content */}</article>;
}
```

### 12.3 JSON-LD in Next.js

```tsx
// app/blog/[slug]/page.tsx
import { Article, WithContext } from 'schema-dts';

export default async function BlogPost({ params }: { params: { slug: string } }) {
  const post = await getPost(params.slug);
  
  const jsonLd: WithContext<Article> = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    image: post.coverImage,
    datePublished: post.publishedAt,
    dateModified: post.updatedAt,
    author: {
      '@type': 'Person',
      name: post.author.name,
      url: `https://www.myapp.com/authors/${post.author.slug}`,
    },
    publisher: {
      '@type': 'Organization',
      name: 'MyApp',
      logo: {
        '@type': 'ImageObject',
        url: 'https://www.myapp.com/logo.png',
      },
    },
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://www.myapp.com/blog/${post.slug}`,
    },
  };
  
  return (
    <article>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <h1>{post.title}</h1>
      {/* Post content */}
    </article>
  );
}
```

### 12.4 SEO Component Utility

```tsx
// components/SEOHead.tsx
import Head from 'next/head';
import { useRouter } from 'next/router';

interface SEOHeadProps {
  title: string;
  description?: string;
  image?: string;
  type?: 'website' | 'article';
  noindex?: boolean;
  canonical?: string;
}

export function SEOHead({
  title,
  description,
  image = '/default-og.jpg',
  type = 'website',
  noindex = false,
  canonical,
}: SEOHeadProps) {
  const router = useRouter();
  const siteUrl = 'https://www.myapp.com';
  const canonicalUrl = canonical ?? `${siteUrl}${router.asPath}`;
  const fullImage = image.startsWith('http') ? image : `${siteUrl}${image}`;
  
  return (
    <Head>
      <title>{title}</title>
      {description && <meta name="description" content={description} />}
      
      <link rel="canonical" href={canonicalUrl} />
      
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      <meta property="og:type" content={type} />
      <meta property="og:url" content={canonicalUrl} />
      <meta property="og:image" content={fullImage} />
      <meta property="og:image:width" content="1200" />
      <meta property="og:image:height" content="630" />
      <meta property="og:site_name" content="MyApp" />
      <meta property="og:locale" content="en_US" />
      
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:site" content="@myapp" />
      <meta name="twitter:title" content={title} />
      <meta name="twitter:description" content={description} />
      <meta name="twitter:image" content={fullImage} />
      
      {noindex && <meta name="robots" content="noindex, nofollow" />}
      
      <link rel="preconnect" href="https://fonts.googleapis.com" />
    </Head>
  );
}

// Usage in pages
export default function AboutPage() {
  return (
    <>
      <SEOHead
        title="About Us | MyApp"
        description="Learn about MyApp's mission to help developers build better software."
        image="/about-og.jpg"
      />
      <div>{/* Page content */}</div>
    </>
  );
}
```

---

## Quick Reference: SEO Checklist

### On-Page SEO
- [ ] Unique, descriptive title tags (50-60 chars)
- [ ] Compelling meta descriptions (150-160 chars)
- [ ] Canonical URL set on every page
- [ ] Semantic HTML structure (header, nav, main, article, footer)
- [ ] Single H1 per page, logical heading hierarchy
- [ ] Alt text on all meaningful images
- [ ] Internal linking between related pages
- [ ] External links to authoritative sources
- [ ] Schema.org structured data (JSON-LD)

### Technical SEO
- [ ] XML sitemap submitted to Google Search Console
- [ ] Robots.txt configured
- [ ] HTTPS enabled
- [ ] Mobile responsive
- [ ] Core Web Vitals passing
- [ ] No broken links (404s)
- [ ] Proper redirects (301 for permanent)
- [ ] Hreflang for multilingual sites
- [ ] Breadcrumb navigation
- [ ] Pagination with rel="next"/"prev"

### Social & Sharing
- [ ] Open Graph tags on all pages
- [ ] Twitter Cards configured
- [ ] OG image 1200x630px, < 8MB
- [ ] Twitter image 1200x628px or 144x144px
- [ ] Social share buttons implemented

### Monitoring
- [ ] Google Search Console connected
- [ ] Google Analytics configured
- [ ] Bing Webmaster Tools connected
- [ ] Regular crawl error checks
- [ ] Keyword ranking monitoring
- [ ] Page speed monitoring (Lighthouse CI)
