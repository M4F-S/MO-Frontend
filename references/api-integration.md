# API Integration Reference

> Comprehensive guide to data fetching and API integration patterns. Covers TanStack Query, SWR, error boundaries, loading states, pagination, data normalization, caching, retry/backoff, file uploads, real-time updates, and GraphQL clients.

---

## Table of Contents

1. [TanStack Query (React Query)](#1-tanstack-query-react-query)
2. [SWR](#2-swr)
3. [Error Boundaries](#3-error-boundaries)
4. [Loading States](#4-loading-states)
5. [Pagination](#5-pagination)
6. [Data Normalization](#6-data-normalization)
7. [Caching Strategies](#7-caching-strategies)
8. [Retry and Backoff](#8-retry-and-backoff)
9. [File Uploads](#9-file-uploads)
10. [Real-Time Updates](#10-real-time-updates)
11. [GraphQL Client](#11-graphql-client)

---

## 1. TanStack Query (React Query)

### 1.1 Basic Query Setup

```typescript
// lib/query-client.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
    },
    mutations: {
      retry: 1,
    },
  },
});

// app/providers.tsx
import { QueryClientProvider } from '@tanstack/react-query';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

### 1.2 Query Patterns

```tsx
// Basic query
function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    enabled: !!userId, // Only run when userId is truthy
    select: (data) => ({
      ...data,
      fullName: `${data.firstName} ${data.lastName}`,
    }),
  });
}

// Parallel queries
function useDashboardData(userId: string) {
  const userQuery = useUser(userId);
  const postsQuery = usePosts(userId);
  const statsQuery = useStats(userId);
  
  const isLoading = userQuery.isLoading || postsQuery.isLoading || statsQuery.isLoading;
  const isError = userQuery.isError || postsQuery.isError || statsQuery.isError;
  
  return { userQuery, postsQuery, statsQuery, isLoading, isError };
}

// Dependent queries (sequential)
function useUserPosts(userId: string) {
  const userQuery = useUser(userId);
  
  const postsQuery = useQuery({
    queryKey: ['posts', userId],
    queryFn: () => fetchUserPosts(userId),
    enabled: userQuery.isSuccess, // Wait for user to load
  });
  
  return { user: userQuery.data, posts: postsQuery.data };
}

// Infinite query (pagination)
function useInfinitePosts() {
  return useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: ({ pageParam }) => fetchPosts({ cursor: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    initialPageParam: null as string | null,
  });
}
```

### 1.3 Mutations and Optimistic Updates

```tsx
// Mutation with cache invalidation
function useUpdateUser() {
  return useMutation({
    mutationFn: updateUser,
    onSuccess: (data, variables) => {
      // Invalidate specific query
      queryClient.invalidateQueries({ queryKey: ['user', variables.id] });
      
      // Or update cache directly
      queryClient.setQueryData(['user', variables.id], data);
      
      // Show success toast
      toast.success('User updated successfully');
    },
    onError: (error) => {
      toast.error(error.message);
    },
  });
}

// Optimistic update
function useToggleLike() {
  return useMutation({
    mutationFn: toggleLike,
    
    // Optimistic update
    onMutate: async (postId: string) => {
      await queryClient.cancelQueries({ queryKey: ['posts'] });
      
      const previousPosts = queryClient.getQueryData<Post[]>(['posts']);
      
      queryClient.setQueryData(['posts'], (old: Post[]) =>
        old.map((post) =>
          post.id === postId
            ? { ...post, liked: !post.liked, likes: post.liked ? post.likes - 1 : post.likes + 1 }
            : post
        )
      );
      
      return { previousPosts };
    },
    
    // Rollback on error
    onError: (err, postId, context) => {
      queryClient.setQueryData(['posts'], context?.previousPosts);
    },
    
    // Refetch after success or error
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] });
    },
  });
}

// Usage in component
function LikeButton({ postId, liked }: { postId: string; liked: boolean }) {
  const toggleLike = useToggleLike();
  
  return (
    <button
      onClick={() => toggleLike.mutate(postId)}
      disabled={toggleLike.isPending}
    >
      {liked ? '❤️' : '🤍'}
      {toggleLike.isPending && <span>Loading...</span>}
    </button>
  );
}
```

### 1.4 Prefetching

```tsx
// Prefetch on hover
function PostLink({ postId }: { postId: string }) {
  const queryClient = useQueryClient();
  
  return (
    <Link
      href={`/posts/${postId}`}
      onMouseEnter={() => {
        queryClient.prefetchQuery({
          queryKey: ['post', postId],
          queryFn: () => fetchPost(postId),
          staleTime: 10 * 60 * 1000, // 10 minutes
        });
      }}
    >
      Read Post
    </Link>
  );
}

// Server-side prefetching (Next.js)
export async function generateStaticParams() {
  const posts = await fetchPosts();
  
  // Prefetch all posts in parallel
  await Promise.all(
    posts.map((post) =>
      queryClient.prefetchQuery({
        queryKey: ['post', post.id],
        queryFn: () => fetchPost(post.id),
      })
    )
  );
  
  return posts.map((post) => ({ id: post.id }));
}
```

---

## 2. SWR

### 2.1 Basic SWR Configuration

```typescript
// lib/swr-config.ts
import { SWRConfig } from 'swr';

const fetcher = (url: string) => fetch(url).then((res) => res.json());

export function SWRProvider({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher,
        revalidateOnFocus: true,
        revalidateOnReconnect: true,
        dedupingInterval: 2000, // Deduplicate requests within 2s
        errorRetryCount: 3,
        errorRetryInterval: 5000,
        onError: (error) => {
          console.error('SWR Error:', error);
        },
      }}
    >
      {children}
    </SWRConfig>
  );
}
```

### 2.2 SWR Patterns

```tsx
// Basic use
import useSWR from 'swr';

function UserProfile({ userId }: { userId: string }) {
  const { data, error, isLoading, mutate } = useSWR(
    `/api/users/${userId}`,
    fetcher,
    {
      refreshInterval: 30000, // Poll every 30s
      revalidateIfStale: false,
    }
  );
  
  if (isLoading) return <Loading />;
  if (error) return <Error error={error} />;
  
  return (
    <div>
      <h1>{data.name}</h1>
      <button onClick={() => mutate()}>Refresh</button>
    </div>
  );
}

// Conditional fetching
function useUser(userId: string | null) {
  return useSWR(userId ? `/api/users/${userId}` : null, fetcher);
}

// Dependent fetching
function useUserAndFriends(userId: string) {
  const { data: user } = useSWR(`/api/users/${userId}`, fetcher);
  const { data: friends } = useSWR(
    user ? `/api/users/${userId}/friends` : null,
    fetcher
  );
  
  return { user, friends };
}

// Global mutation (revalidate)
import { mutate } from 'swr';

async function updateUser(userId: string, data: Partial<User>) {
  await fetch(`/api/users/${userId}`, {
    method: 'PATCH',
    body: JSON.stringify(data),
  });
  
  // Revalidate specific cache
  mutate(`/api/users/${userId}`);
  
  // Or mutate with new data immediately
  mutate(`/api/users/${userId}`, { ...currentUser, ...data }, false);
}
```

### 2.3 SWR Revalidation Strategies

| Strategy | Behavior | Use Case |
|----------|----------|----------|
| `revalidateOnFocus` | Refetch when window regains focus | Data that may change frequently |
| `revalidateOnReconnect` | Refetch when network reconnects | Offline-first apps |
| `refreshInterval` | Poll at fixed interval | Real-time data (notifications) |
| `revalidateIfStale` | Refetch on mount if stale | Always fresh data |
| `revalidateOnMount` | Always refetch on mount | Force refresh on navigation |

---

## 3. Error Boundaries

### 3.1 React Error Boundary

```tsx
// components/ErrorBoundary.tsx
'use client';

import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
    this.props.onError?.(error, errorInfo);
    
    // Send to error tracking service
    // Sentry.captureException(error, { extra: errorInfo });
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback ?? (
          <ErrorFallback
            error={this.state.error}
            onReset={() => this.setState({ hasError: false, error: null })}
          />
        )
      );
    }

    return this.props.children;
  }
}

