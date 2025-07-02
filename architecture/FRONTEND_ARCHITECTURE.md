# Frontend Architecture Overview

## Project Structure

The frontend is built with **React 18**, **TypeScript**, and **Vite**, using a modern component-based architecture with the following key technologies:

<details>
<summary><strong>Core Technologies</strong></summary>

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
<summary><strong>Directory Structure</strong></summary>

```
src/
├── components/        # Reusable UI components
│   ├── ui/            # Shadcn/ui components
│   ├── AdminSidebar.tsx
│   ├── PropertyForm.tsx
│   └── TourNavigation.tsx
├── hooks/             # Custom React hooks
│   ├── useMobile.tsx
│   └── useToast.ts
├── lib/               # Utility functions
│   └── utils.ts
├── pages/             # Page components (routes)
│   ├── auth/          # Authentication pages
│   │   ├── SignIn.tsx
│   │   ├── SignUp.tsx
│   │   ├── ForgotPassword.tsx
│   │   ├── EmailConfirmation.tsx
│   │   └── PasswordResetConfirmation.tsx
│   ├── public/        # Public pages
│   │   ├── Index.tsx
│   │   ├── Property.tsx
│   │   └── MobileApp.tsx
│   ├── buyer/         # Buyer dashboard pages
│   │   ├── Dashboard.tsx
│   │   ├── Tours.tsx
│   │   ├── BookTour.tsx
│   │   ├── PropertyBooking.tsx
│   │   ├── TourConfirmation.tsx
│   │   ├── TourLibrary.tsx
│   │   └── TourDetail.tsx
│   ├── realtor/       # Realtor dashboard pages
│   │   ├── Dashboard.tsx
│   │   ├── Properties.tsx
│   │   ├── PropertyNew.tsx
│   │   ├── PropertyView.tsx
│   │   ├── PropertyEdit.tsx
│   │   ├── TourAppointments.tsx
│   │   ├── Calls.tsx
│   │   └── TourDetail.tsx
│   ├── admin/         # Admin pages
│   │   ├── Dashboard.tsx
│   │   ├── Properties.tsx
│   │   ├── PropertyNew.tsx
│   │   ├── PropertyView.tsx
│   │   ├── PropertyEdit.tsx
│   │   ├── TourAppointments.tsx
│   │   ├── Users.tsx
│   │   └── UserEdit.tsx
│   └── NotFound.tsx
├── App.tsx            # Main app component with routing
├── main.tsx           # App entry point
└── index.css          # Global styles
```

</details>

## Pages Architecture

<details>
<summary><strong>Authentication Pages (pages/auth)</strong></summary>

- **`SignIn.tsx`** - User authentication
- **`SignUp.tsx`** - User registration
- **`ForgotPassword.tsx`** - Password recovery
- **`EmailConfirmation.tsx`** - Email confirmation after signup
- **`PasswordResetConfirmation.tsx`** - Password reset confirmation

</details>

<details>
<summary><strong>Public Pages (pages/public)</strong></summary>

- **`Index.tsx`** - Landing page with marketing content and hero section
- **`Property.tsx`** - Public property viewing
- **`MobileApp.tsx`** - Mobile app download page

</details>

<details>
<summary><strong>Buyer Dashboard Pages (pages/buyer)</strong></summary>

- **`Dashboard.tsx`** - Main buyer dashboard
- **`Tours.tsx`** - Buyer's tour history and upcoming appointments
- **`BookTour.tsx`** - Tour booking interface
- **`PropertyBooking.tsx`** - Property-specific booking
- **`TourConfirmation.tsx`** - Tour confirmation after booking
- **`TourLibrary.tsx`** - Tour library/archive
- **`TourDetail.tsx`** - Individual tour details

</details>

<details>
<summary><strong>Realtor Dashboard Pages (pages/realtor)</strong></summary>

- **`Dashboard.tsx`** - Main realtor dashboard
- **`Properties.tsx`** - Property management
- **`PropertyNew.tsx`** - Create new property
- **`PropertyView.tsx`** - View property details
- **`PropertyEdit.tsx`** - Edit property
- **`TourAppointments.tsx`** - Tour appointment management
- **`Calls.tsx`** - Call management and history
- **`TourDetail.tsx`** - Individual tour details

</details>

<details>
<summary><strong>Admin Pages (pages/admin)</strong></summary>

- **`Dashboard.tsx`** - Main admin dashboard with metrics
- **`Properties.tsx`** - Property management
- **`PropertyNew.tsx`** - Create new property
- **`PropertyView.tsx`** - View property details
- **`PropertyEdit.tsx`** - Edit property
- **`TourAppointments.tsx`** - Tour appointment management
- **`Users.tsx`** - User management
- **`UserEdit.tsx`** - Create/edit users

