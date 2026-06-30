# State Management Reference

> Comprehensive guide to frontend state management patterns. Covers Zustand, Redux Toolkit, React Context, server vs client state, form state, URL state, local storage, anti-patterns, normalization, and derived state.

---

## Table of Contents

1. [Zustand](#1-zustand)
2. [Redux Toolkit](#2-redux-toolkit)
3. [React Context](#3-react-context)
4. [Server State vs Client State](#4-server-state-vs-client-state)
5. [Form State](#5-form-state)
6. [URL State](#6-url-state)
7. [Local Storage State](#7-local-storage-state)
8. [Global State Anti-Patterns](#8-global-state-anti-patterns)
9. [State Normalization](#9-state-normalization)
10. [Derived State](#10-derived-state)

---

## 1. Zustand

### 1.1 Store Creation

```typescript
// stores/userStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

interface UserState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  setUser: (user: User) => void;
  updateUser: (updates: Partial<User>) => void;
  clearUser: () => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
}

export const useUserStore = create<UserState>()(
  devtools(
    immer((set) => ({
      user: null,
      isLoading: false,
      error: null,
      
      setUser: (user) => set({ user }),
      
      updateUser: (updates) =>
        set((state) => {
          if (state.user) {
            Object.assign(state.user, updates);
          }
        }),
      
      clearUser: () => set({ user: null, error: null }),
      setLoading: (isLoading) => set({ isLoading }),
      setError: (error) => set({ error }),
    })),
    { name: 'UserStore' }
  )
);
```

### 1.2 Selectors and Performance

```tsx
// components/UserProfile.tsx
// Bad: Subscribes to entire store, re-renders on any change
const { user, isLoading, error } = useUserStore();

// Good: Subscribe to specific slice
const user = useUserStore((state) => state.user);
const isLoading = useUserStore((state) => state.isLoading);

// Better: Custom selector hook
function useUserName() {
  return useUserStore((state) => state.user?.name ?? 'Guest');
}

// Best: Computed selectors with memoization
import { createSelector } from 'reselect';

const selectUser = (state: UserState) => state.user;
const selectIsAdmin = createSelector(
  [selectUser],
  (user) => user?.role === 'admin'
);

// In component
const isAdmin = useUserStore(selectIsAdmin);

// With shallow comparison for arrays
import { shallow } from 'zustand/shallow';

const { permissions } = useUserStore(
  (state) => ({ permissions: state.user?.permissions ?? [] }),
  shallow
);
```

### 1.3 Middleware

```typescript
// stores/cartStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
  totalItems: () => number;
  totalPrice: () => number;
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      
      addItem: (item) =>
        set((state) => {
          const existing = state.items.find((i) => i.id === item.id);
          if (existing) {
            existing.quantity += 1;
          } else {
            state.items.push({ ...item, quantity: 1 });
          }
        }),
      
      removeItem: (id) =>
        set((state) => {
          state.items = state.items.filter((i) => i.id !== id);
        }),
      
      updateQuantity: (id, quantity) =>
        set((state) => {
          const item = state.items.find((i) => i.id === id);
          if (item) item.quantity = quantity;
        }),
      
      clearCart: () => set({ items: [] }),
      
      totalItems: () => get().items.reduce((sum, i) => sum + i.quantity, 0),
      totalPrice: () => get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
    }),
    {
      name: 'cart-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ items: state.items }), // Only persist items
      version: 1,
      migrate: (persistedState: any, version) => {
        if (version === 0) {
          // Migrate from old format
          return { items: persistedState.cartItems ?? [] };
        }
        return persistedState;
      },
    }
  )
);
```

### 1.4 TypeScript Integration

```typescript
// stores/types.ts
import { StateCreator } from 'zustand';

// Slice pattern for large stores
type UserSlice = {
  user: User | null;
  setUser: (user: User) => void;
};

type ThemeSlice = {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
};

type AppStore = UserSlice & ThemeSlice;

const createUserSlice: StateCreator<AppStore, [], [], UserSlice> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
});

const createThemeSlice: StateCreator<AppStore, [], [], ThemeSlice> = (set) => ({
  theme: 'light',
  toggleTheme: () => set((state) => ({ theme: state.theme === 'light' ? 'dark' : 'light' })),
});

export const useAppStore = create<AppStore>()((...args) => ({
  ...createUserSlice(...args),
  ...createThemeSlice(...args),
}));
```

---

## 2. Redux Toolkit

### 2.1 Slice Creation

```typescript
// features/counter/counterSlice.ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
  loading: boolean;
  error: string | null;
}

const initialState: CounterState = {
  value: 0,
  loading: false,
  error: null,
};

// Async thunk
export const incrementAsync = createAsyncThunk(
  'counter/incrementAsync',
  async (amount: number, { rejectWithValue }) => {
    try {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      return amount;
    } catch (error) {
      return rejectWithValue('Failed to increment');
    }
  }
);

const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action: PayloadAction<number>) => {
      state.value += action.payload;
    },
    reset: (state) => {
      state.value = 0;
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(incrementAsync.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(incrementAsync.fulfilled, (state, action) => {
        state.loading = false;
        state.value += action.payload;
      })
      .addCase(incrementAsync.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { increment, decrement, incrementByAmount, reset } = counterSlice.actions;
export default counterSlice.reducer;
```

### 2.2 RTK Query

```typescript
// features/api/apiSlice.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const apiSlice = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) headers.set('authorization', `Bearer ${token}`);
      return headers;
    },
  }),
  tagTypes: ['User', 'Post', 'Comment'],
  endpoints: (builder) => ({
    getUsers: builder.query<User[], void>({
      query: () => '/users',
      providesTags: ['User'],
    }),
    
    getUser: builder.query<User, string>({
      query: (id) => `/users/${id}`,
      providesTags: (result, error, id) => [{ type: 'User', id }],
    }),
    
    updateUser: builder.mutation<User, Partial<User> & { id: string }>({
      query: ({ id, ...patch }) => ({
        url: `/users/${id}`,
        method: 'PATCH',
        body: patch,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'User', id }],
      // Optimistic update
      async onQueryStarted({ id, ...patch }, { dispatch, queryFulfilled }) {
        const patchResult = dispatch(
          apiSlice.util.updateQueryData('getUser', id, (draft) => {
            Object.assign(draft, patch);
          })
        );
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
    }),
    
    deleteUser: builder.mutation<void, string>({
      query: (id) => ({
        url: `/users/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['User'],
    }),
  }),
});

export const {
  useGetUsersQuery,
  useGetUserQuery,
  useUpdateUserMutation,
  useDeleteUserMutation,
} = apiSlice;
```

### 2.3 Store Configuration

```typescript
// app/store.ts
import { configureStore } from '@reduxjs/toolkit';
import { setupListeners } from '@reduxjs/toolkit/query';
import counterReducer from '../features/counter/counterSlice';
import { apiSlice } from '../features/api/apiSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
    [apiSlice.reducerPath]: apiSlice.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST'],
      },
    }).concat(apiSlice.middleware),
  devTools: process.env.NODE_ENV !== 'production',
});