// Error fallback UI
function ErrorFallback({ error, onReset }: { error: Error | null; onReset: () => void }) {
  return (
    <div role="alert" className="error-container">
      <h2>Something went wrong</h2>
      <details>
        <summary>Error details</summary>
        <pre>{error?.message}</pre>
      </details>
      <button onClick={onReset}>Try again</button>
    </div>
  );
}
```

### 3.2 Query Error Handling

```tsx
// Global error handling with TanStack Query
import { QueryCache } from '@tanstack/react-query';

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      if (query.meta?.errorMessage) {
        toast.error(query.meta.errorMessage as string);
      }
    },
  }),
});

// Query with error handling
function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: fetchUser,
    meta: { errorMessage: 'Failed to load user' },
    throwOnError: false, // Don't throw, handle in component
  });
}

// Component with error UI
function UserProfile({ userId }: { userId: string }) {
  const { data, error, isError, isLoading } = useUser(userId);
  
  if (isLoading) return <UserSkeleton />;
  if (isError) return <ErrorState error={error} retry={() => window.location.reload()} />;
  
  return <UserCard user={data} />;
}

// Error state component
function ErrorState({ error, retry }: { error: Error; retry: () => void }) {
  const isNetworkError = error.message.includes('Network');
  
  return (
    <div className="error-state">
      {isNetworkError ? (
        <>
          <WifiOffIcon />
          <p>You're offline. Check your connection.</p>
        </>
      ) : (
        <>
          <AlertIcon />
          <p>Something went wrong. Please try again.</p>
        </>
      )}
      <button onClick={retry}>Retry</button>
    </div>
  );
}
```

---

## 4. Loading States

### 4.1 Skeleton vs Spinner

```tsx
// Skeleton component (better UX)
function CardSkeleton() {
  return (
    <div className="card skeleton">
      <div className="skeleton-image" />
      <div className="skeleton-content">
        <div className="skeleton-title" />
        <div className="skeleton-text" />
        <div className="skeleton-text short" />
      </div>
    </div>
  );
}