</details>

## Component Architecture

<details>
<summary><strong>Design Patterns</strong></summary>

| Pattern | Description |
|---------|-------------|
| **Component Composition** | Reusable component design |
| **Custom Hooks** | Shared logic extraction |
| **Context API** | Global state management |
| **Render Props** | Flexible component patterns |

</details>

<details>
<summary><strong>UI Components (components/ui)</strong></summary>

Built on **Radix UI** primitives with **Shadcn/ui** styling:

- **Layout**: `sidebar.tsx`, `sheet.tsx`, `drawer.tsx`
- **Forms**: `form.tsx`, `input.tsx`, `button.tsx`, `select.tsx`
- **Feedback**: `toast.tsx`, `alert.tsx`, `badge.tsx`
- **Navigation**: `tabs.tsx`, `breadcrumb.tsx`, `pagination.tsx`
- **Data Display**: `table.tsx`, `card.tsx`, `avatar.tsx`
- **Overlays**: `dialog.tsx`, `popover.tsx`, `tooltip.tsx`

</details>

<details>
<summary><strong>Custom Components</strong></summary>

- **`AdminSidebar.tsx`** - Navigation sidebar for admin pages
- **`PropertyForm.tsx`** - Reusable property creation/editing form
- **`TourNavigation.tsx`** - Tour-specific navigation component

</details>

## Hooks Architecture

<details>
<summary><strong>Custom Hooks</strong></summary>

- **`useMobile.tsx`** - Responsive design hook for mobile detection
- **`useToast.ts`** - Toast notification management

### Recommended Additional Hooks
```typescript
// hooks/use-api.ts
export const useApi = () => {
  // API client configuration
};

// hooks/useAuth.ts
import { useState, useEffect, createContext, useContext, ReactNode } from 'react';
import { authService } from '../services/auth.service';

interface User {
  id: string;
  email: string;
  fullName: string;
  role: 'buyer' | 'realtor' | 'admin';
  avatar?: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  register: (userData: RegisterData) => Promise<void>;
  logout: () => void;
  forgotPassword: (email: string) => Promise<void>;
  resetPassword: (token: string, password: string) => Promise<void>;
  clearError: () => void;
}

interface RegisterData {
  fullName: string;
  email: string;
  password: string;
  role: 'buyer' | 'realtor';
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Check for existing token on mount
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        const token = localStorage.getItem('auth_token');
        if (token) {
          // Verify token and get user data
          const response = await authService.verifyToken();
          setUser(response.data.user);
        }
      } catch (error) {
        // Token is invalid, remove it
        localStorage.removeItem('auth_token');
      } finally {
        setIsLoading(false);
      }
    };

    initializeAuth();
  }, []);

  const login = async (email: string, password: string) => {
    try {
      setIsLoading(true);
      setError(null);
      
      const response = await authService.login({ email, password });
      const { token, user: userData } = response.data;
      
      // Store token
      localStorage.setItem('auth_token', token);
      
      // Update user state
      setUser(userData);
    } catch (error: any) {
      setError(error.response?.data?.message || 'Login failed');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (userData: RegisterData) => {
    try {
      setIsLoading(true);
      setError(null);
      
      const response = await authService.register(userData);
      const { token, user: newUser } = response.data;
      
      // Store token
      localStorage.setItem('auth_token', token);
      
      // Update user state
      setUser(newUser);
    } catch (error: any) {
      setError(error.response?.data?.message || 'Registration failed');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    // Remove token
    localStorage.removeItem('auth_token');
    
    // Clear user state
    setUser(null);
    
    // Redirect to login
    window.location.href = '/signin';
  };

  const forgotPassword = async (email: string) => {
    try {
      setError(null);
      await authService.forgotPassword(email);
    } catch (error: any) {
      setError(error.response?.data?.message || 'Password reset request failed');
      throw error;
    }
  };

  const resetPassword = async (token: string, password: string) => {
    try {
      setError(null);
      await authService.resetPassword(token, password);
    } catch (error: any) {
      setError(error.response?.data?.message || 'Password reset failed');
      throw error;
    }
  };

  const clearError = () => {
    setError(null);
  };

  const value: AuthContextType = {
    user,
    isLoading,
    error,
    login,
    register,
    logout,
    forgotPassword,
    resetPassword,
    clearError,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
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
<summary><strong>React Query (TanStack Query)</strong></summary>

For server state management:
- **Caching** - Automatic caching of API responses
- **Background updates** - Keep data fresh
- **Optimistic updates** - Immediate UI feedback
- **Error handling** - Built-in error states

| Strategy | Description |
|----------|-------------|
| **React Query** | Server state and caching |
| **Context API** | Global application state |
| **Local State** | Component-specific state |
| **URL State** | Navigation and routing state |

</details>

<details>
<summary><strong>Context API</strong></summary>

For global application state:
- **Authentication** - User session and permissions
- **Theme** - Dark/light mode preferences
- **Notifications** - Global notification state

</details>

<details>
<summary><strong>Local State</strong></summary>

For component-specific state:
- **Form state** - Using React Hook Form
- **UI state** - Modal open/close, loading states
- **Component interactions** - Local component behavior

</details>

## API Integration Strategy

<details>
<summary><strong>Recommended API Client Setup</strong></summary>

| Strategy | Description |
|----------|-------------|
| **Axios** | HTTP client with interceptors |
| **Request Caching** | Optimistic updates and caching |
| **File Upload** | Multipart form data handling |

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
<summary><strong>API Service Modules</strong></summary>

```typescript
// services/auth.service.ts
export const authService = {
  login: (credentials: LoginCredentials) => 
    apiClient.post('/auth/login', credentials),
  
  register: (userData: RegisterData) => 
    apiClient.post('/auth/register', userData),
  
  verifyToken: () => 
    apiClient.get('/auth/verify'),
  
  forgotPassword: (email: string) => 
    apiClient.post('/auth/password-reset/request', { email }),
  
  resetPassword: (token: string, password: string) => 
    apiClient.post('/auth/password-reset/confirm', { token, password }),
};

