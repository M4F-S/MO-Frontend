---
name: MO-Frontend
description: Expert frontend design skill for premium web UIs. Use when building or improving React/Next.js sites with Tailwind, Framer Motion, GSAP, shadcn/ui, glassmorphism, dark mode, scroll animations, or WebGL. Triggers on website design, landing page, dashboard, SaaS UI, portfolio, component library, or frontend development.
---

# MO-Frontend — Premium Frontend Design & Development

Expert-level guidance for designing and building breathtaking, award-quality websites and web platforms. Synthesized from deep research of VengeanceUI, ReactBits, Skiper UI, AnimMaster Lib, Magic UI, and Aceternity UI.

## What This Skill Covers

- React, Next.js, Vite, and modern frontend frameworks
- Tailwind CSS, shadcn/ui, and component-driven design
- Premium animations: Framer Motion, GSAP, WebGL, CSS
- Dark-mode-first glassmorphism, bento grids, scroll effects
- Responsive design, accessibility, performance optimization
- Full-stack coordination: API integration, auth, state management
- SEO, Core Web Vitals, and deployment optimization

## What This Skill Does NOT Cover

- **Native mobile apps** (React Native, Flutter, Swift, Kotlin) — use a dedicated mobile skill
- **Backend development** (databases, APIs, server logic) — use `MO-Backend` skill
- **Desktop applications** (Electron, Tauri) — outside scope
- **Game development** (Unity, Unreal, WebGPU games) — outside scope
- **Legacy framework maintenance** (jQuery, Backbone, AngularJS) — outside scope
- **Browser extensions / plugins** — outside scope
- **AI/ML model deployment** — outside scope
- **DevOps / infrastructure** (Kubernetes, Terraform beyond deployment) — use `MO-Backend` skill

## Full-Stack Integration with MO-Backend

When building full-stack applications, coordinate with `MO-Backend`:

| Frontend Need | Backend Coordination | See MO-Backend |
|---------------|---------------------|----------------|
| API client setup | CORS config, API contract | `apis.md`, `frontend-integration.md` |
| Auth (JWT, OAuth) | Token endpoints, refresh flow | `auth.md` |
| Data fetching | REST/GraphQL endpoints, pagination | `apis.md`, `databases.md` |
| File uploads | Presigned URLs, S3/R2 storage | `integrations.md` |
| Real-time updates | WebSocket/SSE endpoints | `realtime.md` |
| Search | Full-text search API, pgvector | `integrations.md`, `databases.md` |
| Deployment | Monorepo, shared env vars, CI/CD | `devops.md` |

**Shared patterns:**
- Generate TypeScript types from OpenAPI or Prisma schema (`scripts/generate-shared-types.sh`)
- Use `TanStack Query` for server state + `Zustand` for client state
- Store auth tokens in `httpOnly` cookies (not `localStorage`)
- Configure CORS per environment: `localhost:3000` (dev), `*.vercel.app` (staging), `yourdomain.com` (prod)
- Deploy frontend to Vercel/Netlify, backend to Railway/Render/Fly.io — keep in same monorepo for coordination

## 5-Step Frontend Workflow

## Obsidian Memory Layer

When working on projects, persist knowledge to the Obsidian vault for cross-session recall. Coordinate with the `mo-graphify-obsidian-memory` skill.

### Vault Location
- **Per-project:** `{project-root}/obsidian/` or `~/Vaults/{project-name}/wiki/`
- **General fallback:** `~/Vaults/general/wiki/`
- Create the vault directory if it doesn't exist

### What to Store
- **Design decisions:** Component architecture, animation choices, color system, typography
- **API integration notes:** Endpoint mapping, auth flow, error handling, TanStack Query patterns
- **Component registry:** shadcn/ui components, custom components, reusable patterns
- **Performance notes:** Lighthouse scores, optimization decisions, lazy loading strategy
- **Deployment notes:** Vercel/Netlify config, env vars, CI/CD pipeline

### Note Types & Naming

