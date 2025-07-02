# Mobile Architecture Overview

## React Native App Architecture

The mobile app is built with **React Native** and **Expo**, designed to provide a simple, focused experience for users to join video tours and view tour history. The app prioritizes ease of use, performance, and reliability for real-time video communication.

<details>
<summary><strong>Core Technologies</strong></summary>

- **React Native** - Cross-platform mobile development
- **Expo** - Development platform and tools
- **TypeScript** - Type-safe development
- **React Navigation** - Navigation library
- **React Query** - Server state management
- **Axios** - HTTP client for API communication
- **AsyncStorage** - Local data persistence
- **Expo Notifications** - Push notifications
- **AWS Chime SDK** - Video calling infrastructure
- **Redux Toolkit** - State management
- **React Hook Form** - Form handling
- **Zod** - Schema validation

</details>

<details>
<summary><strong>State management</strong></summary>

| Strategy | Description |
|----------|-------------|
| **Redux Toolkit** | Predictable state management |
| **AsyncStorage** | Local data persistence |
| **Realm** | Local database for offline data |
| **State Synchronization** | Online/offline sync |

</details>

## App Features

<details>
<summary><strong>Authentication</strong></summary>

- Sign up with email/password
- Sign in with existing credentials
- Forgot password flow
- Secure token storage with refresh mechanism

</details>

<details>
<summary><strong>Tour Management</strong></summary>

- View upcoming tours with real-time updates
- View previous tours with detailed history
- Join active tours with one-tap access
- Tour history with dates, times, and duration
- Push notifications for tour reminders

</details>

<details>
<summary><strong>Video Calling</strong></summary>

- Join video calls via phone with AWS Chime SDK
- Basic video controls (mute, camera toggle, end call)
- Call timer and connection status
- Screen sharing capabilities
- Call recording (view-only for users)

</details>

<details>
<summary><strong>Offline Support</strong></summary>

- View cached tour data when offline
- Queue actions for when connection is restored
- Offline tour history access

| Capability | Description |
|------------|-------------|
| **Local Database** | Realm for offline data storage |
| **Queue System** | Offline action queuing |
| **Sync Engine** | Data synchronization when online |

</details>

## Navigation Structure

<details>
<summary><strong>Navigation Flow</strong></summary>

The navigation flow follows a hierarchical structure with authentication gates and network status checks.

**Navigation Hierarchy:**
1. **App Level**: Authentication check and network status validation
2. **Auth Stack**: Login, signup, and password recovery flows
3. **Tour Stack**: Main app functionality for tour management and video calls

</details>

<details>
<summary><strong>Deep Linking & Navigation</strong></summary>

| Feature | Description | Priority |
|---------|-------------|----------|
| **Deep Links** | Direct navigation to specific content | Future Phase |
| **Universal Links** | iOS deep linking | Future Phase |
| **App Links** | Android deep linking | Future Phase |
| **Navigation State** | Persistent navigation state | Future Phase |

**Note:** Deep linking is a user experience enhancement for property sharing and tour invitations. Not required for MVP but recommended for Future Phase to improve user engagement and lead generation.

</details>

## Authentication System

<details>
<summary><strong>Authentication Hook</strong></summary>

The `useAuth` hook provides a centralized authentication management system using Redux Toolkit for state management. It handles all authentication-related operations including login, signup, token refresh, and secure storage.

**Security Considerations:**
- Tokens are stored securely and automatically refreshed
- Failed refresh attempts trigger automatic sign out
- All API calls include proper authentication headers

**Hook Methods:**
- `signIn()`: Authenticate user with email/password
- `signUp()`: Register new user account
- `signOut()`: Clear authentication state and navigate to auth
- `forgotPassword()`: Initiate password reset flow
- `refreshAuthToken()`: Refresh expired access tokens