// Enable RTK Query refetchOnFocus/refetchOnReconnect
setupListeners(store.dispatch);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// Typed hooks
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

### 2.4 DevTools Integration

```typescript
// app/store.ts with Redux DevTools
import { configureStore } from '@reduxjs/toolkit';

export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      thunk: true,
      immutableCheck: true,
      serializableCheck: true,
    }),
  devTools: {
    name: 'MyApp',
    trace: true,
    traceLimit: 25,
    actionsBlacklist: ['api/executeQuery/pending'], // Hide noisy actions
  },
});
```

---

## 3. React Context

### 3.1 When to Use Context

| Use Case | Solution | Why |
|----------|----------|-----|
| Theme | Context | Rarely changes, many components need it |
| Auth state | Context + Zustand | Zustand for performance, Context for provider pattern |
| Locale/i18n | Context | Static, rarely changes |
| Form state | react-hook-form | Optimized for forms |
| Server state | TanStack Query | Built-in caching, deduping |
| Complex global state | Zustand/Redux | Better performance, devtools |

### 3.2 Context Pattern with State

```tsx
// contexts/ThemeContext.tsx
import { createContext, useContext, useState, useCallback, useMemo } from 'react';

type Theme = 'light' | 'dark' | 'system';

interface ThemeContextValue {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  resolvedTheme: 'light' | 'dark';
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('system');
  
  const resolvedTheme = useMemo(() => {
    if (theme !== 'system') return theme;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }, [theme]);
  
  const value = useMemo(() => ({ theme, setTheme, resolvedTheme }), [theme, resolvedTheme]);
  
  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
}
```

