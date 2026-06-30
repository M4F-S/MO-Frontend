# Performance Optimization Reference

> Comprehensive guide to Core Web Vitals and frontend performance optimization. Covers image optimization, code splitting, bundle analysis, font optimization, CSS/JS optimization, caching, SSR trade-offs, and measurement tools.

---

## Table of Contents

1. [Core Web Vitals](#1-core-web-vitals)
2. [Image Optimization](#2-image-optimization)
3. [Code Splitting](#3-code-splitting)
4. [Bundle Analysis](#4-bundle-analysis)
5. [Font Optimization](#5-font-optimization)
6. [CSS Optimization](#6-css-optimization)
7. [JavaScript Optimization](#7-javascript-optimization)
8. [Third-Party Script Management](#8-third-party-script-management)
9. [Caching Strategies](#9-caching-strategies)
10. [SSR vs Static Generation](#10-ssr-vs-static-generation)
11. [Performance Measurement](#11-performance-measurement)

---

## 1. Core Web Vitals

### 1.1 Definitions and Targets

| Metric | Name | Target | Description |
|--------|------|--------|-------------|
| **LCP** | Largest Contentful Paint | < 2.5s | Time until largest visible element renders |
| **CLS** | Cumulative Layout Shift | < 0.1 | Sum of unexpected layout shifts |
| **INP** | Interaction to Next Paint | < 200ms | Latency of all interactions throughout page lifecycle |
| **FCP** | First Contentful Paint | < 1.8s | Time until first text/image renders |
| **TTFB** | Time to First Byte | < 800ms | Time from request to first byte of response |

```typescript
// web-vitals library measurement
import { onLCP, onCLS, onINP, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric: { name: string; value: number; id: string }) {
  const body = JSON.stringify(metric);
  // Send to your analytics endpoint
  navigator.sendBeacon('/analytics', body);
}

onLCP(sendToAnalytics);
onCLS(sendToAnalytics);
onINP(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

### 1.2 LCP Optimization

- Preload LCP image: `<link rel="preload" as="image" href="hero.webp">`
- Use `fetchpriority="high"` on critical images
- Eliminate render-blocking resources
- Compress and optimize LCP images
- Use CDN for static assets

### 1.3 CLS Prevention

```css
/* Always set dimensions on images */
img {
  width: 100%;
  height: auto;
  aspect-ratio: 16 / 9;
}

/* Reserve space for dynamic content */
.ad-container {
  min-height: 250px;
  background: #f0f0f0;
}

/* Use font-display: swap to prevent FOIT */
@font-face {
  font-family: 'CustomFont';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: swap;
}
```

### 1.4 INP Optimization

- Break long tasks with `yieldToMain()` pattern
- Use `requestIdleCallback` for non-urgent work
- Debounce input handlers
- Use CSS `content-visibility` for off-screen content

---

## 2. Image Optimization

### 2.1 Modern Image Formats

| Format | Use Case | Notes |
|--------|----------|-------|
| **WebP** | General replacement for JPEG/PNG | ~30% smaller than JPEG, supported in all modern browsers |
| **AVIF** | Maximum compression | ~50% smaller than JPEG, limited browser support |
| **JPEG** | Fallback for older browsers | Progressive JPEG for perceived performance |
| **PNG** | Transparency, graphics | Use only when transparency needed |
| **SVG** | Icons, logos, illustrations | Scalable, often smaller than raster |

### 2.2 Lazy Loading and Responsive Images

```html
<!-- Native lazy loading -->
<img src="photo.jpg" loading="lazy" alt="Description" />

<!-- Responsive images with srcset -->
<img
  srcset="
    image-400w.jpg 400w,
    image-800w.jpg 800w,
    image-1200w.jpg 1200w
  "
  sizes="(max-width: 600px) 400px, (max-width: 1000px) 800px, 1200px"
  src="image-800w.jpg"
  alt="Description"
/>

<!-- Picture element for art direction -->
<picture>
  <source srcset="image.avif" type="image/avif" />
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="Description" loading="lazy" />
</picture>
```

### 2.3 Next.js Image Component

```tsx
import Image from 'next/image';

// Automatic optimization, lazy loading, blur placeholder
export default function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      priority // Preload for LCP images
      placeholder="blur"
      blurDataURL="data:image/jpeg;base64,..."
      sizes="(max-width: 768px) 100vw, 50vw"
    />
  );
}

// Remote image with domains configured in next.config.js
<Image
  src="https://cdn.example.com/image.jpg"
  alt="Remote image"
  width={800}
  height={400}
  unoptimized={process.env.NODE_ENV === 'development'}
/>
```

### 2.4 Image CDN Configuration

```typescript
// next.config.js
module.exports = {
  images: {
    domains: ['cdn.example.com', 'images.unsplash.com'],
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
};
```

---

## 3. Code Splitting

### 3.1 Route-Based Code Splitting

```typescript
// Next.js automatically splits by route
// pages/index.tsx -> .next/static/chunks/pages/index.js
// pages/about.tsx -> .next/static/chunks/pages/about.js

// App Router automatic splitting
// app/page.tsx -> separate chunk
// app/dashboard/page.tsx -> separate chunk
```

### 3.2 Dynamic Imports with React.lazy

```tsx
import { lazy, Suspense } from 'react';

// Lazy load heavy components
const HeavyChart = lazy(() => import('./HeavyChart'));
const AdminPanel = lazy(() => import('./AdminPanel'));

// With loading fallback
function Dashboard() {
  return (
    <Suspense fallback={<LoadingSkeleton />}>
      <HeavyChart data={chartData} />
    </Suspense>
  );
}

// Named exports with dynamic import
const NamedExport = lazy(() =>
  import('./Components').then((module) => ({ default: module.NamedExport }))
);

// Preload on hover/interaction
const handleMouseEnter = () => {
  const HeavyChartPreload = import('./HeavyChart');
};
```

### 3.3 Advanced Dynamic Import Patterns

```tsx
// Conditional loading based on feature flags
const FeatureComponent = lazy(() => {
  if (featureFlags.newDashboard) {
    return import('./NewDashboard');
  }
  return import('./OldDashboard');
});

// Loading multiple components in parallel
const [ModuleA, ModuleB] = await Promise.all([
  import('./ModuleA'),
  import('./ModuleB'),
]);

// Prefetch using React Router
import { useNavigate } from 'react-router-dom';

function ProductLink({ id }) {
  const navigate = useNavigate();
  
  return (
    <Link
      to={`/product/${id}`}
      onMouseEnter={() => {
        // Prefetch route component
        import('./ProductPage');
      }}
    >
      View Product
    </Link>
  );
}
```

### 3.4 Suspense Boundaries

```tsx
// Granular suspense boundaries
function App() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<GlobalSpinner />}>
        <Header />
        <Suspense fallback={<SidebarSkeleton />}>
          <Sidebar />
        </Suspense>
        <main>
          <Suspense fallback={<ContentSkeleton />}>
            <Outlet />
          </Suspense>
        </main>
        <Suspense fallback={null}>
          <Footer />
        </Suspense>
      </Suspense>
    </ErrorBoundary>
  );
}
```

---

## 4. Bundle Analysis

### 4.1 webpack-bundle-analyzer

```typescript
// next.config.js or webpack.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // your config
});

// Usage: ANALYZE=true npm run build
```

### 4.2 rollup-plugin-visualizer

```typescript
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    // ... other plugins
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true,
      filename: 'dist/stats.html',
    }),
  ],
});
```

### 4.3 Bundle Size Monitoring

```typescript
// budgets in angular.json or bundle-size config
{
  "budgets": [
    {
      "type": "bundle",
      "name": "main",
      "maximumWarning": "150kb",
      "maximumError": "200kb"
    },
    {
      "type": "bundle",
      "name": "vendor",
      "maximumWarning": "300kb",
      "maximumError": "400kb"
    }
  ]
}

