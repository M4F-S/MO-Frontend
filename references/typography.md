# Typography System Reference

> Comprehensive typography system for frontend projects using Tailwind CSS, CSS variables, and modern font loading strategies.

---

## Table of Contents

1. [Font Loading](#1-font-loading)
2. [Type Scale](#2-type-scale)
3. [Tailwind Configuration](#3-tailwind-configuration)
4. [CSS Variable Setup](#4-css-variable-setup)
5. [Component Patterns](#5-component-patterns)
6. [Responsive Typography](#6-responsive-typography)
7. [Variable Fonts](#7-variable-fonts)
8. [Font Metrics](#8-font-metrics)
9. [Accessibility](#9-accessibility)

---

## 1. Font Loading

### Next.js Font Optimization

```tsx
// app/layout.tsx
import { GeistSans } from 'geist/font/sans';
import { GeistMono } from 'geist/font/mono';
import { Inter } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="font-sans">{children}</body>
    </html>
  );
}
```

### Manual @font-face

```css
@font-face {
  font-family: 'Geist Sans';
  src: url('/fonts/GeistSans.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
  font-style: normal;
}

@font-face {
  font-family: 'Geist Mono';
  src: url('/fonts/GeistMono.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
  font-style: normal;
}
```

---

## 2. Type Scale

```css
/* CSS Variables for type scale */
:root {
  --font-size-xs: 0.75rem;      /* 12px */
  --font-size-sm: 0.875rem;     /* 14px */
  --font-size-base: 1rem;       /* 16px */
  --font-size-lg: 1.125rem;   /* 18px */
  --font-size-xl: 1.25rem;    /* 20px */
  --font-size-2xl: 1.5rem;    /* 24px */
  --font-size-3xl: 1.875rem;  /* 30px */
  --font-size-4xl: 2.25rem;   /* 36px */
  --font-size-5xl: 3rem;      /* 48px */
  --font-size-6xl: 3.75rem;    /* 60px */
  --font-size-7xl: 4.5rem;     /* 72px */
  
  --line-height-tight: 1.25;
  --line-height-snug: 1.375;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.625;
  --line-height-loose: 2;
  
  --letter-spacing-tight: -0.025em;
  --letter-spacing-normal: 0;
  --letter-spacing-wide: 0.025em;
  --letter-spacing-wider: 0.05em;
}
```

---

## 3. Tailwind Configuration

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'system-ui', 'sans-serif'],
        mono: ['var(--font-geist-mono)', 'monospace'],
      },
      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '1.4' }],
      },
      letterSpacing: {
        tighter: '-0.05em',
      },
      lineHeight: {
        'extra-tight': '1.1',
      },
    },
  },
};

export default config;
```

---

## 4. CSS Variable Setup

```css
@layer base {
  :root {
    --font-sans: var(--font-geist-sans), system-ui, -apple-system, sans-serif;
    --font-mono: var(--font-geist-mono), ui-monospace, monospace;
  }
  
  body {
    font-family: var(--font-sans);
    font-size: var(--font-size-base);
    line-height: var(--line-height-normal);
    color: hsl(var(--foreground));
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }
  
  h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    letter-spacing: var(--letter-spacing-tight);
    line-height: var(--line-height-tight);
  }
  
  h1 { font-size: var(--font-size-5xl); }
  h2 { font-size: var(--font-size-4xl); }
  h3 { font-size: var(--font-size-3xl); }
  h4 { font-size: var(--font-size-2xl); }
  h5 { font-size: var(--font-size-xl); }
  h6 { font-size: var(--font-size-lg); }
  
  code, pre {
    font-family: var(--font-mono);
  }
}
```

---

## 5. Component Patterns

```tsx
// Typography components with semantic meaning
import { cn } from '@/lib/utils';

interface HeadingProps {
  as?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';
  size?: 'xl' | 'lg' | 'md' | 'sm' | 'xs';
  children: React.ReactNode;
  className?: string;
}

export function Heading({
  as: Tag = 'h2',
  size = 'lg',
  children,
  className,
}: HeadingProps) {
  const sizeClasses = {
    xl: 'text-5xl font-bold tracking-tight',
    lg: 'text-4xl font-semibold tracking-tight',
    md: 'text-3xl font-semibold tracking-tight',
    sm: 'text-2xl font-semibold tracking-tight',
    xs: 'text-xl font-semibold tracking-tight',
  };

  return (
    <Tag className={cn(sizeClasses[size], className)}>
      {children}
    </Tag>
  );
}

export function Text({
  as: Tag = 'p',
  size = 'base',
  color = 'default',
  children,
  className,
}: {
  as?: 'p' | 'span' | 'div';
  size?: 'xs' | 'sm' | 'base' | 'lg';
  color?: 'default' | 'muted' | 'primary';
  children: React.ReactNode;
  className?: string;
}) {
  const sizeClasses = {
    xs: 'text-xs',
    sm: 'text-sm',
    base: 'text-base',
    lg: 'text-lg',
  };

  const colorClasses = {
    default: 'text-foreground',
    muted: 'text-muted-foreground',
    primary: 'text-primary',
  };

  return (
    <Tag className={cn(sizeClasses[size], colorClasses[color], className)}>
      {children}
    </Tag>
  );
}
```

---

## 6. Responsive Typography

```css
/* Fluid typography using clamp() */
.fluid-heading {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  line-height: 1.1;
}

.fluid-body {
  font-size: clamp(1rem, 1vw + 0.5rem, 1.25rem);
  line-height: 1.6;
}

/* Tailwind responsive classes */
/* text-sm md:text-base lg:text-lg */
```

---

## 7. Variable Fonts

```css
/* Single file for all weights */
@font-face {
  font-family: 'Inter Var';
  src: url('/fonts/Inter-Variable.woff2') format('woff2-variations');
  font-weight: 100 900;
  font-display: swap;
}

/* Usage */
.variable-font {
  font-family: 'Inter Var', sans-serif;
  font-weight: 450; /* Any value between 100-900 */
  font-variation-settings: 'wght' 450, 'slnt' 0;
}
```

---

## 8. Font Metrics

```css
/* Optimize font rendering */
.optimize-text {
  text-rendering: optimizeLegibility;
  font-feature-settings: 'kern' 1, 'liga' 1, 'calt' 1;
}

/* Tabular numbers for data */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}

/* Fractions */
.fractions {
  font-variant-numeric: diagonal-fractions;
}

/* Small caps */
.small-caps {
  font-variant-caps: small-caps;
}
```

---

## 9. Accessibility

- Minimum font size: 16px (prevents iOS zoom on input focus)
- Line height: 1.5 for body text, 1.25 for headings
- Ensure sufficient color contrast (4.5:1 minimum)
- Use `rem` units for scalability
- Allow browser zoom (never disable `user-scalable`)
- Use `font-display: swap` to prevent invisible text during load
- Respect `prefers-reduced-motion` for animated text