### 3.3 Split Contexts for Performance

```tsx
// Split into separate contexts to avoid unnecessary re-renders
// contexts/AuthContext.tsx
const AuthStateContext = createContext<AuthState | null>(null);
const AuthDispatchContext = createContext<AuthDispatch | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(authReducer, initialState);
  
  // State changes won't re-render consumers of dispatch only
  return (
    <AuthStateContext.Provider value={state}>
      <AuthDispatchContext.Provider value={dispatch}>
        {children}
      </AuthDispatchContext.Provider>
    </AuthStateContext.Provider>
  );
}

// Components that only dispatch don't re-render on state changes
function LogoutButton() {
  const dispatch = useAuthDispatch();
  return <button onClick={() => dispatch({ type: 'logout' })}>Logout</button>;
}

// Components that read state re-render when state changes
function UserAvatar() {
  const { user } = useAuthState();
  return <img src={user?.avatar} alt={user?.name} />;
}
```

### 3.4 Context Performance Pitfalls

```tsx
// Bad: Object recreated every render, causes all consumers to re-render
function BadProvider({ children }) {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}> {/* New object every render! */}
      {children}
    </UserContext.Provider>
  );
}

// Good: Memoize the value
function GoodProvider({ children }) {
  const [user, setUser] = useState(null);
  const value = useMemo(() => ({ user, setUser }), [user]);
  
  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}

// Better: Use Zustand for complex state
// Context is fine for simple, rarely-changing values like theme or locale
```

---

## 4. Server State vs Client State

### 4.1 State Classification

| Type | Examples | Management |
|------|----------|------------|
| **Server State** | User data, posts, comments, API responses | TanStack Query, SWR, RTK Query |
| **Client State** | UI flags, theme, form inputs, modals | Zustand, Context, useState |
| **URL State** | Filters, page, sort, search query | URL params, nuqs |
| **Persistent State** | Cart, preferences, auth token | localStorage + Zustand persist |

### 4.2 Architecture Pattern

```tsx
// Hybrid approach: TanStack Query for server, Zustand for client

// Server state - TanStack Query
function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });
}

// Client state - Zustand
interface UIState {
  sidebarOpen: boolean;
  activeModal: string | null;
  toastQueue: Toast[];
  toggleSidebar: () => void;
  openModal: (id: string) => void;
  closeModal: () => void;
  addToast: (toast: Toast) => void;
  removeToast: (id: string) => void;
}

export const useUIStore = create<UIState>()((set) => ({
  sidebarOpen: false,
  activeModal: null,
  toastQueue: [],
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  openModal: (id) => set({ activeModal: id }),
  closeModal: () => set({ activeModal: null }),
  addToast: (toast) => set((state) => ({ toastQueue: [...state.toastQueue, toast] })),
  removeToast: (id) => set((state) => ({
    toastQueue: state.toastQueue.filter((t) => t.id !== id),
  })),
}));

// Component using both
function Dashboard() {
  const { data: user } = useUser('123');
  const { sidebarOpen, toggleSidebar } = useUIStore();
  
  return (
    <div>
      <button onClick={toggleSidebar}>Toggle Sidebar</button>
      {sidebarOpen && <Sidebar user={user} />}
    </div>
  );
}
```