| Note Type | Naming Pattern | Content |
|-----------|---------------|---------|
| **Frontend MOC** | `[[Project Name — Frontend]]` | Hub note linking all frontend decisions |
| **Design System** | `[[Project Name — Design System]]` | Colors, typography, glassmorphism spec, spacing |
| **API Integration** | `[[Project Name — Frontend API Contract]]` | Endpoint mapping, query keys, mutation patterns |
| **Component Registry** | `[[Project Name — Components]]` | shadcn/ui registry, custom components, props API |
| **Performance Log** | `[[Project Name — Performance]]` | Lighthouse scores, optimization decisions |
| **ADR** | `[[Project Name — ADR-001 Topic]]` | Architecture Decision Record (framework, library choice) |

### Linking Pattern
```markdown
<!-- In [[Project Name — Frontend]] MOC -->
## Decisions
- [[Project Name — Design System]]
- [[Project Name — Frontend API Contract]]
- [[Project Name — Components]]

## Backend Coordination
- [[Project Name — Backend]]
- [[Project Name — API Contract]]
```

### Quick Operations
```python
# Create a frontend MOC
create_moc(
    title="Project Name — Frontend",
    description="Frontend architecture and design decisions for Project Name.",
    related_notes=["Project Name — Design System", "Project Name — Frontend API Contract"]
)

# Store a design decision
create_note(
    title="Project Name — ADR-003 Animation Library",
    content="Decision: Use Framer Motion for component animations, GSAP for scroll-triggered effects.\n\nRationale: Framer Motion integrates seamlessly with React, GSAP ScrollTrigger handles complex pinned sections.\n\nStatus: accepted",
    tags=["frontend", "decision", "animation"],
    note_type="decision",
    links=["Project Name — Frontend"]
)
```

### Cross-Skill Linking
- Always link frontend MOC to backend MOC: `[[Project Name — Backend]]`
- Link API integration notes to backend API contract: `[[Project Name — API Contract]]`
- Tag all notes with `["frontend", "project-name"]` for filtering

## 5-Step Frontend Workflow

### Step 1: Setup & Configure
- Initialize project: `npx create-next-app@latest` or `npm create vite@latest`
- Install dependencies: Tailwind, Framer Motion, GSAP, shadcn/ui, Lucide icons
- Configure Tailwind: dark mode, custom colors, fonts, animations, border-radius, shadows
- Set up fonts (Geist/Inter), base styles, and CSS variables
- Add `scripts/init-nextjs-frontend.sh` for one-command scaffolding

### Step 2: Layout & Structure
- Define page structure: hero, features, pricing, testimonials, CTA, footer
- Set up responsive grid system (12-column bento grid for feature showcases)
- Build navigation: floating pill navbar or scroll-transition navbar
- Configure responsive breakpoints: mobile-first, tablet, desktop, wide
- Set up semantic HTML: `<nav>`, `<header>`, `<main>`, `<section>`, `<footer>`

### Step 3: Components & Sections
- Build reusable components using shadcn/ui registry architecture
- Implement hero section: choose effect (WebGL shader, Canvas animation, or CSS gradient)
- Build feature cards with glassmorphism: spotlight hover, border beam, tilt effects
- Add pricing tables, testimonials, testimonials, and footer
- Implement forms with react-hook-form + zod validation
- Add dark mode toggle (system-aware, persisted in localStorage)

### Step 4: Animations & Interactions
- Add scroll-triggered reveals: Framer Motion `whileInView` with stagger delays
- Implement text animations: blur entrance, shiny sweep, gradient flow, or scramble
- Add hover interactions: spotlight cards, magnetic buttons, tilt effects
- Add micro-interactions: button press, icon scale, focus rings, copy feedback
- Implement page transitions with `AnimatePresence` and `layoutId`
- Wrap all animations in `prefers-reduced-motion` media query

### Step 5: Polish & Optimize
- Test responsiveness on all breakpoints
- Run Lighthouse: target LCP < 2.5s, CLS < 0.1, INP < 200ms
- Optimize images: use Next.js `Image` component or equivalent with WebP/AVIF
- Add SEO meta tags, Open Graph, structured data, sitemap, robots.txt
- Test accessibility: keyboard navigation, screen reader labels, contrast ratios
- Add Error Boundaries and loading skeletons for all async content
- Test on Safari — it has unique `backdrop-filter` behavior
- Run `scripts/optimize-performance.sh` for automated checks