```typescript
// hooks/useAuth.ts
export const useAuth = () => {
  const dispatch = useDispatch();
  const { user, token, refreshToken, loading, error } = useSelector(authSelectors.selectAuth);
  const navigation = useNavigation();

  const signIn = async (email: string, password: string) => {
    try {
      dispatch(authActions.signInStart());
      const response = await authService.signIn(email, password);
      
      // Store tokens securely
      await storage.setTokens({
        accessToken: response.token,
        refreshToken: response.refresh_token,
      });
      
      // Store user data
      await storage.setUser(response.user);
      
      dispatch(authActions.signInSuccess(response));
      
      // Navigate to main app
      navigation.reset({
        index: 0,
        routes: [{ name: 'Tour' }],
      });
    } catch (error) {
      dispatch(authActions.signInFailure(error.message));
      throw error;
    }
  };

  const signUp = async (userData: SignUpData) => {
    try {
      dispatch(authActions.signUpStart());
      const response = await authService.signUp(userData);
      
      await storage.setTokens({
        accessToken: response.token,
        refreshToken: response.refresh_token,
      });
      
      await storage.setUser(response.user);
      
      dispatch(authActions.signUpSuccess(response));
      
      navigation.reset({
        index: 0,
        routes: [{ name: 'Tour' }],
      });
    } catch (error) {
      dispatch(authActions.signUpFailure(error.message));
      throw error;
    }
  };

  const signOut = async () => {
    try {
      await authService.signOut();
    } catch (error) {
      console.error('Sign out error:', error);
    } finally {
      await storage.clearAll();
      dispatch(authActions.signOut());
      
      navigation.reset({
        index: 0,
        routes: [{ name: 'Auth' }],
      });
    }
  };

  const forgotPassword = async (email: string) => {
    try {
      await authService.forgotPassword(email);
    } catch (error) {
      throw error;
    }
  };

  const refreshAuthToken = async () => {
    try {
      const tokens = await storage.getTokens();
      if (!tokens?.refreshToken) {
        throw new Error('No refresh token available');
      }

      const response = await authService.refreshToken(tokens.refreshToken);
      
      await storage.setTokens({
        accessToken: response.token,
        refreshToken: response.refresh_token,
      });
      
      dispatch(authActions.refreshTokenSuccess(response));
    } catch (error) {
      dispatch(authActions.refreshTokenFailure(error.message));
      await signOut();
    }
  };

  return {
    user,
    token,
    loading,
    error,
    signIn,
    signUp,
    signOut,
    forgotPassword,
    refreshAuthToken,
  };
};
```

</details>

<details>
<summary><strong>Authentication Service</strong></summary>

The `AuthService` class provides a clean abstraction layer for all authentication-related API calls. It encapsulates HTTP requests, error handling, and response formatting for authentication operations.

</details>

## Custom Hooks

<details>
<summary><strong>Tours Hook</strong></summary>

The Tours hooks provide React Query-based data fetching for tour-related operations with intelligent caching, offline support, and automatic retry mechanisms.

**Hook Variants:**
- `useTours()`: Fetches all user tours with 2-minute stale time
- `useTour(tourId)`: Fetches specific tour details with 1-minute stale time
- `useTourHistory()`: Fetches completed tours with 5-minute stale time

**Caching Strategy:**
- **Stale Time**: How long data is considered fresh (1-5 minutes)
- **Cache Time**: How long data stays in memory (10 minutes)
- **Background Updates**: Refetch on app focus for real-time data
- **Retry Configuration**: 3 attempts with exponential backoff

```typescript
// hooks/useTours.ts
export const useTours = () => {
  const { token } = useAuth();
  const { isConnected } = useNetworkStatus();
  
  return useQuery({
    queryKey: ['tours'],
    queryFn: () => toursService.getTours(),
    enabled: !!token && isConnected,
    staleTime: 2 * 60 * 1000, // 2 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
    refetchOnWindowFocus: true,
    retry: 3,
    retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
  });
};

export const useTour = (tourId: string) => {
  const { token } = useAuth();
  const { isConnected } = useNetworkStatus();
  
  return useQuery({
    queryKey: ['tour', tourId],
    queryFn: () => toursService.getTour(tourId),
    enabled: !!token && !!tourId && isConnected,
    staleTime: 1 * 60 * 1000, // 1 minute
  });
};

export const useTourHistory = () => {
  const { token } = useAuth();
  const { isConnected } = useNetworkStatus();
  
  return useQuery({
    queryKey: ['tour-history'],
    queryFn: () => toursService.getTourHistory(),
    enabled: !!token && isConnected,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};
```

</details>

<details>
<summary><strong>Video Call Hook</strong></summary>

The mobile app integrates seamlessly with AWS Chime SDK to provide robust video calling features, including management of local and remote media streams, real-time call controls (mute, camera toggle, termination), and automatic handling of camera and microphone permissions. Throughout the call lifecycle — from joining (with permission checks and meeting setup) to active participation and leaving (with proper cleanup and duration logging) — the app continuously monitors call quality and connection status, providing users with real-time feedback and visual indicators to ensure a smooth and reliable video communication experience.

