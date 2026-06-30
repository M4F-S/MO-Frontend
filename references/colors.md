# Color & Theme System Reference

> Comprehensive color palette, dark mode implementation, and theming patterns using CSS variables, Tailwind CSS, and shadcn/ui.

---

## Table of Contents

1. [Design Tokens](#1-design-tokens)
2. [CSS Variable Setup](#2-css-variable-setup)
3. [Tailwind Configuration](#3-tailwind-configuration)
4. [Dark Mode Toggle](#4-dark-mode-toggle)
5. [Semantic Color Mapping](#5-semantic-color-mapping)
6. [Gradients](#6-gradients)
7. [Glassmorphism](#7-glassmorphism)
8. [Accessibility (A11y)](#8-accessibility-a11y)

---

## 1. Design Tokens

```css
:root {
  /* Base colors */
  --primary: 240 5.9% 10%;
  --primary-foreground: 0 0% 98%;
  --secondary: 240 4.8% 95.9%;
  --secondary-foreground: 240 5.9% 10%;
  
  /* Background layers */
  --background: 0 0% 100%;
  --foreground: 240 10% 3.9%;
  --card: 0 0% 100%;
  --card-foreground: 240 10% 3.9%;
  --popover: 0 0% 100%;
  --popover-foreground: 240 10% 3.9%;
  
  /* Muted & accent */
  --muted: 240 4.8% 95.9%;
  --muted-foreground: 240 3.8% 46.1%;
  --accent: 240 4.8% 95.9%;
  --accent-foreground: 240 5.9% 10%;
  
  /* Destructive */
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 0 0% 98%;
  
  /* Border & input */
  --border: 240 5.9% 90%;
  --input: 240 5.9% 90%;
  --ring: 240 5.9% 10%;
  --radius: 0.5rem;
}
```

---

## 2. CSS Variable Setup

```css
@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
    font-feature-settings: 'rlig' 1, 'calt' 1;
  }
}

.dark {
  --background: 240 10% 3.9%;
  --foreground: 0 0% 98%;
  --card: 240 10% 3.9%;
  --card-foreground: 0 0% 98%;
  --popover: 240 10% 3.9%;
  --popover-foreground: 0 0% 98%;
  --primary: 0 0% 98%;
  --primary-foreground: 240 5.9% 10%;
  --secondary: 240 3.7% 15.9%;
  --secondary-foreground: 0 0% 98%;
  --muted: 240 3.7% 15.9%;
  --muted-foreground: 240 5% 64.9%;
  --accent: 240 3.7% 15.9%;
  --accent-foreground: 0 0% 98%;
  --destructive: 0 62.8% 30.6%;
  --destructive-foreground: 0 0% 98%;
  --border: 240 3.7% 15.9%;
  --input: 240 3.7% 15.9%;
  --ring: 240 4.9% 83.9%;
}
```

---

## 3. Tailwind Configuration

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
    },
  },
  plugins: [],
};

export default config;
```

---

## 4. Dark Mode Toggle

```tsx
// components/ThemeToggle.tsx
'use client';

import { useTheme } from 'next-themes';
import { Sun, Moon } from 'lucide-react';
import { motion } from 'framer-motion';

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
      className="relative p-2 rounded-lg hover:bg-accent"
      aria-label="Toggle theme"
    >
      <motion.div
        initial={false}
        animate={{ rotate: theme === 'dark' ? 180 : 0 }}
        transition={{ duration: 0.3 }}
      >
        {theme === 'dark' ? (
          <Sun className="h-5 w-5" />
        ) : (
          <Moon className="h-5 w-5" />
        )}
      </motion.div>
    </button>
  );
}
```

---

## 5. Semantic Color Mapping

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `background` | white | dark gray | Page background |
| `foreground` | near-black | near-white | Primary text |
| `card` | white | dark gray | Card surfaces |
| `primary` | dark | white | Buttons, links |
| `secondary` | light gray | dark gray | Secondary buttons |
| `muted` | light gray | dark gray | Subtle backgrounds |
| `accent` | light gray | dark gray | Highlights, badges |
| `destructive` | red | darker red | Errors, delete |
| `border` | light gray | medium gray | Dividers, borders |
| `ring` | dark | light | Focus states |

---

## 6. Gradients

```css
/* Aurora gradient background */
.aurora {
  background: linear-gradient(
    135deg,
    hsl(var(--primary) / 0.1) 0%,
    hsl(var(--accent) / 0.1) 50%,
    hsl(var(--secondary) / 0.1) 100%
  );
}

/* Text gradient */
.gradient-text {
  background: linear-gradient(to right, hsl(var(--primary)), hsl(var(--accent)));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
```

---

## 7. Glassmorphism

```css
.glass {
  background: hsl(var(--background) / 0.7);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid hsl(var(--border) / 0.3);
}

.glass-strong {
  background: hsl(var(--background) / 0.8);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid hsl(var(--border) / 0.4);
}
```

---

## 8. Accessibility (A11y)

- Minimum contrast ratio: 4.5:1 for normal text, 3:1 for large text
- Never rely on color alone to convey information
- Use `prefers-reduced-motion` to disable animations
- Test with browser dev tools contrast checker
- Ensure focus states are visible (`ring` color)