// CI check with bundlesize
// package.json
{
  "bundlesize": [
    { "path": "./dist/*.js", "maxSize": "150 kB" }
  ]
}
```

---

## 5. Font Optimization

### 5.1 Font Display Strategy

```css
/* Font display swap prevents FOIT */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-Regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap; /* Fallback font shows immediately */
}

@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-Bold.woff2') format('woff2');
  font-weight: 700;
  font-style: normal;
  font-display: swap;
}
```

### 5.2 Preconnect and Preload

```html
<!-- Preconnect to font CDN -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />

<!-- Preload critical fonts -->
<link
  rel="preload"
  href="/fonts/Inter-Regular.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>

<!-- Google Fonts with display=swap -->
<link
  href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap"
  rel="stylesheet"
/>
```

### 5.3 Variable Fonts

```css
/* One file for multiple weights */
@font-face {
  font-family: 'Inter Var';
  src: url('/fonts/Inter-Variable.woff2') format('woff2-variations');
  font-weight: 100 900; /* Range supported */
  font-display: swap;
}

/* Usage */
body {
  font-family: 'Inter Var', sans-serif;
  font-weight: 450; /* Any value between 100-900 */
}
```

### 5.4 Font Subsetting

```bash
# Subset fonts to only needed characters
# Using glyphhanger
npx glyphhanger --subset=*.woff2 --formats=woff2 --css