---

## 5. Form State

### 5.1 react-hook-form with Zod

```tsx
// components/RegistrationForm.tsx
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
  role: z.enum(['admin', 'user']),
  tags: z.array(z.string()).min(1, 'At least one tag required'),
  acceptTerms: z.boolean().refine((val) => val === true, 'You must accept terms'),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

type FormData = z.infer<typeof schema>;

export function RegistrationForm() {
  const {
    register,
    handleSubmit,
    control,
    formState: { errors, isSubmitting, isDirty, isValid },
    reset,
    watch,
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    mode: 'onBlur', // Validate on blur
    defaultValues: {
      role: 'user',
      tags: [],
      acceptTerms: false,
    },
  });
  
  const onSubmit = async (data: FormData) => {
    await registerUser(data);
    reset();
  };
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('email')}
        placeholder="Email"
        aria-invalid={errors.email ? 'true' : 'false'}
      />
      {errors.email && <span role="alert">{errors.email.message}</span>}
      
      <input {...register('password')} type="password" placeholder="Password" />
      {errors.password && <span role="alert">{errors.password.message}</span>}
      
      <input {...register('confirmPassword')} type="password" placeholder="Confirm" />
      
      <Controller
        name="role"
        control={control}
        render={({ field }) => (
          <select {...field}>
            <option value="user">User</option>
            <option value="admin">Admin</option>
          </select>
        )}
      />
      
      <button type="submit" disabled={!isValid || isSubmitting}>
        {isSubmitting ? 'Registering...' : 'Register'}
      </button>
    </form>
  );
}
```

### 5.2 Field Arrays

```tsx
// Dynamic form fields
import { useFieldArray } from 'react-hook-form';

interface FormData {
  items: { name: string; quantity: number; price: number }[];
}

function OrderForm() {
  const { control, register } = useForm<FormData>({
    defaultValues: { items: [{ name: '', quantity: 1, price: 0 }] },
  });
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'items',
  });
  
  return (
    <form>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...register(`items.${index}.name`)} placeholder="Item name" />
          <input {...register(`items.${index}.quantity`)} type="number" />
          <input {...register(`items.${index}.price`)} type="number" />
          <button type="button" onClick={() => remove(index)}>Remove</button>
        </div>
      ))}
      <button
        type="button"
        onClick={() => append({ name: '', quantity: 1, price: 0 })}
      >
        Add Item
      </button>
    </form>
  );
}
```

### 5.3 Controlled vs Uncontrolled

```tsx
// Uncontrolled (react-hook-form default) - Better performance
<input {...register('name')} />

// Controlled (use when needed)
<Controller
  name="select"
  control={control}
  render={({ field: { onChange, value } }) => (
    <Select options={options} value={value} onChange={onChange} />
  )}
/>

// When to use controlled:
// - Custom components (Select, DatePicker, RichText)
// - Fields that depend on other fields
// - External state synchronization
// When to use uncontrolled:
// - Simple inputs (text, checkbox, radio)
// - Large forms with many fields
// - Performance-sensitive forms
```

---

## 6. URL State

### 6.1 Query Parameters

```tsx
// hooks/useQueryParams.ts
import { useSearchParams } from 'next/navigation';
import { useCallback } from 'react';

export function useQueryParams() {
  const searchParams = useSearchParams();
  
  const getParam = useCallback(
    (key: string) => searchParams.get(key),
    [searchParams]
  );
  
  const setParam = useCallback(
    (key: string, value: string) => {
      const params = new URLSearchParams(searchParams.toString());
      if (value) {
        params.set(key, value);
      } else {
        params.delete(key);
      }
      window.history.pushState(null, '', `?${params.toString()}`);
    },
    [searchParams]
  );
  
  return { getParam, setParam, searchParams };
}

// Usage in filter component
function ProductFilters() {
  const { getParam, setParam } = useQueryParams();
  const category = getParam('category') ?? 'all';
  const sort = getParam('sort') ?? 'newest';
  
  return (
    <div>
      <select
        value={category}
        onChange={(e) => setParam('category', e.target.value)}
      >
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
        <option value="clothing">Clothing</option>
      </select>
    </div>
  );
}
```

