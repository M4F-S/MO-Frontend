# Frontend Testing Reference

> Comprehensive guide to frontend testing patterns. Covers the testing pyramid, Vitest, React Testing Library, component testing, mocking, E2E testing, accessibility testing, coverage, flaky test prevention, and CI/CD integration.

---

## Table of Contents

1. [Testing Pyramid](#1-testing-pyramid)
2. [Vitest Setup](#2-vitest-setup)
3. [React Testing Library](#3-react-testing-library)
4. [Component Testing](#4-component-testing)
5. [Mocking](#5-mocking)
6. [E2E Testing](#6-e2e-testing)
7. [Accessibility Testing](#7-accessibility-testing)
8. [Snapshot Testing](#8-snapshot-testing)
9. [Test Coverage](#9-test-coverage)
10. [Flaky Test Prevention](#10-flaky-test-prevention)
11. [CI/CD Integration](#11-cicd-integration)

---

## 1. Testing Pyramid

### 1.1 Frontend Testing Hierarchy

```
        /\\
       /  \\\     E2E Tests (Few)     - Playwright/Cypress
      /____\\
     /      \\\   Integration Tests     - Component + API
    /________\\
   /          \\\  Unit Tests (Many)    - Pure functions, hooks, utils
  /____________\\
```

| Level | Scope | Tools | Ratio | Speed |
|-------|-------|-------|-------|-------|
| **Unit** | Functions, hooks, utilities | Vitest, Jest | ~70% | Fast (<100ms) |
| **Component** | Isolated UI components | RTL, Storybook | ~20% | Medium (<1s) |
| **Integration** | Multiple components + API | RTL + MSW | ~8% | Slow (<5s) |
| **E2E** | Full user flows | Playwright, Cypress | ~2% | Very slow (<30s) |

### 1.2 What to Test at Each Level

```typescript
// Unit: Pure logic, no UI
// src/utils/calculateTotal.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTotal } from './calculateTotal';

describe('calculateTotal', () => {
  it('calculates total with tax and discount', () => {
    const result = calculateTotal({
      items: [{ price: 100, quantity: 2 }],
      taxRate: 0.08,
      discount: 10,
    });
    expect(result).toBe(206); // (200 - 10) * 1.08
  });
});

// Component: User interaction, rendering
// src/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByRole('button', { name: /click me/i }));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});

// Integration: Component + API + routing
// src/pages/Checkout.test.tsx
// Tests full checkout flow with mocked API
```

---

## 2. Vitest Setup

### 2.1 Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  test: {
    name: 'MO-Frontend',
    globals: true, // Enable global APIs (describe, it, expect)
    environment: 'jsdom', // Simulate browser environment
    setupFiles: './src/test/setup.ts',
    include: ['src/**/*.test.{ts,tsx}'],
    exclude: ['node_modules', 'dist', '.next'],
    
    // Coverage
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      reportsDirectory: './coverage',
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 70,
        statements: 80,
      },
      exclude: [
        'src/test/**',
        'src/**/*.d.ts',
        'src/**/*.test.{ts,tsx}',
      ],
    },
    
    // Parallel execution
    pool: 'threads',
    poolOptions: {
      threads: {
        singleThread: false,
      },
    },
    
    // Retry flaky tests
    retry: process.env.CI ? 2 : 0,
    
    // Test timeout
    testTimeout: 10000,
  },
});
```

### 2.2 Test Setup File

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom/vitest'; // Extended matchers
import { cleanup } from '@testing-library/react';
import { afterEach, beforeAll, vi } from 'vitest';

// Cleanup after each test
afterEach(() => {
  cleanup();
});

// Global mocks
beforeAll(() => {
  // Mock window.matchMedia
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });

  // Mock IntersectionObserver
  const mockIntersectionObserver = vi.fn();
  mockIntersectionObserver.mockReturnValue({
    observe: () => null,
    unobserve: () => null,
    disconnect: () => null,
  });
  window.IntersectionObserver = mockIntersectionObserver;

  // Mock ResizeObserver
  window.ResizeObserver = vi.fn().mockImplementation(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  }));

  // Mock scrollTo
  window.scrollTo = vi.fn();
  
  // Mock next/navigation
  vi.mock('next/navigation', () => ({
    useRouter: () => ({
      push: vi.fn(),
      replace: vi.fn(),
      refresh: vi.fn(),
    }),
    useSearchParams: () => new URLSearchParams(),
    usePathname: () => '/',
  }));
});
```

### 2.3 Custom Matchers and Utilities

```typescript
// src/test/utils.tsx
import { render as rtlRender } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactElement } from 'react';

// Create test query client
export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: Infinity,
      },
    },
  });
}

// Custom render with providers
export function render(ui: ReactElement, options = {}) {
  const queryClient = createTestQueryClient();
  
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  
  return {
    ...rtlRender(ui, { wrapper: Wrapper, ...options }),
    queryClient,
  };
}

// Re-export everything from RTL
export * from '@testing-library/react';
export { render };
```

---

## 3. React Testing Library

### 3.1 Query Priority

```tsx
// Preferred query order (most accessible to least):
// 1. getByRole - queries by ARIA role
// 2. getByLabelText - queries by label text
// 3. getByPlaceholderText - queries by placeholder
// 4. getByText - queries by text content
// 5. getByDisplayValue - queries by form value
// 6. getByAltText - queries by alt text
// 7. getByTitle - queries by title attribute
// 8. getByTestId - queries by data-testid (last resort)

// Examples:
screen.getByRole('button', { name: /submit/i });
screen.getByRole('heading', { level: 1 });
screen.getByRole('textbox', { name: /email/i });
screen.getByLabelText(/password/i);
screen.getByTestId('user-card');

// Query variants:
// getBy* - throws if not found (use when element should exist)
// queryBy* - returns null if not found (use for conditional elements)
// findBy* - async, waits for element (use for dynamic content)
// getAllBy* - returns array (use for multiple elements)
```

### 3.2 userEvent vs fireEvent

```tsx
import userEvent from '@testing-library/user-event';

// Prefer userEvent over fireEvent - simulates real user interactions
// fireEvent.click just dispatches a click event
// userEvent.click simulates hover, mousedown, focus, mouseup, click

// Setup userEvent (required for v14+)
const user = userEvent.setup();

// Good: Using userEvent
await user.click(screen.getByRole('button'));
await user.type(screen.getByRole('textbox'), 'Hello World');
await user.clear(screen.getByRole('textbox'));
await user.selectOptions(screen.getByRole('combobox'), 'option-1');
await user.upload(screen.getByLabelText(/upload/i), file);
await user.hover(screen.getByText(/tooltip trigger/i));
await user.keyboard('{Control>}a{/Control}'); // Keyboard shortcuts

// Avoid: Using fireEvent directly
// fireEvent.click(button); // Only dispatches click event
// fireEvent.change(input, { target: { value: 'text' } }); // Bypasses typing simulation
```

### 3.3 Async Patterns

```tsx
// findBy* for elements that appear asynchronously
const submitButton = await screen.findByRole('button', { name: /submit/i });

// waitFor for assertions that need retrying
import { waitFor } from '@testing-library/react';

await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument();
});

// waitForElementToBeRemoved for loading states
import { waitForElementToBeRemoved } from '@testing-library/react';

const loading = screen.getByText(/loading/i);
await waitForElementToBeRemoved(loading);

// Testing loading -> success states
it('shows data after loading', async () => {
  render(<DataComponent />);
  
  // Loading state
  expect(screen.getByRole('status')).toBeInTheDocument();
  
  // Wait for data
  const data = await screen.findByRole('heading', { name: /results/i });
  expect(data).toBeInTheDocument();
  
  // Loading removed
  expect(screen.queryByRole('status')).not.toBeInTheDocument();
});
```

---

## 4. Component Testing

### 4.1 Isolated Component Testing

```tsx
// src/components/UserCard/UserCard.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserCard } from './UserCard';

const mockUser = {
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  avatar: 'https://example.com/avatar.jpg',
  role: 'admin',
};

describe('UserCard', () => {
  it('renders user information correctly', () => {
    render(<UserCard user={mockUser} />);
    
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByRole('img', { name: /john doe/i })).toBeInTheDocument();
    expect(screen.getByText('admin')).toHaveClass('badge-admin');
  });

  it('calls onEdit when edit button is clicked', async () => {
    const user = userEvent.setup();
    const handleEdit = vi.fn();
    
    render(<UserCard user={mockUser} onEdit={handleEdit} />);
    
    await user.click(screen.getByRole('button', { name: /edit/i }));
    expect(handleEdit).toHaveBeenCalledWith('1');
  });

  it('does not show delete button for non-admin users', () => {
    render(<UserCard user={{ ...mockUser, role: 'user' }} />);
    expect(screen.queryByRole('button', { name: /delete/i })).not.toBeInTheDocument();
  });
});
```

### 4.2 Story-Driven Testing with Storybook

```tsx
// src/components/Button/Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  component: Button,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    variant: 'primary',
    children: 'Click me',
  },
};

export const Loading: Story = {
  args: {
    ...Primary.args,
    isLoading: true,
  },
};

// Component test using Storybook stories
// src/components/Button/Button.test.tsx
import { composeStories } from '@storybook/react';
import * as stories from './Button.stories';

const { Primary, Loading } = composeStories(stories);

describe('Button', () => {
  it('renders primary story', () => {
    render(<Primary />);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('shows loading state', () => {
    render(<Loading />);
    expect(screen.getByRole('status')).toBeInTheDocument();
  });
});
```

### 4.3 Testing Custom Hooks

```tsx
// src/hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });

  it('respects initial value', () => {
    const { result } = renderHook(() => useCounter({ initial: 10 }));
    expect(result.current.count).toBe(10);
  });

  it('does not exceed max value', () => {
    const { result } = renderHook(() => useCounter({ max: 5 }));
    
    for (let i = 0; i < 10; i++) {
      act(() => result.current.increment());
    }
    
    expect(result.current.count).toBe(5);
  });
});
```

---

## 5. Mocking

### 5.1 MSW for API Mocking

```typescript
// src/test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  // GET user
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    });
  }),

  // POST create user
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '123', ...body }, { status: 201 });
  }),

  // Error response
  http.get('/api/users/404', () => {
    return HttpResponse.json({ message: 'Not found' }, { status: 404 });
  }),

  // Delayed response (test loading states)
  http.get('/api/slow', async () => {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    return HttpResponse.json({ data: 'loaded' });
  }),
];

// src/test/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// src/test/setup.ts
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### 5.2 Function Mocking with vi.fn()

```typescript
import { vi, describe, it, expect } from 'vitest';

// Basic mock function
const mockFn = vi.fn();
mockFn('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledTimes(1);

// Mock with return value
const mockReturn = vi.fn().mockReturnValue(42);
const mockResolved = vi.fn().mockResolvedValue({ data: [] });
const mockRejected = vi.fn().mockRejectedValue(new Error('Failed'));

// Mock implementation
const mockImpl = vi.fn((a: number, b: number) => a + b);
expect(mockImpl(2, 3)).toBe(5);

// Mock module
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: '1', name: 'Test' }),
  updateUser: vi.fn().mockResolvedValue({ success: true }),
}));

// Spy on existing function
const obj = { method: () => 'original' };
const spy = vi.spyOn(obj, 'method').mockReturnValue('mocked');
expect(obj.method()).toBe('mocked');
spy.mockRestore(); // Restore original

// Mock localStorage
const mockStorage = new Map<string, string>();
Object.defineProperty(window, 'localStorage', {
  value: {
    getItem: vi.fn((key: string) => mockStorage.get(key) || null),
    setItem: vi.fn((key: string, value: string) => mockStorage.set(key, value)),
    removeItem: vi.fn((key: string) => mockStorage.delete(key)),
    clear: vi.fn(() => mockStorage.clear()),
  },
  writable: true,
});
```

### 5.3 Mocking Date and Timers

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('time-dependent tests', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('tests debounce', async () => {
    const debouncedFn = vi.fn();
    const debounce = (fn: Function, ms: number) => {
      let timeout: NodeJS.Timeout;
      return (...args: any[]) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), ms);
      };
    };

    const debounced = debounce(debouncedFn, 300);
    debounced('a');
    debounced('b');
    debounced('c');

    vi.advanceTimersByTime(300);
    expect(debouncedFn).toHaveBeenCalledWith('c');
    expect(debouncedFn).toHaveBeenCalledTimes(1);
  });

  it('tests with fixed date', () => {
    const fixedDate = new Date('2024-01-15');
    vi.setSystemTime(fixedDate);
    
    expect(new Date().toISOString()).toBe('2024-01-15T00:00:00.000Z');
  });
});
```

---

## 6. E2E Testing

### 6.1 Playwright vs Cypress

| Feature | Playwright | Cypress |
|---------|------------|---------|
| Browser | Chromium, Firefox, WebKit | Chrome, Firefox, Edge |
| Speed | Faster (parallel) | Good |
| Cross-browser | Better | Limited |
| API | Modern, async | Chain-based |
| Mobile | Native support | Viewport only |
| CI | Built-in reporter | Screenshots/videos |
| Best for | Modern apps, cross-browser | Interactive debugging |

### 6.2 Playwright Page Object Model

```typescript
// e2e/pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(readonly page: Page) {
    this.emailInput = page.getByRole('textbox', { name: /email/i });
    this.passwordInput = page.getByRole('textbox', { name: /password/i });
    this.submitButton = page.getByRole('button', { name: /sign in/i });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await this.errorMessage.toHaveText(message);
  }
}

// e2e/tests/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test.describe('Login', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@example.com', 'password123');
    await expect(page).toHaveURL('/dashboard');
  });

  test('invalid credentials show error', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('wrong@example.com', 'wrong');
    await loginPage.expectError('Invalid credentials');
  });
});

// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html', { open: 'never' }], ['list']],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 12'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### 6.3 Visual Regression Testing

```typescript
// e2e/tests/visual.spec.ts
import { test, expect } from '@playwright/test';

test('homepage visual regression', async ({ page }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  
  // Screenshot comparison
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixels: 100,
    threshold: 0.2,
  });
});