// CSS for skeleton
// .skeleton { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
// @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: .5; } }

// Spinner (use sparingly)
function Spinner({ size = 'md' }: { size?: 'sm' | 'md' | 'lg' }) {
  const sizeClasses = { sm: 'w-4 h-4', md: 'w-8 h-8', lg: 'w-12 h-12' };
  return (
    <div className={`animate-spin ${sizeClasses[size]}`} role="status">
      <span className="sr-only">Loading...</span>
    </div>
  );
}

// Progressive loading pattern
function ProgressiveImage({ src, alt }: { src: string; alt: string }) {
  const [loaded, setLoaded] = useState(false);
  
  return (
    <div className="image-container">
      {!loaded && <ImageSkeleton />}
      <img
        src={src}
        alt={alt}
        className={loaded ? 'opacity-100' : 'opacity-0'}
        onLoad={() => setLoaded(true)}
      />
    </div>
  );
}
```

### 4.2 Skeleton Libraries

```tsx
// Using react-loading-skeleton
import Skeleton from 'react-loading-skeleton';
import 'react-loading-skeleton/dist/skeleton.css';

function UserCardSkeleton() {
  return (
    <div className="user-card">
      <Skeleton circle width={50} height={50} />
      <div>
        <Skeleton width={200} height={20} />
        <Skeleton width={150} height={16} />
      </div>
    </div>
  );
}

// Using @mui/material Skeleton
import { Skeleton } from '@mui/material';

function TableSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <>
      {Array.from({ length: rows }).map((_, i) => (
        <Skeleton key={i} height={48} />
      ))}
    </>
  );
}
```

---

## 5. Pagination

### 5.1 Infinite Scroll

```tsx
// With TanStack Query infinite query
function InfinitePostList() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfinitePosts();
  const observerRef = useRef<IntersectionObserver>();
  
  const lastPostRef = useCallback(
    (node: HTMLDivElement) => {
      if (isFetchingNextPage) return;
      if (observerRef.current) observerRef.current.disconnect();
      
      observerRef.current = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting && hasNextPage) {
          fetchNextPage();
        }
      });
      
      if (node) observerRef.current.observe(node);
    },
    [isFetchingNextPage, hasNextPage, fetchNextPage]
  );
  
  const posts = data?.pages.flatMap((page) => page.posts) ?? [];
  
  return (
    <div className="post-list">
      {posts.map((post, index) => (
        <div
          key={post.id}
          ref={index === posts.length - 1 ? lastPostRef : undefined}
        >
          <PostCard post={post} />
        </div>
      ))}
      {isFetchingNextPage && <PostSkeleton />}
    </div>
  );
}
```

### 5.2 Load More Button

```tsx
function LoadMoreList() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfinitePosts();
  
  return (
    <div>
      {data?.pages.map((page, i) => (
        <div key={i}>
          {page.posts.map((post) => (
            <PostCard key={post.id} post={post} />
          ))}
        </div>
      ))}
      
      <button
        onClick={() => fetchNextPage()}
        disabled={!hasNextPage || isFetchingNextPage}
      >
        {isFetchingNextPage ? 'Loading...' : hasNextPage ? 'Load More' : 'No more posts'}
      </button>
    </div>
  );
}
```

### 5.3 Cursor-Based Pagination

```typescript
// API integration
interface CursorPagination<T> {
  data: T[];
  nextCursor: string | null;
  hasMore: boolean;
}

async function fetchPosts(cursor?: string): Promise<CursorPagination<Post>> {
  const params = new URLSearchParams();
  if (cursor) params.set('cursor', cursor);
  params.set('limit', '20');
  
  const response = await fetch(`/api/posts?${params}`);
  return response.json();
}

// TanStack Query usage
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  initialPageParam: undefined as string | undefined,
});
```

---

## 6. Data Normalization

### 6.1 Normalizr

```typescript
import { normalize, schema } from 'normalizr';

// Define schemas
const user = new schema.Entity('users');
const comment = new schema.Entity('comments', { user });
const post = new schema.Entity('posts', {
  author: user,
  comments: [comment],
});

// Normalize response
const data = {
  id: 'post1',
  title: 'Hello',
  author: { id: 'user1', name: 'John' },
  comments: [
    { id: 'comment1', text: 'Nice!', user: { id: 'user2', name: 'Jane' } },
  ],
};

const normalized = normalize(data, post);
// Result:
// {
//   entities: {
//     users: { user1: {...}, user2: {...} },
//     comments: { comment1: {...} },
//     posts: { post1: {...} }
//   },
//   result: 'post1'
// }
```

### 6.2 Redux Toolkit Entity Adapters

```typescript
import { createEntityAdapter, createSlice } from '@reduxjs/toolkit';

// Create adapter
const usersAdapter = createEntityAdapter<User>({
  sortComparer: (a, b) => a.name.localeCompare(b.name),
  selectId: (user) => user.id,
});

// Initial state with adapter
const usersSlice = createSlice({
  name: 'users',
  initialState: usersAdapter.getInitialState({
    loading: false,
    error: null,
  }),
  reducers: {
    addUser: usersAdapter.addOne,
    addUsers: usersAdapter.addMany,
    updateUser: usersAdapter.updateOne,
    removeUser: usersAdapter.removeOne,
    setUsers: usersAdapter.setAll,
  },
});

// Selectors
export const {
  selectAll: selectAllUsers,
  selectById: selectUserById,
  selectIds: selectUserIds,
  selectEntities: selectUserEntities,
  selectTotal: selectTotalUsers,
} = usersAdapter.getSelectors((state: RootState) => state.users);

// Usage in component
const user = useSelector((state) => selectUserById(state, 'user1'));
const users = useSelector(selectAllUsers);
```

### 6.3 Manual Normalization with Zustand

```typescript
// stores/postStore.ts
import { create } from 'zustand';

