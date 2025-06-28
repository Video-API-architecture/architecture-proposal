# Frontend Architecture Overview

## Table of Contents
- [Project Structure](#project-structure)
- [Directory Structure](#directory-structure)
- [Pages Architecture](#pages-architecture)
- [Component Architecture](#component-architecture)
- [Hooks Architecture](#hooks-architecture)
- [State Management Strategy](#state-management-strategy)
- [API Integration Strategy](#api-integration-strategy)
- [Build & Deployment](#build--deployment)
- [Video/Chime SDK Integration](#videochime-sdk-integration)

## Project Structure

The frontend is built with **React 18**, **TypeScript**, and **Vite**, using a modern component-based architecture with the following key technologies:

<details>
<summary><strong>🔧 Core Technologies</strong></summary>

- **React 18** with Hooks and Functional Components
- **TypeScript** for type safety
- **Vite** for fast development and building
- **React Router DOM** for client-side routing
- **TanStack React Query** for server state management
- **Tailwind CSS** for styling
- **Radix UI** for accessible component primitives
- **Shadcn/ui** for pre-built component library
- **React Hook Form** for form management
- **Zod** for schema validation

</details>

## Directory Structure

<details>
<summary><strong>📁 Directory Structure</strong></summary>

```
src/
├── components/          # Reusable UI components
│   ├── ui/             # Shadcn/ui components
│   ├── AdminSidebar.tsx
│   ├── PropertyForm.tsx
│   └── TourNavigation.tsx
├── hooks/              # Custom React hooks
│   ├── use-mobile.tsx
│   └── use-toast.ts
├── lib/                # Utility functions
│   └── utils.ts
├── pages/              # Page components (routes)
│   ├── Index.tsx
│   ├── SignIn.tsx
│   ├── SignUp.tsx
│   ├── AdminDashboard.tsx
│   ├── AdminProperties.tsx
│   └── ... (other pages)
├── App.tsx             # Main app component with routing
├── main.tsx           # App entry point
└── index.css          # Global styles
```

</details>

## Pages Architecture

<details>
<summary><strong>🌐 Public Pages</strong></summary>

- **`Index.tsx`** - Landing page with marketing content
- **`SignIn.tsx`** - User authentication
- **`SignUp.tsx`** - User registration
- **`ForgotPassword.tsx`** - Password recovery
- **`Property.tsx`** - Public property viewing
- **`BookTour.tsx`** - Tour booking interface
- **`PropertyBooking.tsx`** - Property-specific booking

</details>

<details>
<summary><strong>👨‍💼 Admin Pages</strong></summary>

- **`AdminDashboard.tsx`** - Main admin dashboard with metrics
- **`AdminProperties.tsx`** - Property management
- **`PropertyNew.tsx`** - Create new property
- **`PropertyView.tsx`** - View property details
- **`PropertyEdit.tsx`** - Edit property
- **`AdminTourAppointments.tsx`** - Tour appointment management
- **`AdminUsers.tsx`** - User management
- **`AdminUserEdit.tsx`** - Create/edit users

</details>

<details>
<summary>🏠 Tour Pages</summary>

- **`RemoteTourLibrary.tsx`** - Tour library/archive
- **`TourDetail.tsx`** - Individual tour details

</details>

## Component Architecture

<details>
<summary><strong>🎨 UI Components (`components/ui/`)</strong></summary>

Built on **Radix UI** primitives with **Shadcn/ui** styling:

- **Layout**: `sidebar.tsx`, `sheet.tsx`, `drawer.tsx`
- **Forms**: `form.tsx`, `input.tsx`, `button.tsx`, `select.tsx`
- **Feedback**: `toast.tsx`, `alert.tsx`, `badge.tsx`
- **Navigation**: `tabs.tsx`, `breadcrumb.tsx`, `pagination.tsx`
- **Data Display**: `table.tsx`, `card.tsx`, `avatar.tsx`
- **Overlays**: `dialog.tsx`, `popover.tsx`, `tooltip.tsx`

</details>

<details>
<summary><strong>🔧 Custom Components</strong></summary>

- **`AdminSidebar.tsx`** - Navigation sidebar for admin pages
- **`PropertyForm.tsx`** - Reusable property creation/editing form
- **`TourNavigation.tsx`** - Tour-specific navigation component

</details>

## Hooks Architecture

<details>
<summary><strong>🎣 Custom Hooks</strong></summary>

- **`use-mobile.tsx`** - Responsive design hook for mobile detection
- **`use-toast.ts`** - Toast notification management

### Recommended Additional Hooks
```typescript
// hooks/use-api.ts
export const useApi = () => {
  // API client configuration
};

// hooks/use-auth.ts
export const useAuth = () => {
  // Authentication state management
};

// hooks/use-properties.ts
export const useProperties = () => {
  // Property data management with React Query
};

// hooks/use-tours.ts
export const useTours = () => {
  // Tour data management
};
```

</details>

## State Management Strategy

<details>
<summary><strong>📊 React Query (TanStack Query)</strong></summary>

For server state management:
- **Caching** - Automatic caching of API responses
- **Background updates** - Keep data fresh
- **Optimistic updates** - Immediate UI feedback
- **Error handling** - Built-in error states

</details>

<details>
<summary><strong>🌍 Context API</strong></summary>

For global application state:
- **Authentication** - User session and permissions
- **Theme** - Dark/light mode preferences
- **Notifications** - Global notification state

</details>

<details>
<summary>🏠 Local State</summary>

For component-specific state:
- **Form state** - Using React Hook Form
- **UI state** - Modal open/close, loading states
- **Component interactions** - Local component behavior

</details>

## API Integration Strategy

<details>
<summary><strong>🔧 Recommended API Client Setup</strong></summary>

```typescript
// lib/api-client.ts
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for authentication
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('auth_token');
      window.location.href = '/signin';
    }
    return Promise.reject(error);
  }
);
```

</details>

<details>
<summary><strong>📡 API Service Modules</strong></summary>

```typescript
// services/auth.service.ts
export const authService = {
  login: (credentials: LoginCredentials) => 
    apiClient.post('/auth/login', credentials),
  
  register: (userData: RegisterData) => 
    apiClient.post('/auth/register', userData),
  
  forgotPassword: (email: string) => 
    apiClient.post('/auth/password-reset/request', { email }),
  
  resetPassword: (token: string, password: string) => 
    apiClient.post('/auth/password-reset/confirm', { token, password }),
};

// services/properties.service.ts
export const propertiesService = {
  getAll: (params?: PropertyFilters) => 
    apiClient.get('/properties', { params }),
  
  getById: (id: string) => 
    apiClient.get(`/properties/${id}`),
  
  create: (property: CreatePropertyData) => 
    apiClient.post('/properties', property),
  
  update: (id: string, property: UpdatePropertyData) => 
    apiClient.put(`/properties/${id}`, property),
  
  delete: (id: string) => 
    apiClient.delete(`/properties/${id}`),
  
  uploadImages: (id: string, images: File[]) => {
    const formData = new FormData();
    images.forEach(image => formData.append('images[]', image));
    return apiClient.post(`/properties/${id}/images`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  }
};

// services/bookings.service.ts
export const bookingsService = {
  getAll: (params?: BookingFilters) => 
    apiClient.get('/bookings', { params }),
  
  getById: (id: string) => 
    apiClient.get(`/bookings/${id}`),
  
  create: (booking: CreateBookingData) => 
    apiClient.post('/bookings', booking),
  
  update: (id: string, booking: UpdateBookingData) => 
    apiClient.put(`/bookings/${id}`, booking),
  
  cancel: (id: string) => 
    apiClient.delete(`/bookings/${id}`),
};

// services/tours.service.ts
export const toursService = {
  getAll: (params?: TourFilters) => 
    apiClient.get('/tours', { params }),
  
  getById: (id: string) => 
    apiClient.get(`/tours/${id}`),
  
  start: (id: string) => 
    apiClient.post(`/tours/${id}/start`),
  
  end: (id: string) => 
    apiClient.post(`/tours/${id}/end`),
  
  getNotes: (id: string) => 
    apiClient.get(`/tours/${id}/notes`),
  
  addNote: (id: string, note: CreateNoteData) => 
    apiClient.post(`/tours/${id}/notes`, note),
};
```

</details>

## Form Management

<details>
<summary><strong>📝 React Hook Form Integration</strong></summary>

```typescript
// components/PropertyForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { propertySchema } from '../schemas/property';

interface PropertyFormProps {
  property?: Property;
  onSubmit: (data: PropertyFormData) => void;
  onCancel: () => void;
}

export const PropertyForm: React.FC<PropertyFormProps> = ({
  property,
  onSubmit,
  onCancel
}) => {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset
  } = useForm<PropertyFormData>({
    resolver: zodResolver(propertySchema),
    defaultValues: property || {
      address: '',
      price: '',
      bedrooms: '',
      bathrooms: '',
      sqft: '',
      description: ''
    }
  });

  const onSubmitHandler = async (data: PropertyFormData) => {
    try {
      await onSubmit(data);
      reset();
    } catch (error) {
      console.error('Form submission error:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmitHandler)} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <Label htmlFor="address">Address</Label>
          <Input
            id="address"
            {...register('address')}
            placeholder="123 Main St, City, State"
          />
          {errors.address && (
            <p className="text-sm text-red-600">{errors.address.message}</p>
          )}
        </div>

        <div>
          <Label htmlFor="price">Price</Label>
          <Input
            id="price"
            type="number"
            {...register('price')}
            placeholder="500000"
          />
          {errors.price && (
            <p className="text-sm text-red-600">{errors.price.message}</p>
          )}
        </div>

        <div>
          <Label htmlFor="bedrooms">Bedrooms</Label>
          <Input
            id="bedrooms"
            type="number"
            {...register('bedrooms')}
            placeholder="3"
          />
          {errors.bedrooms && (
            <p className="text-sm text-red-600">{errors.bedrooms.message}</p>
          )}
        </div>

        <div>
          <Label htmlFor="bathrooms">Bathrooms</Label>
          <Input
            id="bathrooms"
            type="number"
            {...register('bathrooms')}
            placeholder="2"
          />
          {errors.bathrooms && (
            <p className="text-sm text-red-600">{errors.bathrooms.message}</p>
          )}
        </div>

        <div>
          <Label htmlFor="sqft">Square Feet</Label>
          <Input
            id="sqft"
            type="number"
            {...register('sqft')}
            placeholder="2000"
          />
          {errors.sqft && (
            <p className="text-sm text-red-600">{errors.sqft.message}</p>
          )}
        </div>
      </div>

      <div>
        <Label htmlFor="description">Description</Label>
        <Textarea
          id="description"
          {...register('description')}
          placeholder="Describe the property..."
          rows={4}
        />
        {errors.description && (
          <p className="text-sm text-red-600">{errors.description.message}</p>
        )}
      </div>

      <div className="flex justify-end space-x-4">
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Saving...' : 'Save Property'}
        </Button>
      </div>
    </form>
  );
};
```

</details>

<details>
<summary><strong>✅ Schema Validation</strong></summary>

```typescript
// schemas/property.ts
import { z } from 'zod';

export const propertySchema = z.object({
  address: z.string().min(1, 'Address is required'),
  price: z.string().min(1, 'Price is required'),
  bedrooms: z.string().min(1, 'Number of bedrooms is required'),
  bathrooms: z.string().min(1, 'Number of bathrooms is required'),
  sqft: z.string().min(1, 'Square footage is required'),
  description: z.string().optional()
});

export type PropertyFormData = z.infer<typeof propertySchema>;

// schemas/booking.ts
export const bookingSchema = z.object({
  propertyId: z.string().min(1, 'Property is required'),
  scheduledAt: z.string().min(1, 'Date and time is required'),
  durationMinutes: z.number().min(15).max(120),
  notes: z.string().optional()
});

export type BookingFormData = z.infer<typeof bookingSchema>;

// schemas/auth.ts
export const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters')
});

export const registerSchema = z.object({
  fullName: z.string().min(1, 'Full name is required'),
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  confirmPassword: z.string()
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"]
});
```

</details>

## Routing & Navigation

<details>
<summary><strong>🧭 React Router Setup</strong></summary>

```typescript
// App.tsx
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from './components/ui/toaster';

// Pages
import Index from './pages/Index';
import SignIn from './pages/SignIn';
import SignUp from './pages/SignUp';
import ForgotPassword from './pages/ForgotPassword';
import Property from './pages/Property';
import BookTour from './pages/BookTour';
import PropertyBooking from './pages/PropertyBooking';
import AdminDashboard from './pages/AdminDashboard';
import AdminProperties from './pages/AdminProperties';
import PropertyNew from './pages/PropertyNew';
import PropertyView from './pages/PropertyView';
import PropertyEdit from './pages/PropertyEdit';
import AdminTourAppointments from './pages/AdminTourAppointments';
import AdminUsers from './pages/AdminUsers';
import AdminUserEdit from './pages/AdminUserEdit';
import RemoteTourLibrary from './pages/RemoteTourLibrary';
import TourDetail from './pages/TourDetail';
import NotFound from './pages/NotFound';

// Components
import ProtectedRoute from './components/ProtectedRoute';
import AdminRoute from './components/AdminRoute';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <div className="min-h-screen bg-background">
<Routes>
  {/* Public Routes */}
  <Route path="/" element={<Index />} />
  <Route path="/signin" element={<SignIn />} />
  <Route path="/signup" element={<SignUp />} />
  <Route path="/forgot-password" element={<ForgotPassword />} />
  <Route path="/property/:id" element={<Property />} />
            <Route path="/book-tour" element={<BookTour />} />
            <Route path="/property/:id/book" element={<PropertyBooking />} />

            {/* Protected Routes */}
            <Route element={<ProtectedRoute />}>
              <Route path="/tour-library" element={<RemoteTourLibrary />} />
              <Route path="/tour/:id" element={<TourDetail />} />
            </Route>
  
  {/* Admin Routes */}
            <Route element={<AdminRoute />}>
              <Route path="/admin" element={<AdminDashboard />} />
  <Route path="/admin/properties" element={<AdminProperties />} />
  <Route path="/admin/properties/new" element={<PropertyNew />} />
  <Route path="/admin/properties/:id" element={<PropertyView />} />
  <Route path="/admin/properties/:id/edit" element={<PropertyEdit />} />
  <Route path="/admin/tours" element={<AdminTourAppointments />} />
  <Route path="/admin/users" element={<AdminUsers />} />
  <Route path="/admin/users/new" element={<AdminUserEdit />} />
  <Route path="/admin/users/:id/edit" element={<AdminUserEdit />} />
            </Route>

            {/* 404 Route */}
  <Route path="*" element={<NotFound />} />
</Routes>
        </div>
        <Toaster />
      </Router>
    </QueryClientProvider>
  );
}

export default App;
```

</details>

<details>
<summary><strong>🛡️ Route Protection</strong></summary>

```typescript
// components/ProtectedRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/use-auth';

const ProtectedRoute = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <Navigate to="/signin" replace />;
  }

  return <Outlet />;
};

// components/AdminRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/use-auth';

const AdminRoute = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <Navigate to="/signin" replace />;
  }

  if (user.role !== 'admin' && user.role !== 'realtor') {
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
};
```

</details>

## Styling & Design System

<details>
<summary><strong>🎨 Tailwind CSS Configuration</strong></summary>

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: ['class'],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  prefix: '',
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
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
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
};

export default config;
```

</details>

<details>
<summary><strong>🎯 Design Tokens</strong></summary>

```css
/* index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 84% 4.9%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 224.3 76.3% 94.1%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
```

</details>

## Performance Optimization

<details>
<summary><strong>⚡ Code Splitting</strong></summary>

```typescript
// Lazy loading for better performance
import { lazy, Suspense } from 'react';

// Lazy load admin pages
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));
const AdminProperties = lazy(() => import('./pages/AdminProperties'));
const AdminUsers = lazy(() => import('./pages/AdminUsers'));

// Loading component
const LoadingSpinner = () => (
  <div className="flex items-center justify-center min-h-screen">
    <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary"></div>
  </div>
);

// Wrap lazy components with Suspense
<Suspense fallback={<LoadingSpinner />}>
  <AdminDashboard />
</Suspense>
```

</details>

<details>
<summary><strong>🖼️ Image Optimization</strong></summary>

```typescript
// components/OptimizedImage.tsx
import { useState } from 'react';

interface OptimizedImageProps {
  src: string;
  alt: string;
  className?: string;
  placeholder?: string;
}

export const OptimizedImage: React.FC<OptimizedImageProps> = ({
  src,
  alt,
  className,
  placeholder = '/placeholder.svg'
}) => {
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);

  return (
    <div className={`relative overflow-hidden ${className}`}>
      {isLoading && (
        <div className="absolute inset-0 bg-gray-200 animate-pulse" />
      )}
      <img
        src={hasError ? placeholder : src}
        alt={alt}
        className={`w-full h-full object-cover transition-opacity duration-300 ${
          isLoading ? 'opacity-0' : 'opacity-100'
        }`}
        onLoad={() => setIsLoading(false)}
        onError={() => {
          setHasError(true);
          setIsLoading(false);
        }}
        loading="lazy"
      />
    </div>
  );
};
```

</details>

<details>
<summary><strong>💾 Caching Strategy</strong></summary>

```typescript
// hooks/use-cached-query.ts
import { useQuery, UseQueryOptions } from '@tanstack/react-query';

export const useCachedQuery = <T>(
  queryKey: string[],
  queryFn: () => Promise<T>,
  options?: UseQueryOptions<T>
) => {
  return useQuery({
    queryKey,
    queryFn,
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    ...options,
  });
};

// Usage example
const { data: properties } = useCachedQuery(
  ['properties', filters],
  () => propertiesService.getAll(filters),
  {
    enabled: !!filters,
  }
);
```

</details>

## Error Handling

<details>
<summary><strong>🚨 Error Boundaries</strong></summary>

```typescript
// components/ErrorBoundary.tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
    // Send to error reporting service
  }

  public render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="min-h-screen flex items-center justify-center">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                Something went wrong
              </h2>
              <p className="text-gray-600 mb-4">
                We're sorry, but something unexpected happened.
              </p>
              <button
                onClick={() => window.location.reload()}
                className="bg-primary text-primary-foreground px-4 py-2 rounded hover:bg-primary/90"
              >
                Reload Page
              </button>
            </div>
          </div>
        )
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
```

</details>

<details>
<summary><strong>📝 Error Handling Hooks</strong></summary>

```typescript
// hooks/use-error-handler.ts
import { useCallback } from 'react';
import { useToast } from './use-toast';

export const useErrorHandler = () => {
  const { toast } = useToast();

  const handleError = useCallback((error: unknown) => {
    console.error('Error:', error);

    let message = 'An unexpected error occurred';

    if (error instanceof Error) {
      message = error.message;
    } else if (typeof error === 'string') {
      message = error;
    } else if (error && typeof error === 'object' && 'message' in error) {
      message = String(error.message);
    }

    toast({
      title: 'Error',
      description: message,
      variant: 'destructive',
    });
  }, [toast]);

  return { handleError };
};

// Usage in components
const { handleError } = useErrorHandler();

const handleSubmit = async (data: FormData) => {
  try {
    await submitData(data);
    toast({ title: 'Success', description: 'Data saved successfully' });
  } catch (error) {
    handleError(error);
  }
};
```

</details>

## Testing Strategy

<details>
<summary><strong>🧪 Testing Setup</strong></summary>

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    globals: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});

// src/test/setup.ts
import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Mock IntersectionObserver
global.IntersectionObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}));

// Mock ResizeObserver
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}));
```

</details>

<details>
<summary><strong>🔧 Component Testing</strong></summary>

```typescript
// components/PropertyForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { PropertyForm } from './PropertyForm';
import { vi } from 'vitest';

describe('PropertyForm', () => {
  const mockOnSubmit = vi.fn();
  const mockOnCancel = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders form fields correctly', () => {
    render(
      <PropertyForm onSubmit={mockOnSubmit} onCancel={mockOnCancel} />
    );

    expect(screen.getByLabelText(/address/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/price/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/bedrooms/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/bathrooms/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/square feet/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/description/i)).toBeInTheDocument();
  });

  it('validates required fields', async () => {
    render(
      <PropertyForm onSubmit={mockOnSubmit} onCancel={mockOnCancel} />
    );

    const submitButton = screen.getByRole('button', { name: /save property/i });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(screen.getByText(/address is required/i)).toBeInTheDocument();
      expect(screen.getByText(/price is required/i)).toBeInTheDocument();
    });

    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  it('submits form with valid data', async () => {
    render(
      <PropertyForm onSubmit={mockOnSubmit} onCancel={mockOnCancel} />
    );

    fireEvent.change(screen.getByLabelText(/address/i), {
      target: { value: '123 Main St' },
    });
    fireEvent.change(screen.getByLabelText(/price/i), {
      target: { value: '500000' },
    });
    fireEvent.change(screen.getByLabelText(/bedrooms/i), {
      target: { value: '3' },
    });
    fireEvent.change(screen.getByLabelText(/bathrooms/i), {
      target: { value: '2' },
    });
    fireEvent.change(screen.getByLabelText(/square feet/i), {
      target: { value: '2000' },
    });

    const submitButton = screen.getByRole('button', { name: /save property/i });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        address: '123 Main St',
        price: '500000',
        bedrooms: '3',
        bathrooms: '2',
        sqft: '2000',
        description: '',
      });
    });
  });
});
```

</details>

## Build & Deployment

<details>
<summary><strong>⚙️ Vite Configuration</strong></summary>

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
});
```

</details>

<details>
<summary><strong>🚀 Deployment Configuration</strong></summary>

```yaml
# .github/workflows/deploy.yml
name: Deploy Frontend

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
        env:
          VITE_API_BASE_URL: ${{ secrets.VITE_API_BASE_URL }}
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

</details>

<details>
<summary>Video/Chime SDK Integration</summary>

### Overview

The RealtyForYou frontend uses the [Amazon Chime SDK](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html) to power real-time video tours, including audio, video, and screen sharing for web and mobile clients.

---

### Frontend (React/React Native) Responsibilities

- **SDK Usage:**  
  - Use [Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js) (web) or [React Native wrapper](https://github.com/aws/amazon-chime-sdk-component-library-react-native) (mobile).
- **Joining a Meeting:**  
  - Receive `Meeting` and `Attendee` objects from backend.
  - Use SDK to join and manage the session.

**Example (JS):**
```js
const meetingSessionConfiguration = new MeetingSessionConfiguration(meeting, attendee);
const meetingSession = new DefaultMeetingSession(meetingSessionConfiguration, logger, deviceController);
await meetingSession.audioVideo.start();
```

---

### References

- [Chime SDK API Reference](https://docs.aws.amazon.com/chime-sdk/latest/APIReference/welcome.html)
- [Chime SDK Developer Guide](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html)

</details>

This comprehensive frontend architecture provides a modern, scalable foundation for the real estate video tour platform with proper state management, form handling, routing, and performance optimizations.