// Component-level visual testing with Storybook
// .storybook/test-runner.js
import { injectAxe, checkA11y } from 'axe-playwright';

export default {
  async preRender(page) {
    await injectAxe(page);
  },
  async postRender(page) {
    await checkA11y(page, '#storybook-root');
  },
};
```

---

## 7. Accessibility Testing

### 7.1 axe-core Integration

```tsx
// src/test/axe-helper.ts
import { run } from 'axe-core';
import { page } from '@vitest/browser/context';

export async function checkA11y(container: HTMLElement = document.body) {
  const results = await run(container, {
    rules: {
      'color-contrast': { enabled: true },
      'heading-order': { enabled: true },
      'landmark-one-main': { enabled: true },
      'page-has-heading-one': { enabled: true },
    },
  });
  
  return {
    violations: results.violations,
    passes: results.passes,
  };
}

// Component test with a11y check
import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { Button } from './Button';

expect.extend(toHaveNoViolations);

describe('Button accessibility', () => {
  it('has no accessibility violations', async () => {
    const { container } = render(<Button>Click me</Button>);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('is accessible via keyboard', async () => {
    const user = userEvent.setup();
    render(<Button onClick={vi.fn()}>Click me</Button>);
    
    const button = screen.getByRole('button');
    await user.tab();
    expect(button).toHaveFocus();
    await user.keyboard('{Enter}');
    expect(handleClick).toHaveBeenCalled();
  });
});
```

### 7.2 Automated A11y Checks

```tsx
// src/components/Modal/Modal.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Modal } from './Modal';

describe('Modal', () => {
  it('traps focus within modal', async () => {
    const user = userEvent.setup();
    render(<Modal isOpen><input /><button>Submit</button></Modal>);
    
    const firstElement = screen.getByRole('textbox');
    expect(firstElement).toHaveFocus();
    
    await user.tab();
    await user.tab();
    // Should cycle back to first element
    expect(firstElement).toHaveFocus();
  });

  it('closes on Escape key', async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    render(<Modal isOpen onClose={onClose}>Content</Modal>);
    
    await user.keyboard('{Escape}');
    expect(onClose).toHaveBeenCalled();
  });

  it('has correct ARIA attributes', () => {
    render(<Modal isOpen title="Confirm">Are you sure?</Modal>);
    
    const dialog = screen.getByRole('dialog');
    expect(dialog).toHaveAttribute('aria-modal', 'true');
    expect(dialog).toHaveAttribute('aria-labelledby', expect.any(String));
  });
});
```

---

## 8. Snapshot Testing

### 8.1 When to Use Snapshots

```tsx
// Good: Component output that shouldn't change unexpectedly
// src/components/Icon/__snapshots__/Icon.test.tsx
import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { Icon } from './Icon';

describe('Icon', () => {
  it('renders all icon variants correctly', () => {
    const { container } = render(
      <>
        <Icon name="home" />
        <Icon name="user" />
        <Icon name="settings" />
      </>
    );
    expect(container).toMatchSnapshot();
  });
});

// Good: Configuration objects, error messages, utility outputs
// src/utils/formatDate.test.ts
it('formats date consistently', () => {
  expect(formatDate('2024-01-15')).toMatchSnapshot();
});

// Avoid: Dynamic data, API responses, timestamps
// Instead use explicit assertions:
expect(data).toHaveProperty('id');
expect(data.name).toBe('Expected Name');
```

### 8.2 Snapshot Update Workflow

```bash
# Review all snapshot changes before updating
npm test -- --updateSnapshots

# Update specific test snapshot
npm test -- --updateSnapshots -t "renders all icon variants"

# Inline snapshots (better for code review)
// vitest.config.ts
export default defineConfig({
  test: {
    snapshotFormat: {
      printBasicPrototype: true,
    },
  },
});
```

---

## 9. Test Coverage

### 9.1 Coverage Configuration

```typescript
// vitest.config.ts (excerpt)
{
  test: {
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'json', 'html', 'lcov'],
      reportsDirectory: './coverage',
      all: true, // Include all files, not just tested ones
      include: ['src/**/*.{ts,tsx}'],
      exclude: [
        'src/**/*.test.{ts,tsx}',
        'src/**/*.d.ts',
        'src/test/**',
        'src/**/*.stories.{ts,tsx}',
        'src/**/types.ts',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 70,
        statements: 80,
      },
    },
  },
}

