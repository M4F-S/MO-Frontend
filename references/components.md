# Component Patterns & UI Architecture

> Reusable UI component patterns, composition strategies, and architectural decisions for scalable frontend projects.

---

## Table of Contents

1. [Component Composition](#1-component-composition)
2. [Polymorphic Components](#2-polymorphic-components)
3. [Compound Components](#3-compound-components)
4. [Render Props](#4-render-props)
5. [Controlled vs Uncontrolled](#5-controlled-vs-uncontrolled)
6. [Slot Pattern](#6-slot-pattern)
7. [Higher-Order Components](#7-higher-order-components)
8. [Custom Hooks](#8-custom-hooks)
9. [Error Boundaries](#9-error-boundaries)
10. [Suspense Boundaries](#10-suspense-boundaries)

---

## 1. Component Composition

```tsx
// Prefer composition over configuration
// Bad: <Button icon="arrow" iconPosition="right" />
// Good: <Button><Icon /><Text /></Button>

function Card({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={cn('rounded-lg border bg-card p-4', className)}>
      {children}
    </div>
  );
}

// Usage
<Card>
  <CardHeader>Title</CardHeader>
  <CardContent>Body</CardContent>
  <CardFooter>Actions</CardFooter>
</Card>
```

---

## 2. Polymorphic Components

```tsx
import { ElementRef, forwardRef, ComponentPropsWithoutRef } from 'react';
import { cn } from '@/lib/utils';

const Heading = forwardRef<
  ElementRef<'h2'>,
  ComponentPropsWithoutRef<'h2'> & { as?: 'h1' | 'h2' | 'h3' }
>(({ as: Tag = 'h2', className, ...props }, ref) => (
  <Tag
    ref={ref}
    className={cn('font-bold tracking-tight', className)}
    {...props}
  />
));

Heading.displayName = 'Heading';
```

---

## 3. Compound Components

```tsx
// Tabs compound component pattern
const TabsContext = createContext<{
  activeTab: string;
  setActiveTab: (id: string) => void;
} | null>(null);

function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = function TabList({ children }: { children: React.ReactNode }) {
  return <div className="tab-list" role="tablist">{children}</div>;
};

Tabs.Trigger = function TabTrigger({ id, children }: { id: string; children: React.ReactNode }) {
  const ctx = useContext(TabsContext);
  return (
    <button
      role="tab"
      aria-selected={ctx?.activeTab === id}
      onClick={() => ctx?.setActiveTab(id)}
    >
      {children}
    </button>
  );
};

Tabs.Content = function TabContent({ id, children }: { id: string; children: React.ReactNode }) {
  const ctx = useContext(TabsContext);
  if (ctx?.activeTab !== id) return null;
  return <div role="tabpanel">{children}</div>;
};
```

---

## 4. Render Props

```tsx
// Flexible list component with render prop
function DataList<T>({
  items,
  renderItem,
  keyExtractor,
}: {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
}) {
  return (
    <ul className="space-y-2">
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>{renderItem(item, index)}</li>
      ))}
    </ul>
  );
}

// Usage
<DataList
  items={users}
  keyExtractor={(u) => u.id}
  renderItem={(user) => (
    <div className="flex items-center gap-2">
      <Avatar src={user.avatar} />
      <span>{user.name}</span>
    </div>
  )}
/>
```

---

## 5. Controlled vs Uncontrolled

```tsx
// Controlled: Parent owns state
function ControlledInput({ value, onChange }: { value: string; onChange: (v: string) => void }) {
  return <input value={value} onChange={(e) => onChange(e.target.value)} />;
}

// Uncontrolled: Component owns state
function UncontrolledInput({ defaultValue = '' }: { defaultValue?: string }) {
  const [value, setValue] = useState(defaultValue);
  return <input value={value} onChange={(e) => setValue(e.target.value)} />;
}

// Hybrid: Support both modes
function HybridInput({
  value,
  defaultValue,
  onChange,
}: {
  value?: string;
  defaultValue?: string;
  onChange?: (v: string) => void;
}) {
  const isControlled = value !== undefined;
  const [internalValue, setInternalValue] = useState(defaultValue ?? '');
  const currentValue = isControlled ? value : internalValue;

  return (
    <input
      value={currentValue}
      onChange={(e) => {
        if (!isControlled) setInternalValue(e.target.value);
        onChange?.(e.target.value);
      }}
    />
  );
}
```

---

## 6. Slot Pattern

```tsx
// Using Radix Slot for polymorphic behavior
import { Slot } from '@radix-ui/react-slot';

interface ButtonProps extends React.ComponentProps<'button'> {
  asChild?: boolean;
}

function Button({ asChild, className, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : 'button';
  return <Comp className={cn('btn', className)} {...props} />;
}

// Usage
<Button asChild>
  <Link href="/dashboard">Dashboard</Link>
</Button>
```

---

## 7. Higher-Order Components

```tsx
// Use sparingly - prefer hooks or composition
function withAuth<P extends object>(
  Component: React.ComponentType<P>
): React.FC<Omit<P, 'user'> & { fallback?: React.ReactNode }> {
  return function WithAuth({ fallback, ...props }) {
    const user = useAuth();
    if (!user) return fallback ?? <LoginPrompt />;
    return <Component {...(props as P)} user={user} />;
  };
}

// Usage
const Dashboard = withAuth(DashboardPage);
```

---

## 8. Custom Hooks

```tsx
// Encapsulate reusable logic
function useDebounce<T>(value: T, delay: number = 500): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debounced;
}

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false);

  useEffect(() => {
    const media = window.matchMedia(query);
    const update = () => setMatches(media.matches);
    update();
    media.addEventListener('change', update);
    return () => media.removeEventListener('change', update);
  }, [query]);

  return matches;
}

function useLocalStorage<T>(key: string, initial: T): [T, (v: T) => void] {
  const [value, setValue] = useState(() => {
    if (typeof window === 'undefined') return initial;
    try {
      return JSON.parse(localStorage.getItem(key) ?? 'null') ?? initial;
    } catch {
      return initial;
    }
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue];
}
```

---

## 9. Error Boundaries

```tsx
'use client';

import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div className="p-4 text-red-500">
          <h2>Something went wrong</h2>
          <details className="mt-2 text-sm">
            <summary>Error details</summary>
            <pre>{this.state.error?.message}</pre>
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}
```

---

## 10. Suspense Boundaries

```tsx
// Loading fallbacks
function LoadingFallback() {
  return (
    <div className="animate-pulse space-y-2">
      <div className="h-4 bg-muted rounded w-3/4" />
      <div className="h-4 bg-muted rounded w-1/2" />
    </div>
  );
}

// Usage with React.lazy
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <HeavyComponent />
    </Suspense>
  );
}

// With Next.js
import { Suspense } from 'react';

export default function Page() {
  return (
    <div>
      <Header /> {/* Static */}
      <Suspense fallback={<LoadingFallback />}>
        <DynamicContent /> {/* Fetched */}
      </Suspense>
    </div>
  );
}
```