// services/properties.service.ts
export const propertiesService = {
  // Realtor endpoints
  getRealtorProperties: (params?: PropertyFilters) => 
    apiClient.get('/realtors/properties', { params }),
  
  getRealtorProperty: (id: string) => 
    apiClient.get(`/realtors/properties/${id}`),
  
  createProperty: (property: CreatePropertyData) => 
    apiClient.post('/realtors/properties', property),
  
  updateProperty: (id: string, property: UpdatePropertyData) => 
    apiClient.put(`/realtors/properties/${id}`, property),
  
  deleteProperty: (id: string) => 
    apiClient.delete(`/realtors/properties/${id}`),
  
  uploadPropertyImages: (id: string, images: File[]) => {
    const formData = new FormData();
    images.forEach(image => formData.append('images[]', image));
    return apiClient.post(`/realtors/properties/${id}/images`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  },

  // Buyer endpoints
  getBuyerProperties: (params?: PropertyFilters) => 
    apiClient.get('/buyers/properties', { params }),
  
  getBuyerProperty: (id: string) => 
    apiClient.get(`/buyers/properties/${id}`),
};

// services/bookings.service.ts
export const bookingsService = {
  // Realtor endpoints
  getRealtorBookings: (params?: BookingFilters) => 
    apiClient.get('/realtors/bookings', { params }),
  
  getRealtorBooking: (id: string) => 
    apiClient.get(`/realtors/bookings/${id}`),
  
  updateRealtorBooking: (id: string, booking: UpdateBookingData) => 
    apiClient.put(`/realtors/bookings/${id}`, booking),
  
  confirmRealtorBooking: (id: string) => 
    apiClient.put(`/realtors/bookings/${id}/confirm`),
  
  cancelRealtorBooking: (id: string) => 
    apiClient.delete(`/realtors/bookings/${id}`),

  // Buyer endpoints
  getBuyerBookings: (params?: BookingFilters) => 
    apiClient.get('/buyers/bookings', { params }),
  
  getBuyerBooking: (id: string) => 
    apiClient.get(`/buyers/bookings/${id}`),
  
  createBuyerBooking: (booking: CreateBookingData) => 
    apiClient.post('/buyers/bookings', booking),
  
  updateBuyerBooking: (id: string, booking: UpdateBookingData) => 
    apiClient.put(`/buyers/bookings/${id}`, booking),
  
  cancelBuyerBooking: (id: string) => 
    apiClient.delete(`/buyers/bookings/${id}`),
};

// services/tours.service.ts
export const toursService = {
  // Realtor endpoints
  getRealtorTours: (params?: TourFilters) => 
    apiClient.get('/realtors/tours', { params }),
  
  getRealtorTour: (id: string) => 
    apiClient.get(`/realtors/tours/${id}`),
  
  startTour: (id: string) => 
    apiClient.post(`/realtors/tours/${id}/start`),
  
  endTour: (id: string) => 
    apiClient.post(`/realtors/tours/${id}/end`),
  
  getTourNotes: (id: string) => 
    apiClient.get(`/realtors/tours/${id}/notes`),
  
  addTourNote: (id: string, note: CreateNoteData) => 
    apiClient.post(`/realtors/tours/${id}/notes`, note),

  // Buyer endpoints
  getBuyerTours: (params?: TourFilters) => 
    apiClient.get('/buyers/tours', { params }),
  
  getBuyerTour: (id: string) => 
    apiClient.get(`/buyers/tours/${id}`),
  
  getBuyerTourNotes: (id: string) => 
    apiClient.get(`/buyers/tours/${id}/notes`),
  
  addBuyerTourNote: (id: string, note: CreateNoteData) => 
    apiClient.post(`/buyers/tours/${id}/notes`, note),
};

// services/calls.service.ts
export const callsService = {
  // Realtor endpoints
  getRealtorCall: (id: string) => 
    apiClient.get(`/realtors/calls/${id}`),
  
  joinRealtorCall: (id: string) => 
    apiClient.post(`/realtors/calls/${id}/join`),
  
  leaveRealtorCall: (id: string) => 
    apiClient.post(`/realtors/calls/${id}/leave`),
  
  endRealtorCall: (id: string) => 
    apiClient.post(`/realtors/calls/${id}/end`),
  
  getRealtorCallRecording: (id: string) => 
    apiClient.get(`/realtors/calls/${id}/recording`),
  
  toggleRealtorCallRecording: (id: string) => 
    apiClient.post(`/realtors/calls/${id}/record`),

  // Buyer endpoints
  getBuyerCall: (id: string) => 
    apiClient.get(`/buyers/calls/${id}`),
  
  joinBuyerCall: (id: string) => 
    apiClient.post(`/buyers/calls/${id}/join`),
  
  leaveBuyerCall: (id: string) => 
    apiClient.post(`/buyers/calls/${id}/leave`),
  
  getBuyerCallRecording: (id: string) => 
    apiClient.get(`/buyers/calls/${id}/recording`),
};
```

</details>

## Video SDK Integration

<details>
<summary><strong>Chime SDK Integration</strong></summary>

### Overview

The RealtyForYou frontend uses the [Amazon Chime SDK](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html) to power real-time video tours, including audio, video, and screen sharing for web and mobile clients.

---

### Frontend (React/React Native) Responsibilities

- **SDK Usage:**  
  - Use [Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js) (web).
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

</details>

## Form Management

<details>
<summary><strong>React Hook Form Integration</strong></summary>

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
<summary><strong>Schema Validation</strong></summary>

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
<summary><strong>React Router Setup</strong></summary>

```typescript
// App.tsx
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from './components/ui/toaster';

// Pages
import Index from './pages/public/Index';
import SignIn from './pages/auth/SignIn';
import SignUp from './pages/auth/SignUp';
import ForgotPassword from './pages/auth/ForgotPassword';
import EmailConfirmation from './pages/auth/EmailConfirmation';
import PasswordResetConfirmation from './pages/auth/PasswordResetConfirmation';
import Property from './pages/public/Property';
import MobileApp from './pages/public/MobileApp';
import BuyerDashboard from './pages/buyer/Dashboard';
import BuyerTours from './pages/buyer/Tours';
import BookTour from './pages/buyer/BookTour';
import PropertyBooking from './pages/buyer/PropertyBooking';
import TourConfirmation from './pages/buyer/TourConfirmation';
import RemoteTourLibrary from './pages/buyer/TourLibrary';
import BuyerTourDetail from './pages/buyer/TourDetail';
import RealtorDashboard from './pages/realtor/Dashboard';
import RealtorProperties from './pages/realtor/Properties';
import PropertyNew from './pages/realtor/PropertyNew';
import PropertyView from './pages/realtor/PropertyView';
import PropertyEdit from './pages/realtor/PropertyEdit';
import RealtorTourAppointments from './pages/realtor/TourAppointments';
import RealtorCalls from './pages/realtor/Calls';
import RealtorTourDetail from './pages/realtor/TourDetail';
import AdminDashboard from './pages/admin/Dashboard';
import AdminProperties from './pages/admin/Properties';
import AdminPropertyNew from './pages/admin/PropertyNew';
import AdminPropertyView from './pages/admin/PropertyView';
import AdminPropertyEdit from './pages/admin/PropertyEdit';
import AdminTourAppointments from './pages/admin/TourAppointments';
import AdminUsers from './pages/admin/Users';
import AdminUserEdit from './pages/admin/UserEdit';
import NotFound from './pages/NotFound';

// Components
import BuyerRoute from './components/BuyerRoute';
import RealtorRoute from './components/RealtorRoute';
import AdminRoute from './components/AdminRoute';
import { AuthProvider } from './hooks/useAuth';

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
      <AuthProvider>
        <Router>
          <div className="min-h-screen bg-background">
            <Routes>
            {/* Public Routes */}
            <Route path="/" element={<Index />} />
            <Route path="/signin" element={<SignIn />} />
            <Route path="/signup" element={<SignUp />} />
            <Route path="/forgot-password" element={<ForgotPassword />} />
            <Route path="/email-confirmation" element={<EmailConfirmation />} />
            <Route path="/password-reset-confirmation" element={<PasswordResetConfirmation />} />
            <Route path="/property/:id" element={<Property />} />
            <Route path="/mobile-app" element={<MobileApp />} />

            {/* Buyer Routes */}
            <Route element={<BuyerRoute />}>
              <Route path="/buyer/dashboard" element={<BuyerDashboard />} />
              <Route path="/buyer/tours" element={<BuyerTours />} />
              <Route path="/buyer/tour-library" element={<RemoteTourLibrary />} />
              <Route path="/buyer/tour/:id" element={<BuyerTourDetail />} />
              <Route path="/buyer/book-tour" element={<BookTour />} />
              <Route path="/buyer/property/:id/book" element={<PropertyBooking />} />
              <Route path="/buyer/tour-confirmation" element={<TourConfirmation />} />
            </Route>

            {/* Realtor Routes */}
            <Route element={<RealtorRoute />}>
              <Route path="/realtor/dashboard" element={<RealtorDashboard />} />
              <Route path="/realtor/properties" element={<RealtorProperties />} />
              <Route path="/realtor/properties/new" element={<PropertyNew />} />
              <Route path="/realtor/properties/:id" element={<PropertyView />} />
              <Route path="/realtor/properties/:id/edit" element={<PropertyEdit />} />
              <Route path="/realtor/tours" element={<RealtorTourAppointments />} />
              <Route path="/realtor/calls" element={<RealtorCalls />} />
              <Route path="/realtor/tour/:id" element={<RealtorTourDetail />} />
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
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;
```

</details>

<details>
<summary><strong>Route Protection</strong></summary>

```typescript
// components/BuyerRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/use-auth';

const BuyerRoute = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <Navigate to="/signin" replace />;
  }

  if (user.role !== 'buyer') {
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
};