interface PostStore {
  posts: Record<string, Post>;
  users: Record<string, User>;
  comments: Record<string, Comment>;
  addPost: (post: Post) => void;
  addPosts: (posts: Post[]) => void;
  getPostWithRelations: (postId: string) => DenormalizedPost | undefined;
}

export const usePostStore = create<PostStore>((set, get) => ({
  posts: {},
  users: {},
  comments: {},
  
  addPost: (post) => {
    const { users: postUsers, comments: postComments, ...postData } = post;
    
    set((state) => ({
      posts: { ...state.posts, [post.id]: postData },
      users: { ...state.users, ...postUsers },
      comments: { ...state.comments, ...postComments },
    }));
  },
  
  addPosts: (posts) => {
    posts.forEach((post) => get().addPost(post));
  },
  
  getPostWithRelations: (postId) => {
    const { posts, users, comments } = get();
    const post = posts[postId];
    if (!post) return undefined;
    
    return {
      ...post,
      author: users[post.authorId],
      comments: post.commentIds.map((id) => comments[id]),
    };
  },
}));
```

---

## 7. Caching Strategies

### 7.1 Cache Comparison

| Strategy | Library | Best For | Persistence |
|----------|---------|----------|-------------|
| **In-memory** | TanStack Query | Active data | Session only |
| **SWR** | SWR | Stale-while-revalidate | Session only |
| **LocalStorage** | zustand persist | User preferences | Permanent |
| **IndexedDB** | Dexie | Large datasets | Permanent |
| **Service Worker** | Workbox | Static assets | Controlled |

### 7.2 Custom Cache Layer

```typescript
// lib/cache.ts
class CacheLayer<T> {
  private cache = new Map<string, { data: T; expires: number }>();
  
  set(key: string, data: T, ttl: number = 60000) {
    this.cache.set(key, { data, expires: Date.now() + ttl });
  }
  
  get(key: string): T | undefined {
    const entry = this.cache.get(key);
    if (!entry) return undefined;
    if (Date.now() > entry.expires) {
      this.cache.delete(key);
      return undefined;
    }
    return entry.data;
  }
  
  invalidate(pattern: RegExp) {
    for (const key of this.cache.keys()) {
      if (pattern.test(key)) this.cache.delete(key);
    }
  }
  
  clear() {
    this.cache.clear();
  }
}

export const apiCache = new CacheLayer<any>();

// Usage in fetch wrapper
async function fetchWithCache(url: string, options?: RequestInit) {
  const cached = apiCache.get(url);
  if (cached) return cached;
  
  const response = await fetch(url, options);
  const data = await response.json();
  apiCache.set(url, data, 5 * 60 * 1000); // 5 minutes
  
  return data;
}
```

---

## 8. Retry and Backoff

### 8.1 Exponential Backoff

```typescript
// lib/retry.ts
interface RetryOptions {
  maxRetries?: number;
  baseDelay?: number;
  maxDelay?: number;
  shouldRetry?: (error: any) => boolean;
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const { maxRetries = 3, baseDelay = 1000, maxDelay = 30000, shouldRetry } = options;
  
  let lastError: Error;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      
      if (attempt === maxRetries || (shouldRetry && !shouldRetry(error))) {
        throw lastError;
      }
      
      const delay = Math.min(baseDelay * 2 ** attempt, maxDelay);
      const jitter = Math.random() * 1000;
      await new Promise((resolve) => setTimeout(resolve, delay + jitter));
    }
  }
  
  throw lastError!;
}

// Usage
const data = await withRetry(() => fetchUser(userId), {
  maxRetries: 5,
  shouldRetry: (error) => error.status >= 500 || error.code === 'NETWORK_ERROR',
});
```

### 8.2 Circuit Breaker Pattern

```typescript
// lib/circuitBreaker.ts
interface CircuitBreakerOptions {
  failureThreshold?: number;
  resetTimeout?: number;
  monitoringPeriod?: number;
}

