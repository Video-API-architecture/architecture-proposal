# Mobile Architecture Overview

## 📱 React Native App Architecture

The mobile app is built with **React Native** and **Expo**, designed to provide a simple, focused experience for users to join video tours and view tour history. The app prioritizes ease of use, performance, and reliability for real-time video communication.

<details>
<summary><strong>🔧 Core Technologies</strong></summary>

- **React Native** - Cross-platform mobile development
- **Expo** - Development platform and tools
- **TypeScript** - Type-safe development
- **React Navigation** - Navigation library
- **React Query** - Server state management
- **Axios** - HTTP client for API communication
- **AsyncStorage** - Local data persistence
- **Expo AV** - Video/audio capabilities
- **Expo Notifications** - Push notifications
- **AWS Chime SDK** - Video calling infrastructure
- **Redux Toolkit** - State management
- **React Hook Form** - Form handling
- **Zod** - Schema validation

</details>

## 🎯 App Features

<details>
<summary><strong>🔐 Authentication</strong></summary>

- Sign up with email/password
- Sign in with existing credentials
- Forgot password flow
- Secure token storage with refresh mechanism
- Biometric authentication (Touch ID/Face ID)

</details>

<details>
<summary><strong>🏠 Tour Management</strong></summary>

- View upcoming tours with real-time updates
- View previous tours with detailed history
- Join active tours with one-tap access
- Tour history with dates, times, and duration
- Push notifications for tour reminders

</details>

<details>
<summary><strong>📹 Video Calling</strong></summary>

- Join video calls via phone with AWS Chime SDK
- Basic video controls (mute, camera toggle, end call)
- Call timer and connection status
- Screen sharing capabilities
- Call recording (view-only for users)

</details>

<details>
<summary><strong>📱 Offline Support</strong></summary>

- View cached tour data when offline
- Queue actions for when connection is restored
- Offline tour history access

</details>

## 🧭 Navigation Structure

<details>
<summary><strong>🗺️ Navigation Flow</strong></summary>

```typescript
// AppNavigator.tsx
const AppNavigator = () => {
  const { isAuthenticated, isLoading } = useAuth();
  const { isConnected } = useNetworkStatus();

  if (isLoading) {
    return <LoadingScreen />;
  }

  if (!isConnected) {
    return <NetworkErrorScreen />;
  }

  return (
    <NavigationContainer linking={linking}>
      {isAuthenticated ? <TourNavigator /> : <AuthNavigator />}
    </NavigationContainer>
  );
};

// AuthNavigator.tsx
const AuthStack = createStackNavigator<AuthStackParamList>();

const AuthNavigator = () => {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: false,
        gestureEnabled: false,
      }}
    >
      <AuthStack.Screen name="Welcome" component={WelcomeScreen} />
      <AuthStack.Screen name="SignIn" component={SignInScreen} />
      <AuthStack.Screen name="SignUp" component={SignUpScreen} />
      <AuthStack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </AuthStack.Navigator>
  );
};

// TourNavigator.tsx
const TourStack = createStackNavigator<TourStackParamList>();

const TourNavigator = () => {
  return (
    <TourStack.Navigator>
      <TourStack.Screen
        name="TourList"
        component={TourListScreen}
        options={{
          title: 'My Tours',
          headerRight: () => <ProfileButton />,
        }}
      />
      <TourStack.Screen
        name="TourDetail"
        component={TourDetailScreen}
        options={{ title: 'Tour Details' }}
      />
      <TourStack.Screen
        name="TourHistory"
        component={TourHistoryScreen}
        options={{ title: 'Tour History' }}
      />
      <TourStack.Screen
        name="VideoCall"
        component={VideoCallScreen}
        options={{
          headerShown: false,
          gestureEnabled: false,
        }}
      />
      <TourStack.Screen
        name="CallEnded"
        component={CallEndedScreen}
        options={{ title: 'Call Ended' }}
      />
      <TourStack.Screen
        name="Profile"
        component={ProfileScreen}
        options={{ title: 'Profile' }}
      />
      <TourStack.Screen
        name="Settings"
        component={SettingsScreen}
        options={{ title: 'Settings' }}
      />
    </TourStack.Navigator>
  );
};
```

</details>

<details>
<summary><strong>📋 Navigation Types</strong></summary>

```typescript
// types/navigation.types.ts
export type AuthStackParamList = {
  Welcome: undefined;
  SignIn: undefined;
  SignUp: undefined;
  ForgotPassword: undefined;
};

export type TourStackParamList = {
  TourList: undefined;
  TourDetail: { tourId: string };
  TourHistory: undefined;
  VideoCall: { tourId: string };
  CallEnded: { tourId: string; duration: number };
  Profile: undefined;
  Settings: undefined;
};

export type RootStackParamList = {
  Auth: undefined;
  Tour: undefined;
};
```

