# Animations & Motion Reference

> Comprehensive guide to animation patterns, timing, and motion design for frontend projects. Covers Framer Motion, GSAP, scroll animations, page transitions, micro-interactions, gesture handling, and reduced-motion accessibility.

---

## Table of Contents

1. [Framer Motion Basics](#1-framer-motion-basics)
2. [Page Transitions](#2-page-transitions)
3. [Scroll Animations](#3-scroll-animations)
4. [Micro-interactions](#4-micro-interactions)
5. [Gesture Handling](#5-gesture-handling)
6. [Stagger Effects](#6-stagger-effects)
7. [Layout Animations](#7-layout-animations)
8. [GSAP Integration](#8-gsap-integration)
9. [Reduced Motion](#9-reduced-motion)
10. [Performance Tips](#10-performance-tips)

---

## 1. Framer Motion Basics

### 1.1 Core Concepts

```tsx
import { motion, AnimatePresence } from 'framer-motion';

// Basic animated component
function FadeIn() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.5 }}
    >
      Content
    </motion.div>
  );
}

// Animated props with spring physics
function SpringAnimation() {
  return (
    <motion.div
      initial={{ scale: 0 }}
      animate={{ scale: 1 }}
      transition={{ type: 'spring', stiffness: 260, damping: 20 }}
    >
      Spring!
    </motion.div>
  );
}

// Keyframes
function Keyframes() {
  return (
    <motion.div
      animate={{
        scale: [1, 1.2, 1],
        rotate: [0, 90, 0],
        borderRadius: ['0%', '50%', '0%'],
      }}
      transition={{ duration: 2, repeat: Infinity }}
    />
  );
}
```

### 1.2 Variants

```tsx
// Define animation variants for cleaner code
const container = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.3,
    },
  },
};

const item = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

function StaggerList() {
  return (
    <motion.ul
      variants={container}
      initial="hidden"
      animate="visible"
    >
      {items.map((i) => (
        <motion.li key={i} variants={item}>
          {i}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

### 1.3 whileHover / whileTap / whileDrag

```tsx
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  whileDrag={{ scale: 1.1 }}
  drag
>
  Click me
</motion.button>
```

---

## 2. Page Transitions

### 2.1 AnimatePresence for exit animations

```tsx
import { AnimatePresence, motion } from 'framer-motion';
import { useState } from 'react';

function PageTransition() {
  const [page, setPage] = useState(0);

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={page}
        initial={{ opacity: 0, x: 100 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -100 }}
        transition={{ duration: 0.3 }}
      >
        {content}
      </motion.div>
    </AnimatePresence>
  );
}
```

### 2.2 Next.js App Router Page Transitions

```tsx
// app/template.tsx
'use client';

import { motion } from 'framer-motion';

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.4, ease: 'easeInOut' }}
    >
      {children}
    </motion.div>
  );
}
```

---

## 3. Scroll Animations

### 3.1 useScroll + useTransform

```tsx
import { motion, useScroll, useTransform } from 'framer-motion';

function Parallax() {
  const { scrollYProgress } = useScroll();
  const y = useTransform(scrollYProgress, [0, 1], ['0%', '100%']);

  return (
    <motion.div
      style={{ y }}
      className="fixed inset-0 -z-10"
    >
      Background
    </motion.div>
  );
}
```

### 3.2 Scroll-triggered reveals

```tsx
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

function RevealOnScroll() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 50 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 50 }}
      transition={{ duration: 0.6 }}
    >
      Content
    </motion.div>
  );
}
```

---

## 4. Micro-interactions

### 4.1 Button hover states

```tsx
<motion.button
  className="relative px-6 py-3 rounded-lg bg-primary"
  whileHover={{
    scale: 1.02,
    boxShadow: '0 10px 20px rgba(0,0,0,0.1)',
  }}
  whileTap={{ scale: 0.98 }}
  transition={{ type: 'spring', stiffness: 400, damping: 17 }}
>
  Hover me
</motion.button>
```

### 4.2 Loading states

```tsx
<motion.div
  animate={{ rotate: 360 }}
  transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
  className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full"
/>
```

---

## 5. Gesture Handling

### 5.1 Drag with constraints

```tsx
<motion.div
  drag
  dragConstraints={{ left: 0, right: 0, top: 0, bottom: 0 }}
  dragElastic={0.2}
  whileDrag={{ scale: 1.1 }}
>
  Draggable
</motion.div>
```

### 5.2 Swipe to dismiss

```tsx
<motion.div
  drag="x"
  dragConstraints={{ left: 0, right: 0 }}
  onDragEnd={(e, info) => {
    if (info.offset.x > 100) {
      // Swiped right
    } else if (info.offset.x < -100) {
      // Swiped left
    }
  }}
/>
```

---

## 6. Stagger Effects

```tsx
const parent = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.05,
      delayChildren: 0.1,
    },
  },
};

const child = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

function StaggerGrid() {
  return (
    <motion.div
      variants={parent}
      initial="hidden"
      animate="visible"
      className="grid grid-cols-3 gap-4"
    >
      {items.map((item) => (
        <motion.div key={item} variants={child}>
          {item}
        </motion.div>
      ))}
    </motion.div>
  );
}
```

---

## 7. Layout Animations

```tsx
import { motion, LayoutGroup } from 'framer-motion';

// Automatic layout animations
<motion.div layout transition={{ type: 'spring', stiffness: 300, damping: 30 }}>
  Content that changes size
</motion.div>

// LayoutGroup for shared layout
<LayoutGroup>
  <motion.div layoutId="card" />
  <motion.div layoutId="card" />
</LayoutGroup>
```

---

## 8. GSAP Integration

```tsx
import { useRef, useEffect } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

function GSAPScroll() {
  const ref = useRef(null);

  useEffect(() => {
    const el = ref.current;
    gsap.from(el, {
      scrollTrigger: {
        trigger: el,
        start: 'top 80%',
      },
      y: 50,
      opacity: 0,
      duration: 1,
    });
  }, []);

  return <div ref={ref}>Content</div>;
}
```

---

## 9. Reduced Motion

```tsx
import { useReducedMotion } from 'framer-motion';

function AccessibleAnimation() {
  const shouldReduceMotion = useReducedMotion();

  return (
    <motion.div
      animate={shouldReduceMotion ? {} : { scale: 1.2 }}
    >
      Respects user preferences
    </motion.div>
  );
}
```

---

## 10. Performance Tips

- Use `will-change: transform` sparingly
- Prefer `transform` and `opacity` animations (GPU-accelerated)
- Avoid animating `width`, `height`, `top`, `left` (layout thrashing)
- Use `layout` prop only when necessary
- Lazy load animation libraries with dynamic imports
- Use `transform: translateZ(0)` or `translate3d` for hardware acceleration
- Debounce resize events
- Use CSS `animation` for simple infinite animations instead of JS