</details>

<details>
<summary><strong>Network Status Hook</strong></summary>

The Network Status hook provides real-time network connectivity monitoring using React Native's NetInfo library, enabling offline-aware features and network-dependent functionality.

**Key Features:**
- **Real-time Monitoring**: Continuous network status updates
- **Connection Type Detection**: WiFi, cellular, or unknown connection types
- **Offline Awareness**: Automatic detection of network disconnection
- **Type Safety**: TypeScript support for connection states
- **Performance Optimized**: Efficient event listener management

**Network States:**
- **Connected**: App has internet connectivity
- **Disconnected**: No internet connection available
- **Connection Types**: WiFi, cellular, ethernet, or unknown

```typescript
// hooks/useNetworkStatus.ts
export const useNetworkStatus = () => {
  const [isConnected, setIsConnected] = useState(true);
  const [connectionType, setConnectionType] = useState<string>('unknown');

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      setIsConnected(state.isConnected ?? false);
      setConnectionType(state.type);
    });

    return unsubscribe;
  }, []);

  const isWifi = connectionType === 'wifi';
  const isCellular = connectionType === 'cellular';

  return {
    isConnected,
    connectionType,
    isWifi,
    isCellular,
  };
};
```

</details>

<details>
<summary><strong>Notifications Hook</strong></summary>

The Notifications hook manages push notifications using Expo's notification system, handling token registration, notification scheduling, and deep linking from notifications.

```typescript
// hooks/useNotifications.ts
export const useNotifications = () => {
  const [expoPushToken, setExpoPushToken] = useState<string | undefined>();
  const [notification, setNotification] = useState<Notification | null>(null);

  useEffect(() => {
    registerForPushNotificationsAsync().then(token => {
      setExpoPushToken(token);
      if (token) {
        notificationService.registerToken(token);
      }
    });

    const notificationListener = Notifications.addNotificationReceivedListener(notification => {
      setNotification(notification);
    });

    const responseListener = Notifications.addNotificationResponseReceivedListener(response => {
      const { tourId } = response.notification.request.content.data;
      if (tourId) {
        // Navigate to tour or video call
        navigation.navigate('VideoCall', { tourId });
      }
    });

    return () => {
      Notifications.removeNotificationSubscription(notificationListener);
      Notifications.removeNotificationSubscription(responseListener);
    };
  }, []);

  const scheduleTourReminder = async (tour: Tour) => {
    const reminderTime = new Date(tour.scheduled_at);
    reminderTime.setMinutes(reminderTime.getMinutes() - 15); // 15 minutes before

    await Notifications.scheduleNotificationAsync({
      content: {
        title: 'Tour Reminder',
        body: `Your tour at ${tour.property.address} starts in 15 minutes`,
        data: { tourId: tour.id },
      },
      trigger: reminderTime,
    });
  };

  return {
    expoPushToken,
    notification,
    scheduleTourReminder,
  };
};
```

</details>

## UI Components

<details>
<summary><strong>Tour Card Component</strong></summary>