// .github/workflows/test.yml (coverage reporting)
- name: Run tests with coverage
  run: npx vitest run --coverage

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
    fail_ci_if_error: true
```

### 9.2 Coverage Best Practices

```typescript
// Don't chase 100% coverage blindly - focus on:
// 1. Business logic (utils, hooks, services)
// 2. Error handling paths
// 3. Edge cases (empty arrays, null values)
// 4. User interaction flows

// Example: Test error paths
it('handles network error', async () => {
  server.use(
    http.get('/api/data', () => {
      return HttpResponse.error();
    })
  );
  
  render(<DataComponent />);
  const error = await screen.findByRole('alert');
  expect(error).toHaveTextContent(/network error/i);
});

// Example: Test edge cases
it('handles empty data gracefully', () => {
  render(<DataTable data={[]} />);
  expect(screen.getByText(/no data available/i)).toBeInTheDocument();
});
```

---

## 10. Flaky Test Prevention

### 10.1 waitFor Patterns

```tsx
// Flaky: Testing immediately after action
fireEvent.click(button);
expect(screen.getByText('Success')).toBeInTheDocument(); // May fail

// Stable: Use findBy* (wraps waitFor)
await screen.findByText('Success');

// Stable: Use waitFor for complex assertions
await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument();
});

// Flaky: Using arbitrary timeouts
await new Promise((r) => setTimeout(r, 1000));