</details>

## 🔐 Authentication System

<details>
<summary><strong>🎣 Authentication Hook</strong></summary>

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
<summary><strong>🔧 Authentication Service</strong></summary>

```typescript
// services/auth.service.ts
class AuthService {
  private api: AxiosInstance;

  constructor() {
    this.api = createApiClient();
  }

  async signIn(email: string, password: string): Promise<AuthResponse> {
    const response = await this.api.post('/auth/login', {
      email,
      password,
    });
    return response.data;
  }

  async signUp(userData: SignUpData): Promise<AuthResponse> {
    const response = await this.api.post('/auth/register', {
      user: userData,
    });
    return response.data;
  }

  async forgotPassword(email: string): Promise<void> {
    await this.api.post('/auth/password-reset/request', { email });
  }

  async resetPassword(token: string, password: string): Promise<void> {
    await this.api.post('/auth/password-reset/confirm', {
      token,
      password,
    });
  }

  async refreshToken(refreshToken: string): Promise<AuthResponse> {
    const response = await this.api.post('/auth/refresh', {
      refresh_token: refreshToken,
    });
    return response.data;
  }

  async signOut(): Promise<void> {
    try {
      await this.api.post('/auth/logout');
    } catch (error) {
      // Continue with local sign out even if API call fails
      console.error('Sign out API error:', error);
    }
  }

  async validateToken(token: string): Promise<User> {
    const response = await this.api.get('/users/me', {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  }
}

export const authService = new AuthService();
```

</details>

## 🎣 Custom Hooks

<details>
<summary><strong>🏠 Tours Hook</strong></summary>

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
<summary><strong>📹 Video Call Hook</strong></summary>

```typescript
// hooks/useVideoCall.ts
export const useVideoCall = (tourId: string) => {
  const [localStream, setLocalStream] = useState<MediaStream | null>(null);
  const [remoteStream, setRemoteStream] = useState<MediaStream | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isCameraOff, setIsCameraOff] = useState(false);
  const [callDuration, setCallDuration] = useState(0);
  const [callQuality, setCallQuality] = useState<'good' | 'poor' | 'unknown'>('unknown');
  
  const { data: tour } = useTour(tourId);
  const dispatch = useDispatch();

  const startCallTimer = useCallback(() => {
    const interval = setInterval(() => {
      setCallDuration(prev => prev + 1);
    }, 1000);
    return interval;
  }, []);

  const joinCall = async () => {
    try {
      // Request permissions
      const hasPermissions = await requestVideoPermissions();
      if (!hasPermissions) {
        throw new Error('Camera and microphone permissions are required');
      }

      // Initialize Chime SDK
      const meeting = await chimeService.createMeeting(tourId);
      const attendee = await chimeService.joinMeeting(meeting.MeetingId);
      
      // Get local media stream
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: true,
        video: { facingMode: 'user' },
      });
      
      setLocalStream(stream);
      
      // Join the meeting
      await chimeService.joinMeetingWithStream(
        meeting.MeetingId, 
        attendee.AttendeeId, 
        stream
      );
      
      setIsConnected(true);
      const timer = startCallTimer();
      
      // Monitor call quality
      const qualityInterval = setInterval(() => {
        const quality = chimeService.getCallQuality();
        setCallQuality(quality);
      }, 5000);
      
      return { timer, qualityInterval };
      
    } catch (error) {
      console.error('Failed to join call:', error);
      throw error;
    }
  };

  const leaveCall = async () => {
    if (localStream) {
      localStream.getTracks().forEach(track => track.stop());
      setLocalStream(null);
    }
    setRemoteStream(null);
    setIsConnected(false);
    setCallDuration(0);
    
    // Leave Chime meeting
    await chimeService.leaveMeeting();
    
    // Log call duration
    if (callDuration > 0) {
      dispatch(videoActions.logCallDuration({ tourId, duration: callDuration }));
    }
  };

  const toggleMute = () => {
    if (localStream) {
      const audioTrack = localStream.getAudioTracks()[0];
      if (audioTrack) {
        audioTrack.enabled = !audioTrack.enabled;
        setIsMuted(!audioTrack.enabled);
      }
    }
  };

  const toggleCamera = () => {
    if (localStream) {
      const videoTrack = localStream.getVideoTracks()[0];
      if (videoTrack) {
        videoTrack.enabled = !videoTrack.enabled;
        setIsCameraOff(!videoTrack.enabled);
      }
    }
  };

  return {
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
  };
};
```

</details>

<details>
<summary><strong>🌐 Network Status Hook</strong></summary>

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
<summary><strong>🔔 Notifications Hook</strong></summary>

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