```typescript
// components/tours/TourCard.tsx
interface TourCardProps {
  tour: Tour;
  onPress: () => void;
  showJoinButton?: boolean;
  variant?: 'upcoming' | 'previous' | 'active';
}

const TourCard: React.FC<TourCardProps> = ({ 
  tour, 
  onPress, 
  showJoinButton = false,
  variant = 'upcoming'
}) => {
  const isUpcoming = new Date(tour.scheduled_at) > new Date();
  const isActive = tour.status === 'in_progress';
  const isPast = new Date(tour.scheduled_at) <= new Date();

  const getStatusColor = () => {
    if (isActive) return '#22c55e';
    if (isUpcoming) return '#3b82f6';
    return '#6b7280';
  };

  const getStatusText = () => {
    if (isActive) return 'Live Now';
    if (isUpcoming) return 'Upcoming';
    return 'Completed';
  };

  const formatDate = (date: string) => {
    const tourDate = new Date(date);
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    if (tourDate.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (tourDate.toDateString() === tomorrow.toDateString()) {
      return 'Tomorrow';
    } else {
      return format(tourDate, 'MMM dd, yyyy');
    }
  };

  return (
    <TouchableOpacity 
      style={[styles.card, variant === 'active' && styles.activeCard]} 
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={styles.cardHeader}>
        <View style={styles.propertyInfo}>
          <Text style={styles.propertyAddress} numberOfLines={2}>
            {tour.property.address}
          </Text>
          <Text style={styles.propertyPrice}>
            ${tour.property.price?.toLocaleString()}
          </Text>
        </View>
        <View style={[styles.statusBadge, { backgroundColor: getStatusColor() }]}>
          <Text style={styles.statusText}>{getStatusText()}</Text>
        </View>
      </View>

      <View style={styles.cardContent}>
        <View style={styles.infoRow}>
          <Icon name="calendar" size={16} color="#666" />
          <Text style={styles.infoText}>{formatDate(tour.scheduled_at)}</Text>
        </View>
        
        <View style={styles.infoRow}>
          <Icon name="clock" size={16} color="#666" />
          <Text style={styles.infoText}>
            {format(new Date(tour.scheduled_at), 'h:mm a')}
          </Text>
        </View>

        <View style={styles.infoRow}>
          <Icon name="person" size={16} color="#666" />
          <Text style={styles.infoText}>{tour.realtor.full_name}</Text>
        </View>

        {tour.duration_minutes && (
          <View style={styles.infoRow}>
            <Icon name="timer" size={16} color="#666" />
            <Text style={styles.infoText}>{tour.duration_minutes} minutes</Text>
          </View>
        )}
      </View>

      {showJoinButton && isActive && (
        <TouchableOpacity style={styles.joinButton} onPress={onPress}>
          <Icon name="video-call" size={20} color="white" />
          <Text style={styles.joinButtonText}>Join Tour</Text>
        </TouchableOpacity>
      )}

      {variant === 'previous' && tour.ended_at && (
        <View style={styles.durationInfo}>
          <Text style={styles.durationText}>
            Duration: {formatDuration(tour.started_at, tour.ended_at)}
          </Text>
        </View>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  activeCard: {
    borderColor: '#22c55e',
    borderWidth: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  propertyInfo: {
    flex: 1,
    marginRight: 12,
  },
  propertyAddress: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
    marginBottom: 4,
  },
  propertyPrice: {
    fontSize: 14,
    color: '#059669',
    fontWeight: '500',
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '600',
    color: 'white',
  },
  cardContent: {
    gap: 8,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  infoText: {
    fontSize: 14,
    color: '#6b7280',
  },
  joinButton: {
    backgroundColor: '#22c55e',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    borderRadius: 8,
    marginTop: 12,
    gap: 8,
  },
  joinButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  durationInfo: {
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#e5e7eb',
  },
  durationText: {
    fontSize: 12,
    color: '#6b7280',
    fontStyle: 'italic',
  },
});
```

</details>

<details>
<summary><strong>Video Call Component</strong></summary>