## NOT-DO Guardrails

- **Don't use microservices** for frontend architecture — frontend is always a monolith
- **Don't ignore `prefers-reduced-motion`** — always wrap animations in media query checks
- **Don't use inline styles** for complex components — use Tailwind or CSS modules
- **Don't use `!important` in Tailwind** — it indicates a design system failure
- **Don't use WebGL for critical UI** — it fails on low-end devices and mobile
- **Don't skip responsive design** — mobile-first is mandatory, not optional
- **Don't use unoptimized images** — always use Next.js Image or equivalent with WebP/AVIF
- **Don't ignore Core Web Vitals** — LCP < 2.5s, CLS < 0.1, INP < 200ms are mandatory
- **Don't skip testing on Safari** — it has unique `backdrop-filter` and `gap` behavior
- **Don't store JWT tokens in `localStorage`** — use `httpOnly` cookies (coordinated with backend)
- **Don't skip Error Boundaries** — every route and major component needs a fallback UI
- **Don't skip loading skeletons** — show skeletons for all async content, not spinners
- **Don't use `eval()` or `dangerouslySetInnerHTML`** with user input — XSS risk
- **Don't skip semantic HTML** — use `<nav>`, `<main>`, `<section>`, proper heading hierarchy
- **Don't use `display: none` for screen-reader-only content** — use `sr-only` utility class

## Design System (Quick Reference)

### Color Palette (Dark Mode Default)

```
Background Deep:    #020617 / #0F172A / #120F17 / #0a0a0a
Background Card:    #0f172a / #1E293B / rgba(18,15,23,0.45)
Accent Primary:     #A855F7 / #00d4ff / #3B82F6
Accent Secondary:   #7C3AED / #8c6cf0 / #06B6D4
Text Primary:       #ffffff / rgba(255,255,255,0.7)
Text Secondary:     #94a3b8 / rgba(255,255,255,0.5)
Text Muted:         rgba(255,255,255,0.3)
Border Subtle:      rgba(255,255,255,0.08)
Border Standard:    rgba(255,255,255,0.1)
```

### Glassmorphism Spec

```css
glass-card {
  background: rgba(18, 15, 23, 0.45);
  backdrop-filter: blur(32px) saturate(1.3);
  -webkit-backdrop-filter: blur(32px) saturate(1.3);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 14px;
  box-shadow:
    0 4px 32px rgba(0, 0, 0, 0.25),
    inset 0 0.5px 0 rgba(255, 255, 255, 0.06);
}
```

### Typography

```
Font Family:      Inter / Geist / system-ui sans-serif
Monospace:        Geist Mono / JetBrains Mono
Hero:             clamp(28px, 5.5vw, 68px) / weight 500 / line-height 1.1 / letter-spacing -0.02em
Body:             13-15px / weight 400 / line-height 1.55
Nav:              13px / weight 500 / uppercase / letter-spacing 0.04em
```

### Animation Easing

| Animation | Duration | Easing |
|-----------|----------|--------|
| Card entrance | 0.45s | `cubic-bezier(0.22, 1, 0.36, 1)` |
| Text content swap | 0.35s | `ease-out` |
| Button hover | spring | `stiffness: 500, damping: 30` |
| Border beam | 15s | `linear` infinite |
| Stagger delay | 0.05-0.1s | — |

**Signature easing:** `[0.22, 1, 0.36, 1]` — use for 80% of transitions.

## Tech Stack

### Primary Stack
```
Framework:      React 19 + Next.js (App Router)
Language:       TypeScript
Styling:        Tailwind CSS v4
Components:     shadcn/ui registry
Animations:     Framer Motion (primary) + GSAP (complex scroll)
Icons:          Lucide React
Fonts:          Geist (Vercel) or Inter
Forms:          react-hook-form + zod
State:          Zustand (client) + TanStack Query (server)
```