class CircuitBreaker {
  private failures = 0;
  private nextAttempt = Date.now();
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  
  constructor(
    private fn: () => Promise<any>,
    private options: CircuitBreakerOptions = {}
  ) {
    this.options = {
      failureThreshold: 5,
      resetTimeout: 60000,
      monitoringPeriod: 60000,
      ...options,
    };
  }
  
  async execute(): Promise<any> {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const result = await this.fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }
  
  private onFailure() {
    this.failures++;
    if (this.failures >= this.options.failureThreshold!) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.options.resetTimeout!;
    }
  }
  
  getState() {
    return this.state;
  }
}

// Usage with TanStack Query
const breaker = new CircuitBreaker(() => fetchCriticalData(), {
  failureThreshold: 3,
  resetTimeout: 30000,
});

useQuery({
  queryKey: ['critical'],
  queryFn: () => breaker.execute(),
  retry: false, // Handle retry in circuit breaker
});
```

---

## 9. File Uploads

### 9.1 Drag and Drop Upload

```tsx
// components/FileUpload.tsx
import { useCallback, useState } from 'react';
import { useDropzone } from 'react-dropzone';

interface FileUploadProps {
  onUpload: (files: File[]) => Promise<void>;
  accept?: Record<string, string[]>;
  maxSize?: number;
  maxFiles?: number;
}

export function FileUpload({ onUpload, accept, maxSize = 5 * 1024 * 1024, maxFiles = 5 }: FileUploadProps) {
  const [uploadProgress, setUploadProgress] = useState<Record<string, number>>({});
  const [errors, setErrors] = useState<string[]>([]);
  
  const onDrop = useCallback(
    async (acceptedFiles: File[], rejectedFiles: any[]) => {
      setErrors(rejectedFiles.map((f) => f.errors.map((e: any) => e.message).join(', ')));
      
      if (acceptedFiles.length === 0) return;
      
      // Upload with progress tracking
      for (const file of acceptedFiles) {
        const formData = new FormData();
        formData.append('file', file);
        
        await fetch('/api/upload', {
          method: 'POST',
          body: formData,
          headers: {
            'X-Upload-Id': file.name,
          },
          // Track progress via XMLHttpRequest if needed
        });
      }
      
      await onUpload(acceptedFiles);
    },
    [onUpload]
  );
  
  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept,
    maxSize,
    maxFiles,
  });
  
  return (
    <div {...getRootProps()} className={`dropzone ${isDragActive ? 'active' : ''}`}>
      <input {...getInputProps()} />
      {isDragActive ? (
        <p>Drop the files here...</p>
      ) : (
        <p>Drag and drop files here, or click to select</p>
      )}
      {Object.entries(uploadProgress).map(([name, progress]) => (
        <div key={name}>
          <span>{name}</span>
          <progress value={progress} max={100} />
        </div>
      ))}
      {errors.map((error, i) => (
        <p key={i} className="error">{error}</p>
      ))}
    </div>
  );
}
```

### 9.2 Multipart Upload with Progress

```typescript
// lib/upload.ts
export async function uploadWithProgress(
  file: File,
  onProgress: (progress: number) => void
): Promise<{ url: string }> {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    formData.append('file', file);
    
    xhr.upload.addEventListener('progress', (event) => {
      if (event.lengthComputable) {
        onProgress(Math.round((event.loaded / event.total) * 100));
      }
    });
    
    xhr.addEventListener('load', () => {
      if (xhr.status === 200) {
        resolve(JSON.parse(xhr.responseText));
      } else {
        reject(new Error(`Upload failed: ${xhr.statusText}`));
      }
    });
    
    xhr.addEventListener('error', () => reject(new Error('Upload failed')));
    xhr.open('POST', '/api/upload');
    xhr.send(formData);
  });
}

// Presigned URL upload (S3)
export async function uploadToS3(file: File, presignedUrl: string) {
  await fetch(presignedUrl, {
    method: 'PUT',
    body: file,
    headers: { 'Content-Type': file.type },
  });
}
```

---

## 10. Real-Time Updates

### 10.1 Server-Sent Events (SSE)

```typescript
// hooks/useSSE.ts
import { useEffect, useRef, useState } from 'react';