## 🎨 UI Components

<details>
<summary><strong>🏠 Tour Card Component</strong></summary>

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
<summary><strong>📹 Video Call Component</strong></summary>

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

## 📱 Platform-Specific Considerations

<details>
<summary><strong>🍎 iOS Configuration</strong></summary>

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
<summary><strong>🔐 Permissions Management</strong></summary>

```typescript
// utils/permissions.ts
import { Camera } from 'expo-camera';
import { Audio } from 'expo-av';
import * as LocalAuthentication from 'expo-local-authentication';

export const requestVideoPermissions = async () => {
  const { status: cameraStatus } = await Camera.requestCameraPermissionsAsync();
  const { status: audioStatus } = await Audio.requestPermissionsAsync();
  
  if (cameraStatus !== 'granted' || audioStatus !== 'granted') {
    Alert.alert(
      'Permissions Required',
      'Camera and microphone permissions are required for video tours. Please enable them in Settings.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Settings', onPress: () => Linking.openSettings() }
      ]
    );
    return false;
  }
  
  return true;
};

export const requestBiometricPermission = async () => {
  const hasHardware = await LocalAuthentication.hasHardwareAsync();
  const isEnrolled = await LocalAuthentication.isEnrolledAsync();
  
  if (!hasHardware || !isEnrolled) {
    return false;
  }
  
  const result = await LocalAuthentication.authenticateAsync({
    promptMessage: 'Authenticate to access your tours',
    fallbackLabel: 'Use passcode',
  });
  
  return result.success;
};

export const checkNotificationPermissions = async () => {
  const { status: existingStatus } = await Notifications.getPermissionsAsync();
  let finalStatus = existingStatus;
  
  if (existingStatus !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync();
    finalStatus = status;
  }
  
  if (finalStatus !== 'granted') {
    Alert.alert(
      'Notification Permission',
      'Enable notifications to receive tour reminders and updates.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Settings', onPress: () => Linking.openSettings() }
      ]
    );
    return false;
  }
  
  return true;
};
```

</details>

## 🚀 Performance Optimization

<details>
<summary><strong>🖼️ Image Optimization</strong></summary>

```typescript
// utils/imageOptimization.ts
import * as ImageManipulator from 'expo-image-manipulator';

export const optimizeImage = async (
  uri: string, 
  width: number, 
  height: number,
  quality: number = 0.8
) => {
  try {
    const result = await ImageManipulator.manipulateAsync(
      uri,
      [{ resize: { width, height } }],
      { 
        compress: quality, 
        format: ImageManipulator.SaveFormat.JPEG 
      }
    );
    return result.uri;
  } catch (error) {
    console.error('Image optimization failed:', error);
    return uri;
  }
};

export const preloadImages = (imageUrls: string[]) => {
  return Promise.all(
    imageUrls.map(url => Image.prefetch(url))
  );
};
```

</details>

<details>
<summary><strong>📱 Offline Support</strong></summary>

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

<details>
<summary><strong>🧠 Memory Management</strong></summary>

```typescript
// hooks/useMemoryOptimization.ts
export const useMemoryOptimization = () => {
  useEffect(() => {
    const handleMemoryWarning = () => {
      // Clear image cache
      Image.clearMemoryCache();
      
      // Clear video cache
      if (Platform.OS === 'ios') {
        // iOS specific memory cleanup
      }
    };

    if (Platform.OS === 'ios') {
      // Listen for memory warnings on iOS
      // Note: This is a simplified example
    }

    return () => {
      // Cleanup
    };
  }, []);
};
```

</details>

## 📊 Testing Strategy

<details>
<summary><strong>🧪 Testing Overview</strong></summary>

| Test Type | Framework | Description |
|-----------|-----------|-------------|
| **Unit Tests** | Jest | Individual component testing |
| **Integration Tests** | Jest + React Native Testing Library | API and service testing |
| **End-to-End Tests** | Detox | Complete user journey testing |
| **Performance Tests** | Custom | Memory and battery optimization |

</details>

<details>
<summary><strong>🔧 Testing Configuration</strong></summary>

```typescript
// jest.config.js
module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|expo|@expo|@react-navigation)/)',
  ],
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{ts,tsx}',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

</details>

## 🚀 Deployment & CI/CD

<details>
<summary><strong>📦 Build Configuration</strong></summary>

```yaml
# .github/workflows/mobile-ci.yml
name: Mobile CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test
      - run: npm run lint

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npx expo build:android

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npx expo build:ios
```

</details>

This expanded mobile architecture provides a comprehensive foundation for a React Native app focused on video tour participation, with robust authentication, real-time video calling, offline support, and performance optimizations.