### 6.2 nuqs Library

```tsx
// Using nuqs for type-safe URL state
import { useQueryState, parseAsString, parseAsInteger, parseAsBoolean } from 'nuqs';

function ProductCatalog() {
  const [search, setSearch] = useQueryState('search', parseAsString.withDefault(''));
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1));
  const [showFilters, setShowFilters] = useQueryState('filters', parseAsBoolean.withDefault(false));
  const [category, setCategory] = useQueryState('category', parseAsString.withDefault('all'));
  
  // URL: ?search=iphone&page=2&filters=true&category=electronics
  // All types are inferred correctly!
  
  return (
    <div>
      <input
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        placeholder="Search..."
      />
      <button onClick={() => setPage(page + 1)}>Next Page</button>
      <button onClick={() => setShowFilters(!showFilters)}>
        {showFilters ? 'Hide' : 'Show'} Filters
      </button>
    </div>
  );
}
```

### 6.3 Route State (React Router)

```tsx
// Using React Router state
import { useNavigate, useLocation } from 'react-router-dom';

function ProductList() {
  const navigate = useNavigate();
  const location = useLocation();
  
  const goToProduct = (productId: string) => {
    navigate(`/products/${productId}`, {
      state: { from: location.pathname, scrollToReviews: true },
    });
  };
  
  return <button onClick={() => goToProduct('123')}>View Product</button>;
}

// Reading route state
function ProductDetail() {
  const location = useLocation();
  const { from, scrollToReviews } = location.state ?? {};
  
  useEffect(() => {
    if (scrollToReviews) {
      document.getElementById('reviews')?.scrollIntoView();
    }
  }, [scrollToReviews]);
  
  return <div>...</div>;
}
```

---

## 7. Local Storage State

### 7.1 Zustand Persist Middleware

```typescript
// stores/settingsStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface Settings {
  theme: 'light' | 'dark' | 'system';
  language: string;
  sidebarCollapsed: boolean;
  recentSearches: string[];
}

export const useSettingsStore = create<Settings>()(
  persist(
    (set) => ({
      theme: 'system',
      language: 'en',
      sidebarCollapsed: false,
      recentSearches: [],
      
      setTheme: (theme: Settings['theme']) => set({ theme }),
      setLanguage: (language: string) => set({ language }),
      toggleSidebar: () => set((state) => ({ sidebarCollapsed: !state.sidebarCollapsed })),
      addRecentSearch: (search: string) =>
        set((state) => ({
          recentSearches: [search, ...state.recentSearches.slice(0, 9)],
        })),
    }),
    {
      name: 'user-settings',
      storage: {
        getItem: (name) => {
          const str = localStorage.getItem(name);
          return str ? JSON.parse(str) : null;
        },
        setItem: (name, value) => localStorage.setItem(name, JSON.stringify(value)),
        removeItem: (name) => localStorage.removeItem(name),
      },
      partialize: (state) => ({
        theme: state.theme,
        language: state.language,
        sidebarCollapsed: state.sidebarCollapsed,
      }),
    }
  )
);
```

### 7.2 Custom useLocalStorage Hook

