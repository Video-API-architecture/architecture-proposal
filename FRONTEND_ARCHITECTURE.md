# Frontend Architecture Overview

## Project Structure

The frontend is built with **React 18**, **TypeScript**, and **Vite**, using a modern component-based architecture with the following key technologies:

### Core Technologies
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

## Directory Structure

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

## Pages Architecture

### Public Pages
- **`Index.tsx`** - Landing page with marketing content
- **`SignIn.tsx`** - User authentication
- **`SignUp.tsx`** - User registration
- **`ForgotPassword.tsx`** - Password recovery
- **`Property.tsx`** - Public property viewing
- **`BookTour.tsx`** - Tour booking interface
- **`PropertyBooking.tsx`** - Property-specific booking

### Admin Pages
- **`AdminDashboard.tsx`** - Main admin dashboard with metrics
- **`AdminProperties.tsx`** - Property management
- **`PropertyNew.tsx`** - Create new property
- **`PropertyView.tsx`** - View property details
- **`PropertyEdit.tsx`** - Edit property
- **`AdminTourAppointments.tsx`** - Tour appointment management
- **`AdminUsers.tsx`** - User management
- **`AdminUserEdit.tsx`** - Create/edit users

### Tour Pages
- **`RemoteTourLibrary.tsx`** - Tour library/archive
- **`TourDetail.tsx`** - Individual tour details

## Component Architecture

### UI Components (`components/ui/`)
Built on **Radix UI** primitives with **Shadcn/ui** styling:

- **Layout**: `sidebar.tsx`, `sheet.tsx`, `drawer.tsx`
- **Forms**: `form.tsx`, `input.tsx`, `button.tsx`, `select.tsx`
- **Feedback**: `toast.tsx`, `alert.tsx`, `badge.tsx`
- **Navigation**: `tabs.tsx`, `breadcrumb.tsx`, `pagination.tsx`
- **Data Display**: `table.tsx`, `card.tsx`, `avatar.tsx`
- **Overlays**: `dialog.tsx`, `popover.tsx`, `tooltip.tsx`

### Custom Components
- **`AdminSidebar.tsx`** - Navigation sidebar for admin pages
- **`PropertyForm.tsx`** - Reusable property creation/editing form
- **`TourNavigation.tsx`** - Tour-specific navigation component

## Hooks Architecture

### Custom Hooks
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

## State Management Strategy

### 1. React Query (TanStack Query)
For server state management:
- **Caching** - Automatic caching of API responses
- **Background updates** - Keep data fresh
- **Optimistic updates** - Immediate UI feedback
- **Error handling** - Built-in error states

### 2. Context API
For global application state:
- **Authentication** - User session and permissions
- **Theme** - Dark/light mode preferences
- **Notifications** - Global notification state

### 3. Local State
For component-specific state:
- **Form state** - Using React Hook Form
- **UI state** - Modal open/close, loading states
- **Component interactions** - Local component behavior

## API Integration Strategy

### Recommended API Client Setup

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