// Stable: Use waitFor with specific condition
await waitFor(() => {
  expect(api.getData).toHaveBeenCalledTimes(1);
}, { timeout: 5000 });
```

### 10.2 Test Isolation

```typescript
// vitest.config.ts - isolate tests
{
  test: {
    isolate: true, // Default: true
    pool: 'threads', // Each test file in separate thread
    // Or pool: 'forks' for process isolation
  },
}

// Clean up after each test
describe('UserStore', () => {
  beforeEach(() => {
    useUserStore.setState({ user: null, isLoading: false });
  });

  afterEach(() => {
    cleanup();
    vi.restoreAllMocks();
  });
});

// Avoid: Shared state between tests
// Bad:
let sharedUser: User;

it('creates user', () => {
  sharedUser = createUser('John');
});

it('updates user', () => {
  // Depends on previous test! Flaky!
  updateUser(sharedUser.id, { name: 'Jane' });
});

// Good:
it('creates and updates user', () => {
  const user = createUser('John');
  updateUser(user.id, { name: 'Jane' });
  expect(user.name).toBe('Jane');
});
```

### 10.3 Fixed Timeouts and Retries

```typescript
// vitest.config.ts
{
  test: {
    testTimeout: 10000, // 10 seconds default
    hookTimeout: 10000,
    teardownTimeout: 10000,
    retry: process.env.CI ? 2 : 0, // Retry in CI
  },
}