```tsx
// hooks/useLocalStorage.ts
import { useState, useEffect, useCallback } from 'react';

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue;
    try {
      const item = window.localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch {
      return initialValue;
    }
  });
  
  const setValue = useCallback(
    (value: T | ((prev: T) => T)) => {
      try {
        const valueToStore = value instanceof Function ? value(storedValue) : value;
        setStoredValue(valueToStore);
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
        // Sync across tabs
        window.dispatchEvent(new StorageEvent('storage', { key, newValue: JSON.stringify(valueToStore) }));
      } catch (error) {
        console.error('Error saving to localStorage:', error);
      }
    },
    [key, storedValue]
  );
  
  const removeValue = useCallback(() => {
    try {
      window.localStorage.removeItem(key);
      setStoredValue(initialValue);
    } catch (error) {
      console.error('Error removing from localStorage:', error);
    }
  }, [key, initialValue]);
  
  // Listen for changes in other tabs
  useEffect(() => {
    const handleStorage = (e: StorageEvent) => {
      if (e.key === key && e.newValue !== null) {
        setStoredValue(JSON.parse(e.newValue));
      }
    };
    window.addEventListener('storage', handleStorage);
    return () => window.removeEventListener('storage', handleStorage);
  }, [key]);
  
  return [storedValue, setValue, removeValue] as const;
}

// Usage
function Settings() {
  const [theme, setTheme] = useLocalStorage('theme', 'light');
  return (
    <select value={theme} onChange={(e) => setTheme(e.target.value)}>
      <option value="light">Light</option>
      <option value="dark">Dark</option>
    </select>
  );
}
```

### 7.3 Hydration Issues

```tsx
// Fix hydration mismatch with localStorage
function ClientOnly({ children }: { children: React.ReactNode }) {
  const [hasMounted, setHasMounted] = useState(false);
  
  useEffect(() => {
    setHasMounted(true);
  }, []);
  
  if (!hasMounted) return null;
  return <>{children}</>;
}

// Usage
function App() {
  return (
    <div>
      <Header />
      <ClientOnly>
        <ThemeToggle /> {/* Uses localStorage, safe to render client-only */}
      </ClientOnly>
    </div>
  );
}

// Or use next-themes for Next.js
import { ThemeProvider } from 'next-themes';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

---

## 8. Global State Anti-Patterns

### 8.1 Prop Drilling

```tsx
// Bad: Prop drilling through many layers
function App() {
  const [user, setUser] = useState(null);
  return <Layout user={user} setUser={setUser} />;
}

function Layout({ user, setUser }) {
  return <Sidebar user={user} setUser={setUser} />;
}

function Sidebar({ user, setUser }) {
  return <UserMenu user={user} setUser={setUser} />;
}

function UserMenu({ user, setUser }) {
  return <button onClick={() => setUser(null)}>Logout {user.name}</button>;
}

// Good: Use context or Zustand at appropriate level
function App() {
  return (
    <UserProvider>
      <Layout />
    </UserProvider>
  );
}

function UserMenu() {
  const { user, logout } = useUser();
  return <button onClick={logout}>Logout {user.name}</button>;
}
```

### 8.2 Unnecessary Re-renders

```tsx
// Bad: Subscribing to entire store
function UserProfile() {
  const state = useUserStore(); // Re-renders on ANY state change
  return <div>{state.user.name}</div>;
}

// Good: Select specific slice
function UserProfile() {
  const userName = useUserStore((state) => state.user?.name);
  return <div>{userName}</div>;
}

// Bad: Inline selectors (new function every render)
const user = useUserStore((state) => state.users.find((u) => u.id === id));

// Good: Memoized selector
const selectUserById = (id: string) => (state: UserState) => state.users[id];
const user = useUserStore(selectUserById(id));
```

### 8.3 Zombie Children Pattern

```tsx
// Problem: Parent unmounts, child still references old state
function Parent() {
  const [items, setItems] = useState(['a', 'b', 'c']);
  
  return (
    <div>
      {items.map((item) => (
        <Child key={item} item={item} onRemove={() => setItems((prev) => prev.filter((i) => i !== item))} />
      ))}
    </div>
  );
}

function Child({ item, onRemove }) {
  // If Parent re-renders and removes this child,
  // onRemove closure references stale state
  const handleRemove = useCallback(() => {
    onRemove();
  }, [onRemove]);
  
  return <button onClick={handleRemove}>Remove {item}</button>;
}