### API Service Modules

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
  getProperties: (params?: PropertyFilters) => 
    apiClient.get('/properties', { params }),
  
  getProperty: (id: string) => 
    apiClient.get(`/properties/${id}`),
  
  createProperty: (propertyData: CreatePropertyData) => 
    apiClient.post('/properties', propertyData),
  
  updateProperty: (id: string, propertyData: UpdatePropertyData) => 
    apiClient.patch(`/properties/${id}`, propertyData),
  
  deleteProperty: (id: string) => 
    apiClient.delete(`/properties/${id}`),
  
  uploadImages: (propertyId: string, images: File[]) => {
    const formData = new FormData();
    images.forEach(image => formData.append('images[]', image));
    return apiClient.post(`/properties/${propertyId}/upload/images`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
};

// services/bookings.service.ts
export const bookingsService = {
  getBookings: (params?: BookingFilters) => 
    apiClient.get('/bookings', { params }),
  
  createBooking: (bookingData: CreateBookingData) => 
    apiClient.post('/bookings', bookingData),
  
  updateBooking: (id: string, bookingData: UpdateBookingData) => 
    apiClient.patch(`/bookings/${id}`, bookingData),
  
  cancelBooking: (id: string) => 
    apiClient.delete(`/bookings/${id}`),
};

// services/calls.service.ts
export const callsService = {
  createCall: (callData: CreateCallData) => 
    apiClient.post('/calls', callData),
  
  joinCall: (callId: string) => 
    apiClient.post(`/calls/${callId}/join`),
  
  endCall: (callId: string) => 
    apiClient.post(`/calls/${callId}/end`),
};
```

### React Query Integration

```typescript
// hooks/use-properties.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { propertiesService } from '@/services/properties.service';

export const useProperties = (filters?: PropertyFilters) => {
  return useQuery({
    queryKey: ['properties', filters],
    queryFn: () => propertiesService.getProperties(filters),
  });
};

export const useProperty = (id: string) => {
  return useQuery({
    queryKey: ['property', id],
    queryFn: () => propertiesService.getProperty(id),
    enabled: !!id,
  });
};

export const useCreateProperty = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: propertiesService.createProperty,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['properties'] });
    },
  });
};

export const useUpdateProperty = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdatePropertyData }) =>
      propertiesService.updateProperty(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['properties'] });
      queryClient.invalidateQueries({ queryKey: ['property', id] });
    },
  });
};
```

## Routing Strategy

### Route Structure
```typescript
// App.tsx routing
<Routes>
  {/* Public Routes */}
  <Route path="/" element={<Index />} />
  <Route path="/signin" element={<SignIn />} />
  <Route path="/signup" element={<SignUp />} />
  <Route path="/forgot-password" element={<ForgotPassword />} />
  <Route path="/property/:id" element={<Property />} />
  
  {/* Admin Routes */}
  <Route path="/admin/dashboard" element={<AdminDashboard />} />
  <Route path="/admin/properties" element={<AdminProperties />} />
  <Route path="/admin/properties/new" element={<PropertyNew />} />
  <Route path="/admin/properties/:id" element={<PropertyView />} />
  <Route path="/admin/properties/:id/edit" element={<PropertyEdit />} />
  <Route path="/admin/tours" element={<AdminTourAppointments />} />
  <Route path="/admin/users" element={<AdminUsers />} />
  <Route path="/admin/users/new" element={<AdminUserEdit />} />
  <Route path="/admin/users/:id/edit" element={<AdminUserEdit />} />
  
  {/* Tour Routes */}
  <Route path="/tours" element={<RemoteTourLibrary />} />
  <Route path="/tours/:id" element={<TourDetail />} />
  <Route path="/book-tour" element={<BookTour />} />
  <Route path="/book-tour/:id" element={<PropertyBooking />} />
  
  {/* Catch-all */}
  <Route path="*" element={<NotFound />} />
</Routes>
```

## Error Handling Strategy

### Global Error Handling
```typescript
// components/ErrorBoundary.tsx
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">
              Something went wrong
            </h1>
            <button
              onClick={() => window.location.reload()}
              className="bg-blue-600 text-white px-4 py-2 rounded"
            >
              Reload Page
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### API Error Handling
```typescript
// lib/api-error.ts
export class ApiError extends Error {
  constructor(
    public status: number,
    public message: string,
    public errors?: Record<string, string[]>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Enhanced error handling in services
export const handleApiError = (error: any): never => {
  if (error.response) {
    throw new ApiError(
      error.response.status,
      error.response.data.message || 'An error occurred',
      error.response.data.errors
    );
  }
  throw new ApiError(500, 'Network error');
};
```

## Form Handling Strategy