export function useSSE<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const eventSourceRef = useRef<EventSource | null>(null);
  
  useEffect(() => {
    const eventSource = new EventSource(url);
    eventSourceRef.current = eventSource;
    
    eventSource.onmessage = (event) => {
      try {
        const parsed = JSON.parse(event.data);
        setData(parsed);
      } catch (e) {
        setData(event.data as any);
      }
    };
    
    eventSource.onerror = (error) => {
      setError(new Error('SSE connection error'));
      eventSource.close();
    };
    
    return () => {
      eventSource.close();
      eventSourceRef.current = null;
    };
  }, [url]);
  
  const reconnect = () => {
    eventSourceRef.current?.close();
    // Reconnect logic
  };
  
  return { data, error, reconnect };
}

// Usage
function LiveNotifications() {
  const { data: notification } = useSSE<Notification>('/api/notifications/stream');
  
  if (!notification) return null;
  
  return (
    <div className="notification-toast">
      <p>{notification.message}</p>
    </div>
  );
}
```

### 10.2 WebSocket with Socket.io-client

```typescript
// lib/socket.ts
import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!socket) {
    socket = io(process.env.NEXT_PUBLIC_SOCKET_URL!, {
      transports: ['websocket'],
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
    });
  }
  return socket;
}

export function disconnectSocket() {
  socket?.disconnect();
  socket = null;
}

// hooks/useSocket.ts
import { useEffect, useState } from 'react';
import { getSocket } from '@/lib/socket';

export function useSocket<T>(event: string) {
  const [data, setData] = useState<T | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  
  useEffect(() => {
    const socket = getSocket();
    
    socket.on('connect', () => setIsConnected(true));
    socket.on('disconnect', () => setIsConnected(false));
    socket.on(event, (payload: T) => setData(payload));
    
    return () => {
      socket.off(event);
    };
  }, [event]);
  
  const emit = (payload: any) => {
    getSocket().emit(event, payload);
  };
  
  return { data, isConnected, emit };
}

// Usage in component
function ChatRoom({ roomId }: { roomId: string }) {
  const { data: message, emit } = useSocket<Message>('message');
  const [messages, setMessages] = useState<Message[]>([]);
  
  useEffect(() => {
    if (message) setMessages((prev) => [...prev, message]);
  }, [message]);
  
  const sendMessage = (text: string) => {
    emit({ roomId, text, timestamp: Date.now() });
  };
  
  return (
    <div>
      {messages.map((msg) => (
        <MessageBubble key={msg.id} message={msg} />
      ))}
      <MessageInput onSend={sendMessage} />
    </div>
  );
}
```

### 10.3 Reconnection Handling

```typescript
// Enhanced socket hook with reconnection
export function useSocketWithReconnect<T>(event: string, options: { maxRetries?: number } = {}) {
  const [data, setData] = useState<T | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const [status, setStatus] = useState<'connecting' | 'connected' | 'disconnected' | 'error'>('connecting');
  
  useEffect(() => {
    const socket = getSocket();
    
    const onConnect = () => {
      setStatus('connected');
      setRetryCount(0);
    };
    
    const onDisconnect = (reason: string) => {
      setStatus('disconnected');
      if (reason === 'io server disconnect') {
        // Server forced disconnect, manual reconnect needed
        setTimeout(() => socket.connect(), 1000);
      }
    };
    
    const onConnectError = (error: Error) => {
      setStatus('error');
      setRetryCount((prev) => {
        if (prev < (options.maxRetries ?? 5)) {
          setTimeout(() => socket.connect(), 1000 * 2 ** prev);
          return prev + 1;
        }
        return prev;
      });
    };
    
    socket.on('connect', onConnect);
    socket.on('disconnect', onDisconnect);
    socket.on('connect_error', onConnectError);
    socket.on(event, (payload: T) => setData(payload));
    
    return () => {
      socket.off('connect', onConnect);
      socket.off('disconnect', onDisconnect);
      socket.off('connect_error', onConnectError);
      socket.off(event);
    };
  }, [event, options.maxRetries]);
  
  return { data, status, retryCount };
}
```

---

## 11. GraphQL Client

### 11.1 Apollo Client Setup

```typescript
// lib/apollo-client.ts
import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';