# Using subset-font (Node.js)
const subsetFont = require('subset-font');
const fs = require('fs');

const fontBuffer = fs.readFileSync('Inter-Regular.woff2');
const subsetBuffer = await subsetFont(fontBuffer, 'Hello World', {
  targetFormat: 'woff2',
});
```

### 5.5 Next.js Font Optimization

```tsx
import { Inter, Roboto } from 'next/font/google';

// Automatic optimization, no layout shift
const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

const roboto = Roboto({
  weight: ['400', '700'],
  subsets: ['latin'],
  display: 'swap',
});

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={inter.className}>{children}</body>
    </html>
  );
}
```

---

## 6. CSS Optimization

### 6.1 Critical CSS

```html
<!-- Inline critical CSS in <head> -->
<style>
  /* Critical above-the-fold styles */
  :root { --primary: #0070f3; }
  body { margin: 0; font-family: system-ui; }
  .hero { min-height: 100vh; display: flex; }
</style>

<!-- Load non-critical CSS asynchronously -->
<link
  rel="preload"
  href="/non-critical.css"
  as="style"
  onload="this.onload=null;this.rel='stylesheet'"
/>
<noscript><link rel="stylesheet" href="/non-critical.css" /></noscript>
```

### 6.2 CSS Containment

```css
/* Isolate rendering for complex components */
.feed-item {
  contain: layout style paint;
  /* Or strict for maximum isolation */
  contain: strict;
}

/* Content visibility for off-screen content */
.off-screen-section {
  content-visibility: auto;
  contain-intrinsic-size: 0 500px;
}

/* Will-change for animated elements */
.animated-card {
  will-change: transform;
  transform: translateZ(0); /* Force GPU layer */
}
```

### 6.3 Unused CSS Removal

```javascript
// PurgeCSS configuration (Tailwind does this automatically)
// postcss.config.js
module.exports = {
  plugins: [
    require('@fullhuman/postcss-purgecss')({
      content: ['./src/**/*.html', './src/**/*.tsx', './src/**/*.jsx'],
      safelist: ['dark', 'light', /^modal-/],
    }),
  ],
};

// Tailwind CSS (built-in purge)
// tailwind.config.js
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx}',
    './src/components/**/*.{js,ts,jsx,tsx}',
  ],
  // Purges automatically in production
};
```

### 6.4 CSS-in-JS Optimization

```tsx
// styled-components with SSR (babel plugin)
// .babelrc
{
  "plugins": [
    ["styled-components", { "ssr": true, "displayName": true }]
  ]
}

// Linaria - zero-runtime CSS-in-JS
import { styled } from '@linaria/react';

const Title = styled.h1`
  font-size: 24px;
  color: ${(props) => props.color};
`;
// Extracts to CSS file at build time
```

---

## 7. JavaScript Optimization

### 7.1 Script Loading Strategies

```html
<!-- Normal blocking script -->
<script src="app.js"></script>

<!-- Async - download in parallel, execute when ready (may block parsing) -->
<script async src="analytics.js"></script>

<!-- Defer - download in parallel, execute after DOM parsed -->
<script defer src="app.js"></script>

<!-- Module - automatically deferred, strict mode -->
<script type="module" src="app.js"></script>

<!-- Preload critical scripts -->
<link rel="preload" href="critical.js" as="script" />

<!-- Prefetch scripts for next page -->
<link rel="prefetch" href="next-page.js" />
```

### 7.2 Module / Nomodule Pattern

```html
<!-- Modern browsers get modern bundle -->
<script type="module" src="app.modern.js"></script>

<!-- Older browsers get transpiled bundle -->
<script nomodule src="app.legacy.js"></script>
```

```typescript
// Vite configuration for dual builds
export default defineConfig({
  build: {
    target: 'esnext', // Modern build
    // Use @vitejs/plugin-legacy for legacy
    plugins: [
      legacy({
        targets: ['defaults', 'not IE 11'],
      }),
    ],
  },
});
```

### 7.3 Tree-Shaking

```typescript
// Use ES modules for tree-shaking
import { map, filter } from 'lodash-es'; // Tree-shakeable
// NOT: import _ from 'lodash'; // Imports everything

// Package.json sideEffects field
{
  "name": "my-library",
  "sideEffects": [
    "*.css",
    "*.scss",
    "./src/polyfills.ts"
  ],
  // Everything else is tree-shakeable
}