```typescript
// components/video/VideoCall.tsx
interface VideoCallProps {
  tourId: string;
  onEndCall: () => void;
}

const VideoCall: React.FC<VideoCallProps> = ({ tourId, onEndCall }) => {
  const {
    tour,
    localStream,
    remoteStream,
    isConnected,
    isMuted,
    isCameraOff,
    callDuration,
    callQuality,
    joinCall,
    leaveCall,
    toggleMute,
    toggleCamera,
  } = useVideoCall(tourId);

  const [isJoining, setIsJoining] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const initializeCall = async () => {
      try {
        setIsJoining(true);
        setError(null);
        await joinCall();
      } catch (err) {
        setError(err.message);
      } finally {
        setIsJoining(false);
      }
    };

    initializeCall();

    return () => {
      leaveCall();
    };
  }, [tourId]);

  const handleEndCall = async () => {
    await leaveCall();
    onEndCall();
  };

  if (isJoining) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text style={styles.loadingText}>Joining tour...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Icon name="error" size={48} color="#ef4444" />
        <Text style={styles.errorTitle}>Failed to join tour</Text>
        <Text style={styles.errorMessage}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={initializeCall}>
          <Text style={styles.retryButtonText}>Try Again</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Remote Video */}
      <RTCView
        streamURL={remoteStream}
        style={styles.remoteVideo}
        objectFit="cover"
      />

      {/* Local Video */}
      <View style={styles.localVideoContainer}>
        <RTCView
          streamURL={localStream}
          style={styles.localVideo}
          objectFit="cover"
        />
        {isCameraOff && (
          <View style={styles.cameraOffOverlay}>
            <Icon name="videocam-off" size={24} color="white" />
          </View>
        )}
      </View>

      {/* Call Info */}
      <View style={styles.callInfo}>
        <Text style={styles.tourTitle}>{tour?.property.address}</Text>
        <CallTimer duration={callDuration} />
        <CallQualityIndicator quality={callQuality} />
      </View>

      {/* Controls */}
      <VideoControls
        isMuted={isMuted}
        isCameraOff={isCameraOff}
        onToggleMute={toggleMute}
        onToggleCamera={toggleCamera}
        onEndCall={handleEndCall}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
  },
  loadingText: {
    color: 'white',
    fontSize: 16,
    marginTop: 16,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
    padding: 24,
  },
  errorTitle: {
    color: 'white',
    fontSize: 20,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
  },
  errorMessage: {
    color: '#9ca3af',
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 24,
  },
  retryButton: {
    backgroundColor: '#3b82f6',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  retryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  remoteVideo: {
    flex: 1,
  },
  localVideoContainer: {
    position: 'absolute',
    top: 60,
    right: 20,
    width: 120,
    height: 160,
    borderRadius: 12,
    overflow: 'hidden',
  },
  localVideo: {
    width: '100%',
    height: '100%',
  },
  cameraOffOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  callInfo: {
    position: 'absolute',
    top: 60,
    left: 20,
    right: 160,
  },
  tourTitle: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
});
```

</details>

## Platform-Specific Considerations

<details>
<summary><strong>iOS/Android Configuration</strong></summary>

The iOS/Android configuration ensures the app meets App Stores requirements and provides optimal user experience on mobile devices.

```json
// app.json
{
  "expo": {
    "name": "RealtyForYou",
    "slug": "realty-for-you",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "bundleIdentifier": "com.realtyforyou.app",
      "buildNumber": "1",
      "supportsTablet": false,
      "infoPlist": {
        "NSCameraUsageDescription": "This app needs access to camera for video tours",
        "NSMicrophoneUsageDescription": "This app needs access to microphone for video tours",
        "NSPhotoLibraryUsageDescription": "This app needs access to photo library for profile pictures",
        "NSFaceIDUsageDescription": "This app uses Face ID for secure authentication",
        "UIBackgroundModes": ["audio", "voip"],
        "UIRequiresFullScreen": true
      },
      "entitlements": {
        "com.apple.developer.associated-domains": [
          "applinks:realtyforyou.com"
        ]
      }
    },
    "android": {
      "package": "com.realtyforyou.app",
      "versionCode": 1,
      "permissions": [
        "CAMERA",
        "RECORD_AUDIO",
        "READ_EXTERNAL_STORAGE",
        "WRITE_EXTERNAL_STORAGE",
        "USE_BIOMETRIC",
        "USE_FINGERPRINT",
        "VIBRATE",
        "WAKE_LOCK"
      ],
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      }
    },
    "plugins": [
      "expo-camera",
      "expo-av",
      "expo-notifications",
      "expo-device",
      "expo-constants",
      "expo-linking",
      "expo-splash-screen",
      "expo-status-bar"
    ]
  }
}
```

</details>

<details>
<summary><strong>Permissions Management</strong></summary>

The Permissions Management system handles all device permission requests with user-friendly explanations and graceful fallback handling.

| Permission | Purpose | Required | Fallback |
|------------|---------|----------|----------|
| **Camera Access** | Video call permissions | Yes | Audio-only calls |
| **Microphone Access** | Audio permissions | Yes | Text chat only |
| **Location Services** | Property proximity features | No | Manual location entry |
| **Push Notifications** | Real-time alerts | No | Email notifications |

</details>

## Performance Optimization

<details>
<summary><strong>Offline Support</strong></summary>

The mobile app can be designed with robust offline-first capabilities, ensuring users can access key features and perform actions even without an internet connection. It achieves this through local data caching, action queuing, and a structured local database, allowing users to view tour history, manage their profile, and queue actions for later execution. When connectivity is restored, the app automatically synchronizes data using incremental updates and background sync, efficiently handling conflicts with a server-wins strategy and notifying users as needed.

