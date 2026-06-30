# MO-Frontend

Expert frontend design skill for premium web UIs. Covers React, Next.js, Tailwind CSS, Framer Motion, GSAP, shadcn/ui, glassmorphism, dark mode, scroll animations, WebGL, and full-stack coordination with MO-Backend.

## What This Skill Does

MO-Frontend provides expert-level guidance for designing and building breathtaking, award-quality websites and web platforms. It includes:

- **Complete design system** — Dark-mode-first color palette, glassmorphism spec, typography system, layout patterns
- **Animation catalog** — Scroll-triggered, hover, entrance, text, background, 3D, physics, micro-interactions
- **Component library** — Navbars, hero sections, cards, buttons, forms, grids, modals, footers, data visualization
- **Full-stack bridge** — API integration, auth coordination, state management, shared types with MO-Backend
- **Performance & SEO** — Core Web Vitals, Lighthouse, image optimization, meta tags, structured data
- **Testing** — React Testing Library, Vitest, Playwright, MSW mocking
- **Boilerplate scripts** — One-command project scaffolding for Next.js and Vite React

## Installation

Copy this skill folder to your Kimi skills directory:

```bash
# Kimi Desktop / CLI
cp -r MO-Frontend ~/.kimi/skills/

# Or clone from GitHub
git clone https://github.com/M4F-S/MO-Frontend.git ~/.kimi/skills/MO-Frontend
```

## File Structure

```
MO-Frontend/
├── SKILL.md                          # Core skill instructions (workflow, design system, NOT-DO)
├── references/
│   ├── animations.md                 # Scroll, hover, entrance, text, 3D, physics animations
│   ├── components.md                 # UI component patterns (navbar, cards, buttons, forms, grids)
│   ├── effects.md                    # WebGL shaders, Canvas, particles, glassmorphism
│   ├── colors.md                     # Color system, gradients, dark mode
│   ├── typography.md                 # Font system, text animations, font pairing
│   ├── performance.md                # Core Web Vitals, Lighthouse, optimization
│   ├── seo.md                        # Meta tags, Open Graph, structured data
│   ├── testing.md                    # React Testing Library, Vitest, Playwright
│   ├── api-integration.md            # TanStack Query, error boundaries, loading states
│   └── state-management.md           # Zustand, Redux, Context, server state patterns
└── scripts/
    ├── init-nextjs-frontend.sh       # Scaffold Next.js + Tailwind + Framer Motion + shadcn/ui
    ├── init-react-spa.sh             # Scaffold Vite React + Tailwind + React Router
    └── optimize-performance.sh       # Automated Lighthouse + heuristic performance audit
```

## Quick Start

### Scaffolding a New Project

```bash
# Next.js with full design system
bash ~/.kimi/skills/MO-Frontend/scripts/init-nextjs-frontend.sh my-app

# Vite React SPA
bash ~/.kimi/skills/MO-Frontend/scripts/init-react-spa.sh my-app

# Performance audit
bash ~/.kimi/skills/MO-Frontend/scripts/optimize-performance.sh http://localhost:3000
```

### 5-Step Workflow

When building a frontend, follow this workflow:

1. **Setup & Configure** — Initialize project, install dependencies, configure Tailwind/dark mode
2. **Layout & Structure** — Define page structure, responsive grid, navigation, semantic HTML
3. **Components & Sections** — Build hero, features, cards, forms, footer with shadcn/ui
4. **Animations & Interactions** — Add scroll reveals, hover effects, text animations, micro-interactions
5. **Polish & Optimize** — Test responsive, run Lighthouse, optimize images, add SEO, test accessibility

See `SKILL.md` for the complete workflow with detailed instructions.

## Full-Stack Integration

MO-Frontend is designed to work seamlessly with [MO-Backend](https://github.com/M4F-S/MO-Backend):

| Coordination | Frontend | Backend |
|-------------|----------|---------|
| API client | TanStack Query + error boundaries | REST/GraphQL endpoints + pagination |
| Auth | `httpOnly` cookies, interceptors | JWT + refresh rotation + RBAC |
| Types | Generated from OpenAPI/Prisma | OpenAPI spec + Prisma schema |
| Real-time | SSE client / Socket.io-client | SSE endpoints / WebSocket server |
| Deployment | Vercel/Netlify | Railway/Render/Fly.io |

See `SKILL.md` → "Full-Stack Integration with MO-Backend" for detailed patterns.

## Triggers

This skill activates when you ask about:

- Website design, landing pages, dashboards, SaaS platforms
- React, Next.js, Vite, Tailwind CSS, shadcn/ui
- Framer Motion, GSAP, scroll animations, WebGL
- Glassmorphism, dark mode, bento grids, premium UI
- Frontend performance, Core Web Vitals, SEO
- Component libraries, design systems, UI/UX

## What This Skill Does NOT Cover

- Native mobile apps (React Native, Flutter)
- Backend development (use MO-Backend)
- Desktop applications (Electron, Tauri)
- Game development (Unity, Unreal)
- AI/ML model deployment
- DevOps/infrastructure (use MO-Backend)

## NOT-DO Guardrails

- Don't use microservices for frontend — frontend is always a monolith
- Don't ignore `prefers-reduced-motion` — always wrap animations
- Don't use WebGL for critical UI — fails on low-end devices
- Don't skip responsive design — mobile-first is mandatory
- Don't store JWT in `localStorage` — use `httpOnly` cookies with backend
- Don't skip Core Web Vitals — LCP < 2.5s, CLS < 0.1, INP < 200ms
- See `SKILL.md` for the complete 15-item NOT-DO list.

## Contributing

This is a personal skill. To improve it:

1. Edit files in `~/.kimi/skills/MO-Frontend/`
2. Test changes with real projects
3. Update the skill archive: `cd ~/.kimi/skills && zip -r MO-Frontend.skill MO-Frontend`
4. Push to GitHub: `git push`

## License

MIT — Use freely for personal and commercial projects.

---

*Built for Kimi AI. Synthesized from VengeanceUI, ReactBits, Skiper UI, AnimMaster Lib, Magic UI, and Aceternity UI.*