// Pure annotations for bundlers
/*#__PURE__*/ createContext(); // Can be removed if unused
```

### 7.4 Preloading and Prefetching

```tsx
// Next.js Script component with strategies
import Script from 'next/script';

// AfterInteractive (default) - load after page becomes interactive
<Script src="analytics.js" strategy="afterInteractive" />

// LazyOnload - load during idle time
<Script src="chat-widget.js" strategy="lazyOnload" />

// Worker - load in web worker (Partytown)
<Script src="fb-pixel.js" strategy="worker" />
```

---

## 8. Third-Party Script Management

### 8.1 Partytown (Web Worker)

```tsx
// next.config.js
const { withPartytown } = require('@builder.io/partytown/utils');

module.exports = withPartytown({
  // Partytown runs scripts in web worker
})({
  // your config
});

// Usage in component
import { Partytown } from '@builder.io/partytown/react';

export default function Page() {
  return (
    <>
      <Partytown forward={['dataLayer.push']} />
      <script
        src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"
        type="text/partytown"
      />
    </>
  );
}
```

### 8.2 Facade Patterns

```tsx
// Load heavy third-party only when needed
const [loadMap, setLoadMap] = useState(false);

return (
  <div>
    {!loadMap ? (
      <button onClick={() => setLoadMap(true)}>
        Load Interactive Map
      </button>
    ) : (
      <LazyMap lat={lat} lng={lng} />
    )}
  </div>
);

// YouTube facade pattern
function YouTubeFacade({ videoId }) {
  const [loadVideo, setLoadVideo] = useState(false);
  
  return loadVideo ? (
    <iframe
      src={`https://www.youtube.com/embed/${videoId}?autoplay=1`}
      allow="autoplay; encrypted-media"
    />
  ) : (
    <div
      onClick={() => setLoadVideo(true)}
      style={{ backgroundImage: `url(https://img.youtube.com/vi/${videoId}/hqdefault.jpg)` }}
    >
      <PlayButton />
    </div>
  );
}
```

---

## 9. Caching Strategies

### 9.1 Service Worker with Workbox

```typescript
// service-worker.ts
import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { StaleWhileRevalidate, CacheFirst } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';

// Precache build assets
precacheAndRoute(self.__WB_MANIFEST);

// Cache images with expiration
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  })
);

// API calls: stale while revalidate
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
  })
);
```

### 9.2 Cache-Control Headers

```http
# Static assets - immutable, long cache
Cache-Control: public, max-age=31536000, immutable

# HTML pages - no cache, always fresh
Cache-Control: public, max-age=0, must-revalidate

# API responses - stale while revalidate
Cache-Control: public, max-age=60, stale-while-revalidate=300

# Next.js static assets (handled automatically)
# /_next/static/* -> 1 year cache
# HTML -> no cache (or ISR revalidation)
```

### 9.3 Next.js ISR Caching

```tsx
// Time-based revalidation
export const revalidate = 3600; // Revalidate every hour

// On-demand revalidation
// pages/api/revalidate.ts
export default async function handler(req, res) {
  const { path, secret } = req.query;
  
  if (secret !== process.env.REVALIDATE_SECRET) {
    return res.status(401).json({ message: 'Invalid token' });
  }
  
  try {
    await res.revalidate(path);
    return res.json({ revalidated: true });
  } catch (err) {
    return res.status(500).json({ message: 'Error revalidating' });
  }
}
```

---

## 10. SSR vs Static Generation

### 10.1 Trade-offs

| Approach | Build Time | Request Time | Data Freshness | Use Case |
|----------|------------|--------------|----------------|----------|
| **SSG** | High | Low | Stale | Marketing pages, blogs, docs |
| **SSR** | Low | Higher | Fresh | Dynamic content, authenticated pages |
| **ISR** | Medium | Low | Configurable | Large e-commerce catalogs, news |
| **CSR** | Low | Variable | Real-time | Dashboards, interactive apps |

### 10.2 Next.js Implementation

```tsx
// Static Generation (SSG)
export async function generateStaticParams() {
  const posts = await fetchPosts();
  return posts.map((post) => ({ id: post.id }));
}

// Static with ISR
export const revalidate = 60;

// Server-side Rendering (SSR)
export async function getServerSideProps({ req }) {
  const data = await fetchData(req.headers.cookie);
  return { props: { data } };
}

// Client-side Rendering (CSR)
'use client';
import { useQuery } from '@tanstack/react-query';

export default function Dashboard() {
  const { data } = useQuery({ queryKey: ['dashboard'], queryFn: fetchDashboard });
  return <DashboardUI data={data} />;
}