// Mark known flaky tests
it('flaky third-party integration', async () => {
  // Test implementation
}, { retry: 3 });

// Or use test.skip for known broken tests
// Use test.todo for planned tests
```

---

## 11. CI/CD Integration

### 11.1 GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test
on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  unit:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4] # Split tests across 4 jobs
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx vitest run --shard=${{ matrix.shard }}/4 --coverage
      - uses: actions/upload-artifact@v3
        with:
          name: coverage-${{ matrix.shard }}
          path: coverage/

  e2e:
    runs-on: ubuntu-latest
    needs: unit
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/

  merge-coverage:
    runs-on: ubuntu-latest
    needs: unit
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v3
      - uses: codecov/codecov-action@v3
        with:
          directory: coverage/
          fail_ci_if_error: true
```

### 11.2 Parallel Test Execution

```typescript
// vitest.config.ts
{
  test: {
    // Sharding for CI
    shard: process.env.VITEST_SHARD
      ? parseInt(process.env.VITEST_SHARD)
      : undefined,
    
    // Parallel file execution
    pool: 'threads',
    poolOptions: {
      threads: {
        minThreads: 1,
        maxThreads: 4,
      },
    },
  },
}

// Run specific tests in parallel
// package.json
{
  "scripts": {
    "test": "vitest run",
    "test:unit": "vitest run --exclude='**/*.e2e.test.ts'",
    "test:e2e": "vitest run --include='**/*.e2e.test.ts'",
    "test:ci": "vitest run --shard=$SHARD/$TOTAL_SHARDS",
    "test:watch": "vitest"
  }
}
```