### Animation Library Selection
| Need | Library | Use Case |
|------|---------|----------|
| Component animations | Framer Motion | `motion.div`, `AnimatePresence`, `whileInView` |
| Scroll-triggered | GSAP + ScrollTrigger | Scrub animations, pinned sections |
| Text effects | GSAP SplitText | Per-character, per-word control |
| 3D scenes | Three.js + R3F | 3D models, post-processing |
| WebGL backgrounds | OGL | Lightweight shaders (aurora, particles) |
| Sound | Web Audio API | Subtle UI sound effects |

## State Management Patterns

### Client State (Zustand)
```typescript
import { create } from 'zustand';

interface UIStore {
  sidebarOpen: boolean;
  theme: 'dark' | 'light' | 'system';
  toggleSidebar: () => void;
  setTheme: (theme: 'dark' | 'light' | 'system') => void;
}

export const useUIStore = create<UIStore>((set) => ({
  sidebarOpen: false,
  theme: 'system',
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  setTheme: (theme) => set({ theme }),
}));
```

### Server State (TanStack Query)
```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Fetch data with caching, stale-while-revalidate, background refetch
const { data: user, isLoading, error } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => api.users.get(userId),
  staleTime: 5 * 60 * 1000, // 5 minutes
});

// Mutation with automatic cache invalidation
const queryClient = useQueryClient();
const updateUser = useMutation({
  mutationFn: (data) => api.users.update(userId, data),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['user', userId] });
  },
});
```

### Auth Token Handling (with MO-Backend coordination)
```typescript
// api-client.ts
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  withCredentials: true, // sends httpOnly cookies automatically
});

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      await api.post('/auth/refresh'); // backend handles refresh token rotation
      return api(originalRequest);
    }
    return Promise.reject(error);
  }
);
```

## API Integration Patterns

### Data Fetching with Loading & Error States
```tsx
// Use a consistent pattern for all async data
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => api.users.get(userId),
  });

  if (isLoading) return <UserProfileSkeleton />;
  if (error) return <ErrorFallback error={error} retry={() => refetch()} />;
  if (!user) return <EmptyState message="User not found" />;

  return (
    <div className="space-y-4">
      <UserCard user={user} />
      <UserOrders userId={userId} />
    </div>
  );
}
```

### Error Boundaries
```tsx
// components/ErrorBoundary.tsx
import { Component, ReactNode } from 'react';

interface Props { children: ReactNode; fallback?: ReactNode; }
interface State { hasError: boolean; error?: Error; }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };
  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }
  render() {
    if (this.state.hasError) {
      return this.props.fallback || <DefaultErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}

// Wrap routes:
<ErrorBoundary fallback={<RouteError />}>
  <UserProfile userId={id} />
</ErrorBoundary>
```

## Performance Checklist

Before shipping, verify all items:

- [ ] **Lighthouse score ≥ 90** (Performance, Accessibility, Best Practices, SEO)
- [ ] **LCP < 2.5s** — optimize images, preload critical fonts, reduce server response time
- [ ] **CLS < 0.1** — set explicit dimensions on images, avoid layout shifts during load
- [ ] **INP < 200ms** — debounce event handlers, use `will-change` sparingly, avoid forced reflows
- [ ] **Images optimized** — WebP/AVIF format, proper sizing, lazy loading for below-fold
- [ ] **Code splitting** — route-based splitting, dynamic imports for heavy components
- [ ] **Fonts optimized** — `font-display: swap`, preconnect to font CDN, subset fonts
- [ ] **Bundle analyzed** — check for duplicated dependencies, tree-shaking effectiveness
- [ ] **Cache headers** — static assets cached for 1 year, API responses with appropriate Cache-Control
- [ ] **No unused JS** — remove dead code, split vendor chunks

Run `scripts/optimize-performance.sh` for automated checks.

## Accessibility Checklist