This approach provides a seamless user experience, with clear indicators for offline status, progress tracking for sync operations, and graceful error recovery. The app minimizes disruptions by ensuring transitions between online and offline states are smooth, and employs retry logic with exponential backoff to handle failed sync attempts, maintaining data integrity and reliability for users at all times.

```typescript
// hooks/useOfflineSync.ts
export const useOfflineSync = () => {
  const { isConnected } = useNetworkStatus();
  const queryClient = useQueryClient();
  const dispatch = useDispatch();

  useEffect(() => {
    if (isConnected) {
      // Sync any offline data when connection is restored
      queryClient.invalidateQueries();
      
      // Sync offline actions
      const offlineActions = storage.getOfflineActions();
      offlineActions.forEach(action => {
        dispatch(action);
      });
      storage.clearOfflineActions();
    }
  }, [isConnected]);

  const queueOfflineAction = (action: any) => {
    if (!isConnected) {
      storage.addOfflineAction(action);
    } else {
      dispatch(action);
    }
  };

  return { queueOfflineAction };
};
```
</details>

## Testing Strategy

<details>
<summary><strong>Testing Overview</strong></summary>

The Testing Strategy ensures code quality, reliability, and user experience through comprehensive testing at multiple levels.

| Test Type | Framework | Coverage | Purpose |
|-----------|-----------|----------|---------|
| **Unit Tests** | Jest | 90%+ | Individual component and logic testing |
| **Integration Tests** | Jest + React Native Testing Library | 100% | API and service interaction testing |
| **End-to-End Tests** | Detox | Critical paths | Complete user journey validation |
| **Performance Tests** | React Native Performance | Key metrics | App performance monitoring |

</details>

<details>
<summary><strong>Error Handling</strong></summary>

The mobile app employs a robust error handling strategy that categorizes issues into network, authentication, video call, data, and system errors. To ensure a smooth user experience, the app should use graceful degradation, user-friendly error messages, automatic recovery mechanisms, and comprehensive error reporting. Users receive non-intrusive feedback through toast notifications, have easy access to retry failed operations, and are kept informed about network status and available help resources.

For monitoring and continuous improvement, the app integrates with Sentry for real-time error tracking and alerting, and leverages performance monitoring tools to analyze crashes and app health. In-app feedback and error reporting features enable users to communicate issues directly, while trend analysis helps the team identify and resolve recurring problems efficiently.

| Component | Description | Implementation |
|-----------|-------------|----------------|
| **Crash Reporting** | Sentry integration for error tracking | Automatic crash capture and reporting |
| **Network Error Handling** | Offline mode support and retry logic | Graceful degradation with user feedback |
| **User Feedback** | Toast and alert notifications | Contextual error messages with actions |
| **Error Recovery** | Automatic retry and fallback mechanisms | Progressive error handling strategies |

</details>

## Deployment & CI/CD

<details>
<summary><strong>Build Configuration</strong></summary>

The Build Configuration provides automated, reliable, and secure mobile app deployment through comprehensive CI/CD pipelines and quality assurance processes.

| Pipeline Component | Description | Tools |
|-------------------|-------------|-------|
| **CI/CD** | Automated testing and deployment | GitHub Actions, EAS Build |
| **Code Quality** | Automated linting and formatting | ESLint, Prettier, TypeScript |
| **Security Scanning** | Automated vulnerability detection | Snyk, npm audit |
| **Testing** | Unit, integration, and E2E tests | Jest, Detox, React Native Testing Library |
| **Deployment** | App store deployment and distribution | App Store Connect, Google Play Console |

```yaml
# .github/workflows/mobile-ci.yml
name: Mobile CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  install-deps:
    name: Install Dependencies
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci

  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    needs: install-deps
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run lint
      - run: npm run format:check # e.g. prettier --check .

  test:
    name: Run Tests
    runs-on: ubuntu-latest
    needs: install-deps
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run test

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: install-deps
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npx snyk test --all-projects || true
      - run: npm audit || true

  build-android:
    name: Build Android (EAS)
    runs-on: ubuntu-latest
    needs: [lint, test, security]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npx expo login --token ${{ secrets.EXPO_TOKEN }}
      - run: npx eas build --platform android --non-interactive

  build-ios:
    name: Build iOS (EAS)
    runs-on: macos-latest
    needs: [lint, test, security]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npx expo login --token ${{ secrets.EXPO_TOKEN }}
      - run: npx eas build --platform ios --non-interactive
```
</details>