// Solution: Use stable references or store
function Parent() {
  const items = useItemStore((state) => state.items);
  const removeItem = useItemStore((state) => state.removeItem);
  
  return (
    <div>
      {items.map((item) => (
        <Child key={item.id} item={item} onRemove={() => removeItem(item.id)} />
      ))}
    </div>
  );
}
```

---

## 9. State Normalization

### 9.1 Flat Structure Design

```typescript
// Bad: Nested structure, hard to update
interface NestedState {
  posts: {
    id: string;
    title: string;
    author: {
      id: string;
      name: string;
      posts: Post[]; // Circular reference!
    };
    comments: {
      id: string;
      text: string;
      author: User;
    }[];
  }[];
}

// Good: Flat normalized structure
interface NormalizedState {
  posts: Record<string, Post>;
  users: Record<string, User>;
  comments: Record<string, Comment>;
  // Relationship tables
  postComments: Record<string, string[]>; // postId -> commentIds
  userPosts: Record<string, string[]>; // userId -> postIds
}

// Example normalized state
const state: NormalizedState = {
  posts: {
    '1': { id: '1', title: 'Hello', authorId: 'user1', commentIds: ['c1', 'c2'] },
  },
  users: {
    'user1': { id: 'user1', name: 'John' },
  },
  comments: {
    'c1': { id: 'c1', text: 'Nice!', authorId: 'user2' },
    'c2': { id: 'c2', text: 'Thanks!', authorId: 'user1' },
  },
  postComments: { '1': ['c1', 'c2'] },
  userPosts: { 'user1': ['1'] },
};
```

### 9.2 ID-Based Lookups

```tsx
// Store with normalized state
interface PostStore {
  posts: Record<string, Post>;
  postIds: string[];
  addPost: (post: Post) => void;
  updatePost: (id: string, updates: Partial<Post>) => void;
  removePost: (id: string) => void;
  getPost: (id: string) => Post | undefined;
  getPosts: () => Post[];
}

export const usePostStore = create<PostStore>()((set, get) => ({
  posts: {},
  postIds: [],
  
  addPost: (post) =>
    set((state) => ({
      posts: { ...state.posts, [post.id]: post },
      postIds: [...state.postIds, post.id],
    })),
  
  updatePost: (id, updates) =>
    set((state) => ({
      posts: {
        ...state.posts,
        [id]: { ...state.posts[id], ...updates },
      },
    })),
  
  removePost: (id) =>
    set((state) => {
      const { [id]: _, ...remainingPosts } = state.posts;
      return {
        posts: remainingPosts,
        postIds: state.postIds.filter((postId) => postId !== id),
      };
    }),
  
  getPost: (id) => get().posts[id],
  getPosts: () => get().postIds.map((id) => get().posts[id]),
}));
```

### 9.3 Denormalization for UI

```tsx
// Denormalize for component rendering
function PostCard({ postId }: { postId: string }) {
  const post = usePostStore((state) => state.posts[postId]);
  const author = useUserStore((state) => state.users[post?.authorId]);
  const comments = useCommentStore((state) =>
    post?.commentIds?.map((id) => state.comments[id]) ?? []
  );
  
  if (!post || !author) return null;
  
  return (
    <article>
      <h2>{post.title}</h2>
      <p>By {author.name}</p>
      <ul>
        {comments.map((comment) => (
          <li key={comment.id}>{comment.text}</li>
        ))}
      </ul>
    </article>
  );
}

// Or use a selector for denormalized data
const selectPostWithRelations = (postId: string) => (state: RootState) => {
  const post = state.posts.posts[postId];
  if (!post) return null;
  
  return {
    ...post,
    author: state.users.users[post.authorId],
    comments: post.commentIds.map((id) => state.comments.comments[id]),
  };
};
```

---

## 10. Derived State

### 10.1 Selectors

```tsx
// Zustand with selectors
interface CartStore {
  items: CartItem[];
}

// Memoized selector outside component
const selectCartTotal = (state: CartStore) =>
  state.items.reduce((total, item) => total + item.price * item.quantity, 0);