### 11.3 Test Splitting by File Pattern

```typescript
// Separate test configs for different test types
// vitest.unit.config.ts
import { defineConfig } from 'vitest/config';
export default defineConfig({
  test: {
    name: 'unit',
    include: ['src/**/*.test.{ts,tsx}'],
    exclude: ['src/**/*.e2e.test.ts', 'src/**/*.integration.test.ts'],
  },
});

// vitest.e2e.config.ts
import { defineConfig } from 'vitest/config';
export default defineConfig({
  test: {
    name: 'e2e',
    include: ['src/**/*.e2e.test.ts'],
    testTimeout: 30000,
    pool: 'forks', // Process isolation for E2E
  },
});

// Usage:
// npx vitest --config vitest.unit.config.ts
// npx vitest --config vitest.e2e.config.ts
```

---

## Quick Reference: Testing Checklist

### Writing Tests
- [ ] Test behavior, not implementation
- [ ] Use `userEvent` over `fireEvent`
- [ ] Prefer `findBy*` over `waitFor` + `getBy*`
- [ ] Test error states and edge cases
- [ ] Mock external dependencies with MSW
- [ ] Keep tests isolated and independent

### Test Quality
- [ ] Descriptive test names (it('should...'))
- [ ] Arrange-Act-Assert structure
- [ ] One assertion per test (ideally)
- [ ] No arbitrary timeouts or delays
- [ ] Clean up mocks and state after each test

### CI/CD
- [ ] Tests run in under 5 minutes
- [ ] Coverage reports generated
- [ ] Flaky tests identified and fixed
- [ ] E2E tests run on staging
- [ ] Failed tests block deployment