### React Hook Form + Zod Integration
```typescript
// schemas/property.schema.ts
import { z } from 'zod';

export const propertySchema = z.object({
  title: z.string().min(1, 'Title is required'),
  address: z.string().min(1, 'Address is required'),
  price: z.number().min(0, 'Price must be positive'),
  bedrooms: z.number().min(0),
  bathrooms: z.number().min(0),
  sqft: z.number().min(0),
  description: z.string().optional(),
});

export type PropertyFormData = z.infer<typeof propertySchema>;

// components/PropertyForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { propertySchema, type PropertyFormData } from '@/schemas/property.schema';

export const PropertyForm = ({ onSubmit, defaultValues }: PropertyFormProps) => {
  const form = useForm<PropertyFormData>({
    resolver: zodResolver(propertySchema),
    defaultValues,
  });

  const handleSubmit = async (data: PropertyFormData) => {
    try {
      await onSubmit(data);
    } catch (error) {
      // Handle form submission errors
    }
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(handleSubmit)}>
        {/* Form fields */}
      </form>
    </Form>
  );
};
```

## Performance Optimization

### Code Splitting
```typescript
// Lazy load admin pages
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));
const AdminProperties = lazy(() => import('./pages/AdminProperties'));

// Wrap with Suspense
<Suspense fallback={<LoadingSpinner />}>
  <AdminDashboard />
</Suspense>
```

### React Query Optimizations
```typescript
// Optimistic updates
const useUpdateProperty = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: updateProperty,
    onMutate: async (newProperty) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['properties'] });
      
      // Snapshot previous value
      const previousProperties = queryClient.getQueryData(['properties']);
      
      // Optimistically update
      queryClient.setQueryData(['properties'], (old: Property[]) =>
        old.map(p => p.id === newProperty.id ? newProperty : p)
      );
      
      return { previousProperties };
    },
    onError: (err, newProperty, context) => {
      // Rollback on error
      queryClient.setQueryData(['properties'], context?.previousProperties);
    },
    onSettled: () => {
      // Always refetch after error or success
      queryClient.invalidateQueries({ queryKey: ['properties'] });
    },
  });
};
```

## Security Considerations

### Authentication Flow
```typescript
// hooks/use-auth.ts
export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check for stored token and validate
    const token = localStorage.getItem('auth_token');
    if (token) {
      validateToken(token);
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (credentials: LoginCredentials) => {
    const response = await authService.login(credentials);
    const { token, user } = response.data;
    
    localStorage.setItem('auth_token', token);
    setUser(user);
  };

  const logout = () => {
    localStorage.removeItem('auth_token');
    setUser(null);
  };

  return { user, loading, login, logout };
};
```

### Protected Routes
```typescript
// components/ProtectedRoute.tsx
export const ProtectedRoute = ({ children, requiredRole }: ProtectedRouteProps) => {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <LoadingSpinner />;
  }

  if (!user) {
    return <Navigate to="/signin" state={{ from: location }} replace />;
  }

  if (requiredRole && user.role !== requiredRole) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
};
```

## Testing Strategy

### Unit Testing
```typescript
// __tests__/components/PropertyForm.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { PropertyForm } from '@/components/PropertyForm';

describe('PropertyForm', () => {
  it('should validate required fields', async () => {
    render(<PropertyForm onSubmit={jest.fn()} />);
    
    fireEvent.click(screen.getByText('Submit'));
    
    expect(await screen.findByText('Title is required')).toBeInTheDocument();
  });
});
```

### Integration Testing
```typescript
// __tests__/pages/AdminProperties.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AdminProperties } from '@/pages/AdminProperties';

const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: false } },
});

describe('AdminProperties', () => {
  it('should load and display properties', async () => {
    render(
      <QueryClientProvider client={queryClient}>
        <AdminProperties />
      </QueryClientProvider>
    );
    
    await waitFor(() => {
      expect(screen.getByText('Modern Downtown Condo')).toBeInTheDocument();
    });
  });
});
```

## Deployment Considerations

### Environment Configuration
```typescript
// vite.config.ts
export default defineConfig({
  plugins: [react()],
  define: {
    'process.env.VITE_API_BASE_URL': JSON.stringify(process.env.VITE_API_BASE_URL),
  },
});

// .env files
VITE_API_BASE_URL=http://localhost:3000/api/v1
VITE_APP_NAME=RealtyForYou
```

### Build Optimization
```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
});
```

This architecture provides a solid foundation for a scalable, maintainable React application with proper separation of concerns, type safety, and modern development practices. 