- [ ] **Contrast:** Primary text AAA (18:1), secondary text AA Large (4.5:1)
- [ ] **Focus:** `focus-visible:ring-1` with `outline-offset-4` on all interactive elements
- [ ] **Reduced motion:** Wrap all animations in `prefers-reduced-motion` media query
- [ ] **Semantic HTML:** Proper `<nav>`, `<header>`, `<main>`, `<section>`, `<footer>`, heading hierarchy
- [ ] **ARIA:** Labels on icon buttons, `aria-expanded` on toggles, `aria-live` for dynamic content
- [ ] **Keyboard:** Tab order logical, arrow keys for carousels, Escape for modals, Enter for buttons
- [ ] **Screen reader:** Test with VoiceOver/NVDA, use `sr-only` for visual-hidden text
- [ ] **Alt text:** All images have descriptive alt text, decorative images have `alt=""`

## SEO Checklist

- [ ] **Meta tags:** Title, description, canonical, viewport on every page
- [ ] **Open Graph:** `og:title`, `og:description`, `og:image`, `og:url` for all shareable pages
- [ ] **Twitter Cards:** `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`
- [ ] **Structured data:** JSON-LD for articles, products, organizations, breadcrumbs
- [ ] **Sitemap:** Auto-generated `/sitemap.xml` with all public URLs
- [ ] **Robots.txt:** Allow public pages, block admin, API, and internal routes
- [ ] **Semantic URLs:** Clean, descriptive URLs with hyphens, not IDs or hashes
- [ ] **Performance:** Fast load times are a ranking factor — prioritize LCP and INP

## Boilerplate Scripts

```bash
# Next.js + Tailwind + Framer Motion + shadcn/ui + dark mode
bash scripts/init-nextjs-frontend.sh my-project

# Vite React + Tailwind + React Router
bash scripts/init-react-spa.sh my-project

# Run performance audit (Lighthouse + custom checks)
bash scripts/optimize-performance.sh http://localhost:3000
```

## Reference File Index

Load these as needed — never all at once:

- **references/animations.md** — Full animation technique catalog (scroll, hover, entrance, text, background, 3D, physics, SVG)
- **references/components.md** — Complete UI component pattern library (navbars, cards, buttons, forms, grids, modals, footers, data viz)
- **references/effects.md** — Visual effects taxonomy (WebGL shaders, Canvas, particles, 3D, cursor effects, glassmorphism)
- **references/colors.md** — Complete color system, gradient recipes, dark mode implementation, glassmorphism color math
- **references/typography.md** — Extended typography system, font pairing, text animation implementations
- **references/performance.md** — Core Web Vitals, Lighthouse, code splitting, image optimization, lazy loading, bundle analysis
- **references/seo.md** — Meta tags, Open Graph, structured data, sitemap, robots.txt, semantic URLs, performance SEO
- **references/testing.md** — Jest/Vitest, React Testing Library, Playwright, Cypress, mocking, coverage
- **references/api-integration.md** — Data fetching, TanStack Query, SWR, error boundaries, loading states, caching patterns
- **references/state-management.md** — Zustand, Redux, React Context, TanStack Query, server state patterns, persistence

## Quick Reference by Task

| Task | Go To | Key Pattern |
|------|-------|-------------|
| Design dark mode palette | colors.md | Background deep → card → surface → accent hierarchy |
| Build glassmorphism cards | effects.md | `blur(32px)` + `rgba(18,15,23,0.45)` + subtle border |
| Add scroll animations | animations.md | Framer Motion `whileInView` with `[0.22, 1, 0.36, 1]` easing |
| Build hero section | components.md | Choose WebGL shader, Canvas, or CSS gradient effect |
| Optimize performance | performance.md | LCP < 2.5s, CLS < 0.1, INP < 200ms |
| Add SEO meta tags | seo.md | Title + OG + structured data + sitemap + robots.txt |
| Set up data fetching | api-integration.md | TanStack Query with skeletons + error boundaries |
| Manage global state | state-management.md | Zustand (client) + TanStack Query (server) |
| Write component tests | testing.md | React Testing Library + Vitest + MSW for API mocking |
| Connect to backend | See MO-Backend | CORS + shared types + auth + env vars |