const selectCartItemCount = (state: CartStore) =>
  state.items.reduce((count, item) => count + item.quantity, 0);

const selectIsCartEmpty = (state: CartStore) => state.items.length === 0;

// Component usage
function CartSummary() {
  const total = useCartStore(selectCartTotal);
  const itemCount = useCartStore(selectCartItemCount);
  const isEmpty = useCartStore(selectIsCartEmpty);
  
  return (
    <div>
      <p>{itemCount} items</p>
      <p>Total: ${total.toFixed(2)}</p>
      {isEmpty && <p>Your cart is empty</p>}
    </div>
  );
}
```

### 10.2 Reselect with Redux

```tsx
// store/selectors.ts
import { createSelector } from '@reduxjs/toolkit';

// Input selectors
const selectItems = (state: RootState) => state.cart.items;
const selectFilterCategory = (state: RootState) => state.filters.category;
const selectSortBy = (state: RootState) => state.filters.sortBy;

// Memoized derived selector
export const selectFilteredAndSortedItems = createSelector(
  [selectItems, selectFilterCategory, selectSortBy],
  (items, category, sortBy) => {
    let result = [...items];
    
    if (category !== 'all') {
      result = result.filter((item) => item.category === category);
    }
    
    switch (sortBy) {
      case 'price-asc':
        result.sort((a, b) => a.price - b.price);
        break;
      case 'price-desc':
        result.sort((a, b) => b.price - a.price);
        break;
      case 'name':
        result.sort((a, b) => a.name.localeCompare(b.name));
        break;
    }
    
    return result;
  }
);

// Usage - only re-renders when items, category, or sortBy changes
const filteredItems = useAppSelector(selectFilteredAndSortedItems);
```

### 10.3 Computed Values in Zustand

```tsx
// Zustand with computed values
import { create } from 'zustand';

interface Store {
  items: Item[];
  // Computed (not stored, calculated on access)
  getTotalPrice: () => number;
  getUniqueCategories: () => string[];
  getItemById: (id: string) => Item | undefined;
}

export const useStore = create<Store>((set, get) => ({
  items: [],
  
  getTotalPrice: () => get().items.reduce((sum, item) => sum + item.price, 0),
  
  getUniqueCategories: () => [...new Set(get().items.map((item) => item.category))],
  
  getItemById: (id) => get().items.find((item) => item.id === id),
}));

// For true computed state, use middleware or subscribe
// subscribeWithSelector middleware
import { subscribeWithSelector } from 'zustand/middleware';

export const useStore = create(
  subscribeWithSelector((set, get) => ({
    items: [],
    totalPrice: 0, // Will be kept in sync via subscription
  }))
);

// Keep computed state in sync
useStore.subscribe(
  (state) => state.items,
  (items) => {
    useStore.setState({ totalPrice: items.reduce((sum, item) => sum + item.price, 0) });
  }
);
```

---

## Quick Reference: State Management Checklist

### Choosing State Management
- [ ] Server state → TanStack Query / SWR / RTK Query
- [ ] Global client state → Zustand (simple) / Redux (complex)
- [ ] Local UI state → useState / useReducer
- [ ] Form state → react-hook-form + zod
- [ ] URL state → nuqs / query params
- [ ] Persistent state → Zustand persist / localStorage

### Best Practices
- [ ] Keep state minimal (derive, don't store)
- [ ] Normalize relational data
- [ ] Use selectors to prevent unnecessary re-renders
- [ ] Separate server and client state
- [ ] Avoid prop drilling with composition or store
- [ ] Use TypeScript for type safety
- [ ] Consider state serialization (SSR, persistence)

### Anti-Patterns to Avoid
- [ ] Storing derived data in state
- [ ] Deeply nested state structures
- [ ] Storing server state in global store
- [ ] Using context for frequently-changing state
- [ ] Prop drilling more than 2 levels
- [ ] Not memoizing selectors
- [ ] Mixing sync and async state logic