// components/RealtorRoute.tsx
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/use-auth';

const RealtorRoute = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <Navigate to="/signin" replace />;
  }

  if (user.role !== 'realtor') {
    return <Navigate to="/" replace />;
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

  if (user.role !== 'admin') {
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
};
```

</details>

## Security

<details>
<summary><strong>Security Measures</strong></summary>

| Security Measure | Description |
|-----------------|-------------|
| **XSS Prevention** | Input sanitization |
| **CSRF Protection** | Cross-site request forgery prevention |
| **Content Security Policy** | Resource loading restrictions |
| **HTTPS** | Secure communication |
</details>

## Styling & Design System


<details>
<summary><strong>Approaches</strong></summary>

| Approach | Description |
|----------|-------------|
| **Tailwind CSS** | Utility-first styling |
| **CSS Modules** | Component-scoped styles |
| **Design System** | Consistent component library |

</details>

<details>
<summary><strong>Tailwind CSS Configuration</strong></summary>

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
<summary><strong>Design Tokens</strong></summary>

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
<summary><strong>Code Splitting</strong></summary>

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
<summary><strong>Caching Strategy</strong></summary>

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
<summary><strong>Components</strong></summary>

| Component | Description |
|-----------|-------------|
| **Error Boundaries** | Component error isolation |
| **Toast Notifications** | User-friendly error messages |
| **Fallback UI** | Graceful degradation |

</details>

<details>
<summary><strong>Error Handling Hooks</strong></summary>

```typescript
// hooks/use-error-handler.ts
import { useCallback } from 'react';
import { useToast } from './useToast';

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
<summary><strong>Testing frameworks</strong></summary>

| Test Type | Framework |
|-----------|-----------|
| **Jest** | Unit testing framework |
| **React Testing Library** | Component testing |
| **Cypress** | End-to-end testing |
| **MSW** | API mocking for tests |

</details>

## Build & Deployment

<details>
<summary><strong>Deployment Configuration</strong></summary>

```yaml
# .github/workflows/deploy.yml
name: Deploy Frontend to AWS

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
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Sync build to S3
        run: aws s3 sync dist/ s3://${{ secrets.AWS_S3_BUCKET_NAME }} --delete
      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.AWS_CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths '/*'
```
</details>