const httpLink = createHttpLink({
  uri: process.env.NEXT_PUBLIC_GRAPHQL_URL,
});

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('token');
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : '',
    },
  };
});

export const apolloClient = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          posts: {
            keyArgs: ['filter'],
            merge(existing = [], incoming) {
              return [...existing, ...incoming];
            },
          },
        },
      },
    },
  }),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
    },
  },
});
```

### 11.2 Queries and Mutations

```tsx
// Queries
import { gql, useQuery, useMutation } from '@apollo/client';

const GET_USER = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
      posts {
        id
        title
      }
    }
  }
`;

const UPDATE_USER = gql`
  mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
    updateUser(id: $id, input: $input) {
      id
      name
      email
    }
  }
`;

function UserProfile({ userId }: { userId: string }) {
  const { data, loading, error } = useQuery(GET_USER, {
    variables: { id: userId },
  });
  
  const [updateUser] = useMutation(UPDATE_USER, {
    update: (cache, { data }) => {
      cache.writeQuery({
        query: GET_USER,
        variables: { id: userId },
        data: { user: data.updateUser },
      });
    },
  });
  
  if (loading) return <Skeleton />;
  if (error) return <Error error={error} />;
  
  return (
    <div>
      <h1>{data.user.name}</h1>
      <button onClick={() => updateUser({ variables: { id: userId, input: { name: 'New Name' } } })}>
        Update
      </button>
    </div>
  );
}
```

### 11.3 Fragments

```tsx
// fragments.ts
export const UserFragment = gql`
  fragment UserFields on User {
    id
    name
    email
    avatar
  }
`;

export const PostFragment = gql`
  fragment PostFields on Post {
    id
    title
    content
    author {
      ...UserFields
    }
  }
  ${UserFragment}
`;

// Usage in query
const GET_POSTS = gql`
  query GetPosts {
    posts {
      ...PostFields
    }
  }
  ${PostFragment}
`;
```

### 11.4 urql Alternative (Lightweight)

```typescript
// lib/urql-client.ts
import { createClient, dedupExchange, fetchExchange, cacheExchange } from 'urql';

export const urqlClient = createClient({
  url: process.env.NEXT_PUBLIC_GRAPHQL_URL!,
  exchanges: [dedupExchange, cacheExchange, fetchExchange],
  fetchOptions: () => {
    const token = localStorage.getItem('token');
    return {
      headers: { authorization: token ? `Bearer ${token}` : '' },
    };
  },
});

// Usage
import { useQuery } from 'urql';

const [result] = useQuery({
  query: GET_USER,
  variables: { id: userId },
});

const { data, fetching, error } = result;
```

---

## Quick Reference: API Integration Checklist

### Data Fetching
- [ ] Use TanStack Query or SWR for server state
- [ ] Implement proper loading and error states
- [ ] Add retry logic for transient failures
- [ ] Set appropriate staleTime and cacheTime
- [ ] Use prefetching for route preloading

### Error Handling
- [ ] Implement error boundaries for crash recovery
- [ ] Show user-friendly error messages
- [ ] Log errors to monitoring service
- [ ] Handle network errors separately from API errors
- [ ] Implement offline state detection

### Performance
- [ ] Normalize data for efficient updates
- [ ] Implement pagination for large lists
- [ ] Use optimistic updates for mutations
- [ ] Cache API responses appropriately
- [ ] Debounce search/filter requests

### Real-Time
- [ ] Choose SSE for server-to-client only
- [ ] Use WebSockets for bidirectional communication
- [ ] Implement reconnection with exponential backoff
- [ ] Handle connection state in UI
- [ ] Clean up subscriptions on unmount
