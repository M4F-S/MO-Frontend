# Visual Effects & CSS Patterns

> Advanced CSS effects, backdrop filters, gradients, animations, and modern visual techniques for premium UI design.

---

## Table of Contents

1. [Backdrop Filters](#1-backdrop-filters)
2. [Gradient Patterns](#2-gradient-patterns)
3. [Shadow Effects](#3-shadow-effects)
4. [Border Effects](#4-border-effects)
5. [Noise & Texture](#5-noise--texture)
6. [Animated Backgrounds](#6-animated-backgrounds)
7. [Text Effects](#7-text-effects)
8. [3D Transforms](#8-3d-transforms)
9. [Clip Path](#9-clip-path)
10. [Masking](#10-masking)

---

## 1. Backdrop Filters

```css
/* Standard glassmorphism */
.glass {
  background: hsl(var(--background) / 0.7);
  backdrop-filter: blur(12px) saturate(180%);
  -webkit-backdrop-filter: blur(12px) saturate(180%);
  border: 1px solid hsl(var(--border) / 0.2);
}

/* Stronger glass */
.glass-strong {
  background: hsl(var(--background) / 0.8);
  backdrop-filter: blur(24px) saturate(200%) brightness(1.1);
  -webkit-backdrop-filter: blur(24px) saturate(200%) brightness(1.1);
  border: 1px solid hsl(var(--border) / 0.3);
}

/* Frosted navbar */
.nav-glass {
  background: linear-gradient(
    to bottom,
    hsl(var(--background) / 0.9) 0%,
    hsl(var(--background) / 0.7) 100%
  );
  backdrop-filter: blur(16px);
  border-bottom: 1px solid hsl(var(--border) / 0.1);
}
```

---

## 2. Gradient Patterns

```css
/* Aurora background */
.aurora-bg {
  background: radial-gradient(
      ellipse at top,
      hsl(var(--primary) / 0.15) 0%,
      transparent 50%
    ),
    radial-gradient(
      ellipse at bottom,
      hsl(var(--accent) / 0.15) 0%,
      transparent 50%
    );
}

/* Mesh gradient */
.mesh-gradient {
  background: 
    radial-gradient(at 40% 20%, hsl(var(--primary) / 0.2) 0px, transparent 50%),
    radial-gradient(at 80% 0%, hsl(var(--accent) / 0.2) 0px, transparent 50%),
    radial-gradient(at 0% 50%, hsl(var(--secondary) / 0.2) 0px, transparent 50%),
    radial-gradient(at 80% 50%, hsl(var(--primary) / 0.2) 0px, transparent 50%),
    radial-gradient(at 0% 100%, hsl(var(--accent) / 0.2) 0px, transparent 50%);
}

/* Gradient text */
.gradient-text {
  background: linear-gradient(135deg, hsl(var(--primary)), hsl(var(--accent)));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* Animated gradient border */
@keyframes gradient-rotate {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.animated-border {
  background: linear-gradient(90deg, #ff00cc, #3333ff, #ff00cc);
  background-size: 200% 200%;
  animation: gradient-rotate 3s ease infinite;
  padding: 2px;
  border-radius: inherit;
}
```

---

## 3. Shadow Effects

```css
/* Soft shadow */
.shadow-soft {
  box-shadow: 0 2px 15px -3px hsl(var(--foreground) / 0.08),
    0 4px 6px -4px hsl(var(--foreground) / 0.05);
}

/* Glow shadow */
.shadow-glow {
  box-shadow: 0 0 20px hsl(var(--primary) / 0.3),
    0 0 40px hsl(var(--primary) / 0.1);
}

/* Inner glow */
.shadow-inner-glow {
  box-shadow: inset 0 0 20px hsl(var(--primary) / 0.1);
}

/* Layered shadow */
.shadow-layered {
  box-shadow: 
    0 1px 2px hsl(var(--foreground) / 0.05),
    0 4px 8px hsl(var(--foreground) / 0.05),
    0 8px 16px hsl(var(--foreground) / 0.05),
    0 16px 32px hsl(var(--foreground) / 0.05);
}
```

---

## 4. Border Effects

```css
/* Gradient border */
.gradient-border {
  position: relative;
  border-radius: 0.5rem;
}

.gradient-border::before {
  content: '';
  position: absolute;
  inset: 0;
  padding: 1px;
  border-radius: inherit;
  background: linear-gradient(135deg, hsl(var(--primary)), hsl(var(--accent)));
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
}

/* Dashed border animation */
@keyframes dash {
  to { stroke-dashoffset: 0; }
}

.animated-dash {
  stroke-dasharray: 1000;
  stroke-dashoffset: 1000;
  animation: dash 2s linear forwards;
}
```

---

## 5. Noise & Texture

```css
/* SVG noise overlay */
.noise-overlay::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
  opacity: 0.03;
  pointer-events: none;
  mix-blend-mode: overlay;
}

/* Dot pattern */
.dot-pattern {
  background-image: radial-gradient(hsl(var(--border)) 1px, transparent 1px);
  background-size: 20px 20px;
}

/* Grid pattern */
.grid-pattern {
  background-image: 
    linear-gradient(hsl(var(--border) / 0.3) 1px, transparent 1px),
    linear-gradient(90deg, hsl(var(--border) / 0.3) 1px, transparent 1px);
  background-size: 40px 40px;
}
```

---

## 6. Animated Backgrounds

```css
/* Moving gradient */
@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.moving-gradient {
  background: linear-gradient(
    -45deg,
    hsl(var(--primary) / 0.2),
    hsl(var(--accent) / 0.2),
    hsl(var(--secondary) / 0.2)
  );
  background-size: 400% 400%;
  animation: gradient-shift 15s ease infinite;
}

/* Floating orbs */
@keyframes float {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
}

.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.5;
  animation: float 20s ease-in-out infinite;
}
```

---

## 7. Text Effects

```css
/* Gradient text */
.gradient-text {
  background: linear-gradient(135deg, hsl(var(--primary)), hsl(var(--accent)));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Text shadow glow */
.text-glow {
  text-shadow: 0 0 20px hsl(var(--primary) / 0.5);
}

/* Underline animation */
.animated-underline {
  position: relative;
}

.animated-underline::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 2px;
  background: hsl(var(--primary));
  transition: width 0.3s ease;
}

.animated-underline:hover::after {
  width: 100%;
}

/* Typing effect */
@keyframes typing {
  from { width: 0; }
  to { width: 100%; }
}

.typing {
  overflow: hidden;
  white-space: nowrap;
  animation: typing 3s steps(40, end);
}
```

---

## 8. 3D Transforms

```css
/* 3D card flip */
.perspective-1000 {
  perspective: 1000px;
}

.card-3d {
  transform-style: preserve-3d;
  transition: transform 0.6s;
}

.card-3d:hover {
  transform: rotateY(10deg) rotateX(5deg);
}

/* Perspective container */
.perspective-container {
  perspective: 1000px;
  transform-style: preserve-3d;
}

/* 3D transform on hover */
.hover-3d {
  transition: transform 0.3s ease;
}

.hover-3d:hover {
  transform: translateZ(20px) rotateX(5deg) rotateY(5deg);
}
```

---

## 9. Clip Path

```css
/* Diagonal section */
.diagonal-section {
  clip-path: polygon(0 0, 100% 5%, 100% 100%, 0 95%);
}

/* Circle mask */
.circle-mask {
  clip-path: circle(50% at 50% 50%);
}

/* Hexagon */
.hexagon {
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
}

/* Wave shape */
.wave-bottom {
  clip-path: polygon(
    0 0,
    100% 0,
    100% 85%,
    50% 100%,
    0 85%
  );
}
```

---

## 10. Masking

```css
/* Gradient mask */
.fade-mask {
  -webkit-mask-image: linear-gradient(to bottom, black 80%, transparent 100%);
  mask-image: linear-gradient(to bottom, black 80%, transparent 100%);
}

/* Image mask */
.image-mask {
  -webkit-mask-image: url('mask.svg');
  mask-image: url('mask.svg');
  -webkit-mask-size: cover;
  mask-size: cover;
}

/* Radial mask */
.radial-mask {
  -webkit-mask-image: radial-gradient(circle, black 50%, transparent 100%);
  mask-image: radial-gradient(circle, black 50%, transparent 100%);
}
```