// Streaming SSR with Suspense
export default async function Page() {
  return (
    <Suspense fallback={<Skeleton />}>
      <AsyncComponent />
    </Suspense>
  );
}
```

### 10.3 Selective Hydration

```tsx
// React 18 selective hydration
import { Suspense } from 'react';

function App() {
  return (
    <div>
      {/* Hydrates first - user interaction priority */}
      <Header />
      
      {/* Hydrates on scroll or interaction */}
      <Suspense fallback={<Loading />}>
        <Comments />
      </Suspense>
      
      {/* Low priority - hydrates last */}
      <Suspense fallback={null}>
        <FooterAnalytics />
      </Suspense>
    </div>
  );
}
```

---

## 11. Performance Measurement

### 11.1 Lighthouse CI

```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI
on: [push]
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install && npm run build
      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.12.x
          lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

# lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3000/'],
      startServerCommand: 'npm start',
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:performance': ['warn', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1800 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
      },
    },
  },
};
```

### 11.2 Web Vitals Library with Analytics

```typescript
// lib/vitals.ts
import { onCLS, onFCP, onFID, onINP, onLCP, onTTFB } from 'web-vitals';

const vitalsUrl = 'https://vitals.vercel-analytics.com/v1/vitals';

function getConnectionSpeed() {
  return (navigator as any).connection?.effectiveType ?? 'unknown';
}

export function sendToAnalytics(metric: any) {
  const body = {
    id: metric.id,
    page: window.location.pathname,
    href: window.location.href,
    event_name: metric.name,
    value: metric.value.toString(),
    speed: getConnectionSpeed(),
  };

  if (navigator.sendBeacon) {
    navigator.sendBeacon(vitalsUrl, JSON.stringify(body));
  } else {
    fetch(vitalsUrl, {
      body: JSON.stringify(body),
      method: 'POST',
      keepalive: true,
    });
  }
}

export function reportWebVitals() {
  onCLS(sendToAnalytics);
  onFCP(sendToAnalytics);
  onFID(sendToAnalytics);
  onINP(sendToAnalytics);
  onLCP(sendToAnalytics);
  onTTFB(sendToAnalytics);
}
```

### 11.3 Chrome DevTools Performance Panel

```typescript
// Performance marks and measures
// Mark key moments in app lifecycle
performance.mark('app-start');
performance.mark('data-loaded');
performance.mark('first-render');

// Create measures between marks
performance.measure('data-fetch-duration', 'app-start', 'data-loaded');
performance.measure('render-duration', 'data-loaded', 'first-render');

// Read results
const entries = performance.getEntriesByType('measure');
entries.forEach((entry) => {
  console.log(`${entry.name}: ${entry.duration}ms`);
});

// Custom element timing
// In component:
if ('PerformanceObserver' in window) {
  const observer = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      console.log('Element timing:', entry);
    }
  });
  observer.observe({ entryTypes: ['element'] });
}
// Mark element: <div elementtiming="hero-image">...</div>
```

### 11.4 Performance Budget Checklist

```typescript
// performance-budget.js
const budgets = {
  javascript: {
    initial: 150 * 1024, // 150KB
    total: 500 * 1024,   // 500KB
  },
  css: {
    initial: 50 * 1024,  // 50KB
  },
  images: {
    initial: 250 * 1024, // 250KB
  },
  fonts: {
    initial: 100 * 1024, // 100KB
  },
  thirdParty: {
    total: 200 * 1024,   // 200KB
  },
};

// Check in build script
const stats = require('./build-stats.json');
const jsSize = stats.assets
  .filter((a) => a.name.endsWith('.js'))
  .reduce((sum, a) => sum + a.size, 0);

if (jsSize > budgets.javascript.total) {
  console.error(`JS budget exceeded: ${jsSize} > ${budgets.javascript.total}`);
  process.exit(1);
}
```

---

## Quick Reference: Performance Checklist

### Before Launch
- [ ] LCP < 2.5s, CLS < 0.1, INP < 200ms
- [ ] Images optimized (WebP/AVIF), lazy loaded
- [ ] Critical CSS inlined, fonts preloaded
- [ ] JavaScript code-split, tree-shaken
- [ ] Bundle analyzed, no duplicate dependencies
- [ ] Third-party scripts managed (Partytown/facade)
- [ ] Caching headers configured
- [ ] Service worker for offline support
- [ ] Lighthouse score > 90
- [ ] Web Vitals tracking in production

### Runtime Monitoring
- [ ] Real User Monitoring (RUM) enabled
- [ ] Error tracking configured
- [ ] Performance regression alerts set
- [ ] Monthly performance audits scheduled
