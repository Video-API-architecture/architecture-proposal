# Backend Architecture Overview

## System Architecture

The backend is built with **Ruby on Rails 7** in API mode, designed to support real estate video tours with real-time communication, property management, and tour scheduling.

<details>
<summary><strong>Core Technologies</strong></summary>

- **Ruby on Rails 7** - Web framework with API mode
- **PostgreSQL** - Primary relational database
- **Redis** - Caching and session storage
- **AWS Cognito** - User authentication and token issuance
- **AWS Chime SDK** - Video communication
- **Active Job** - Background job processing
- **Sidekiq** - Job queue management

</details>

## Project Structure

<details>
<summary><strong>MVC + Services</strong></summary>

| Layer | Description |
|-------|-------------|
| **Models** | Data validation and business rules |
| **Views** | JSON response formatting |
| **Controllers** | Request handling and routing |
| **Services** | Complex business logic |

</details>

<details>
<summary><strong>Concerns</strong></summary>

| Concern | Description |
|---------|-------------|
| **Authentication** | User authentication and authorization |
| **Caching** | Response caching strategies |
| **Logging** | Request and response logging |
| **Validation** | Input validation and sanitization |

</details>

<details>
<summary><strong>File Structure</strong></summary>

```
app/
├── controllers/
│   └── api/v1/ 
│       ├── auth/
│       │   ├── application_controller.rb
│       │   ├── registrations_controller.rb
│       │   └── sessions_controller.rb
│       ├── realtors/
│       │   ├── application_controller.rb
│       │   ├── properties_controller.rb
│       │   ├── tours_controller.rb
│       │   ├── bookings_controller.rb
│       │   └── calls_controller.rb
│       ├── buyers/
│       │   ├── application_controller.rb
│       │   ├── properties_controller.rb
│       │   ├── tours_controller.rb
│       │   ├── bookings_controller.rb
│       │   └── calls_controller.rb
│       └── admin/
│           ├── application_controller.rb
│           ├── users_controller.rb
│           ├── properties_controller.rb
│           ├── tours_controller.rb
│           └── bookings_controller.rb
├── models/
│   ├── user.rb
│   ├── property.rb
│   ├── booking.rb
│   ├── tour.rb
│   ├── call.rb
│   ├── tour_note.rb
│   ├── transcript.rb
│   ├── highlight.rb
│   ├── recording.rb
│   └── audit_log.rb
├── services/
│   ├── tour_lifecycle_service.rb
│   ├── video_processing_service.rb
│   ├── transcription_service.rb
│   ├── highlight_detection_service.rb
│   ├── summary_service.rb
│   └── image_processing_service.rb
├── jobs/
│   ├── notification_job.rb
│   ├── tour_processing_job.rb
│   └── image_processing_job.rb
└── concerns/
    ├── authentication.rb
    ├── caching.rb
    ├── logging.rb
    └── validation.rb
```

</details>

## Database Schema

<details>
<summary><strong>Core Tables</strong></summary>

| Table | Description |
|-------|-------------|
| **Users Table** | User profiles and authentication (id, full_name, email, role, cognito_sub, timestamps) |
| **Properties Table** | Property listings and details (realtor_id, address, mls_id, description, timestamps) |
| **Bookings Table** | Tour booking requests (buyer_id, property_id, scheduled_at, status, timestamps) |
| **Tours Table** | Actual tour sessions (property_id, realtor_id, buyer_id, status, scheduled_at, started_at) |
| **Calls Table** | Video call sessions (tour_id, chime_meeting_id, status, started_at, ended_at) |
| **TourNotes Table** | User-generated notes during tours (tour_id, user_id, content, tag, timestamp_ms, timestamps) |
| **Transcripts Table** | AI-generated call transcripts (tour_id, full_text, segments JSON, timestamps) |
| **Highlights Table** | Tour highlights and moments (tour_id, timestamp_ms, note, image_url, timestamps) |
| **Recordings Table** | Call recordings and playback (tour_id, mux_asset_id, playback_url, duration_seconds, recorded_at, timestamps) |
| **AuditLogs Table** | Immutable system & user actions for compliance (actor_id, action, target_id, meta, created_at) |

#### Users Table
```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  role VARCHAR(50) DEFAULT 'buyer',
  cognito_sub VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Properties Table
```sql
CREATE TABLE properties (
  id BIGSERIAL PRIMARY KEY,
  realtor_id BIGINT REFERENCES users(id),
  address TEXT NOT NULL,
  mls_id VARCHAR(255) UNIQUE,
  description TEXT,
  price DECIMAL(12,2),
  bedrooms INTEGER,
  bathrooms INTEGER,
  sqft INTEGER,
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Bookings Table
```sql
CREATE TABLE bookings (
  id BIGSERIAL PRIMARY KEY,
  buyer_id BIGINT REFERENCES users(id),
  property_id BIGINT REFERENCES properties(id),
  scheduled_at TIMESTAMP NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  duration_minutes INTEGER DEFAULT 30,
  notes TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Tours Table
```sql
CREATE TABLE tours (
  id BIGSERIAL PRIMARY KEY,
  property_id BIGINT REFERENCES properties(id),
  realtor_id BIGINT REFERENCES users(id),
  buyer_id BIGINT REFERENCES users(id),
  booking_id BIGINT REFERENCES bookings(id),
  status VARCHAR(50) DEFAULT 'scheduled',
  scheduled_at TIMESTAMP NOT NULL,
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Calls Table
```sql
CREATE TABLE calls (
  id BIGSERIAL PRIMARY KEY,
  tour_id BIGINT REFERENCES tours(id),
  chime_meeting_id VARCHAR(255) UNIQUE NOT NULL,
  status VARCHAR(50) DEFAULT 'created',
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Tour Notes Table
```sql
CREATE TABLE tour_notes (
  id BIGSERIAL PRIMARY KEY,
  tour_id BIGINT REFERENCES tours(id),
  user_id BIGINT REFERENCES users(id),
  content TEXT NOT NULL,
  tag VARCHAR(100),
  timestamp_ms BIGINT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Transcripts Table
```sql
CREATE TABLE transcripts (
  id BIGSERIAL PRIMARY KEY,
  tour_id BIGINT REFERENCES tours(id),
  full_text TEXT,
  segments JSONB,
  confidence_score DECIMAL(3,2),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Highlights Table
```sql
CREATE TABLE highlights (
  id BIGSERIAL PRIMARY KEY,
  tour_id BIGINT REFERENCES tours(id),
  timestamp_ms BIGINT NOT NULL,
  note TEXT,
  image_url VARCHAR(500),
  highlight_type VARCHAR(50),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Recordings Table
```sql
CREATE TABLE recordings (
  id BIGSERIAL PRIMARY KEY,
  tour_id BIGINT REFERENCES tours(id),
  mux_asset_id VARCHAR(255) UNIQUE,
  playback_url VARCHAR(500),
  duration_seconds INTEGER,
  file_size_bytes BIGINT,
  recorded_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

#### Audit Logs Table
```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(50),
  resource_id BIGINT,
  details TEXT,
  created_at TIMESTAMP NOT NULL
);
```

</details>

<details>
<summary><strong>Indexes</strong></summary>

```sql
-- Performance indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_properties_realtor_id ON properties(realtor_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_bookings_buyer_id ON bookings(buyer_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_scheduled_at ON bookings(scheduled_at);
CREATE INDEX idx_tours_property_id ON tours(property_id);
CREATE INDEX idx_tours_realtor_id ON tours(realtor_id);
CREATE INDEX idx_tours_buyer_id ON tours(buyer_id);
CREATE INDEX idx_tours_scheduled_at ON tours(scheduled_at);
CREATE INDEX idx_calls_tour_id ON calls(tour_id);
CREATE INDEX idx_tour_notes_tour_id ON tour_notes(tour_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

</details>

## Authentication & Authorization

<details>
<summary><strong>Cognito Authentication Flow</strong></summary>

- User registration, login, and password reset are handled by AWS Cognito.
- The backend verifies Cognito JWTs using the User Pool's JWKS endpoint.
- On first login, a user record is created/updated in the local database using Cognito's `sub` as the unique identifier.
- Passwords are never stored or managed by the backend.

</details>

<details>
<summary><strong>Authorization</strong></summary>

The system supports three user types: **buyer**, **realtor**, and **admin**. While authentication is managed by AWS Cognito, authorization (what each user can do) is enforced by the backend using the `role` field in the `users` table and policy classes (e.g., Pundit).

#### Role Storage
- The canonical user role is stored in the local `users` table (`role` column).
- Optionally, the role can also be stored as a custom attribute in Cognito and synced to the DB on login.

#### Role Helpers (User Model)

```ruby
class User < ApplicationRecord
  def buyer?
    role == 'buyer'
  end

  def realtor?
    role == 'realtor'
  end

  def admin?
    role == 'admin'
  end
end
```

#### Example Policy (Pundit)

```ruby
class PropertyPolicy < ApplicationPolicy
  def index?
    user.realtor? || user.admin?
  end

  def show?
    user.realtor? || user.admin? || record.realtor_id == user.id
  end

  def create?
    user.realtor? || user.admin?
  end

  def update?
    user.realtor? && record.realtor_id == user.id || user.admin?
  end

  def destroy?
    user.realtor? && record.realtor_id == user.id || user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.realtor?
        scope.where(realtor_id: user.id)
      else
        scope.none
      end
    end
  end
end
```
</details>

## API Design

<details>
<summary><strong>API Endpoints</strong></summary>

### Authentication Endpoints

`/api/v1/auth` (Public)

- Authentication endpoints accessible to all users
- Login, register, password reset, profile management

```
POST   /api/v1/auth/login                     # User login
POST   /api/v1/auth/register                  # User registration
POST   /api/v1/auth/logout                    # User logout
POST   /api/v1/auth/refresh                   # Refresh access token
POST   /api/v1/auth/password-reset/request    # Request password reset
POST   /api/v1/auth/password-reset/confirm    # Confirm password reset
GET    /api/v1/auth/me                        # Get current user profile
PUT    /api/v1/auth/me                        # Update current user profile
```

### Realtor Endpoints

`/api/v1/realtors` (Realtor-specific)

- Property Management: CRUD operations for realtor's properties
- Tour Management: Start/end tours, view recordings, transcripts
- Booking Management: View and manage bookings
- Video Calls: Create and manage video calls

```
# Property Management
GET    /api/v1/realtors/properties            # List realtor's properties
POST   /api/v1/realtors/properties            # Create property
GET    /api/v1/realtors/properties/:id        # Get property details
PUT    /api/v1/realtors/properties/:id        # Update property
DELETE /api/v1/realtors/properties/:id        # Delete property
POST   /api/v1/realtors/properties/:id/images # Upload property images
DELETE /api/v1/realtors/properties/:id/images/:image_id # Delete property image

# Tour Management
GET    /api/v1/realtors/tours                 # List realtor's tours
GET    /api/v1/realtors/tours/:id             # Get tour details
POST   /api/v1/realtors/tours/:id/start       # Start tour
POST   /api/v1/realtors/tours/:id/end         # End tour
GET    /api/v1/realtors/tours/:id/notes       # Get tour notes
POST   /api/v1/realtors/tours/:id/notes       # Add tour note
GET    /api/v1/realtors/tours/:id/recording   # Get tour recording
GET    /api/v1/realtors/tours/:id/transcript  # Get tour transcript
GET    /api/v1/realtors/tours/:id/highlights  # Get tour highlights
GET    /api/v1/realtors/tours/:id/summary     # Get tour summary

# Booking Management
GET    /api/v1/realtors/bookings              # List realtor's bookings
GET    /api/v1/realtors/bookings/:id          # Get booking details
PUT    /api/v1/realtors/bookings/:id          # Update booking
PUT    /api/v1/realtors/bookings/:id/confirm  # Confirm booking and create call
DELETE /api/v1/realtors/bookings/:id          # Cancel booking

# Video Calls
GET    /api/v1/realtors/calls/:id             # Get call details
POST   /api/v1/realtors/calls/:id/join        # Join video call
POST   /api/v1/realtors/calls/:id/leave       # Leave video call
POST   /api/v1/realtors/calls/:id/end         # End video call
GET    /api/v1/realtors/calls/:id/recording   # Get call recording
POST   /api/v1/realtors/calls/:id/record      # Start/stop call recording
```

### Buyer Endpoints

`/api/v1/buyers` (Buyer-specific)

- Property Browsing: View available properties
- Tour Booking: Create and manage bookings
- Tour Participation: View tour details, recordings, summaries
- Video Calls: Join/leave video calls

```
# Property Browsing
GET    /api/v1/buyers/properties              # Browse available properties
GET    /api/v1/buyers/properties/:id          # Get property details

# Tour Booking
GET    /api/v1/buyers/bookings                # List buyer's bookings
POST   /api/v1/buyers/bookings                # Create booking
GET    /api/v1/buyers/bookings/:id            # Get booking details
PUT    /api/v1/buyers/bookings/:id            # Update booking
DELETE /api/v1/buyers/bookings/:id            # Cancel booking

# Tour Participation
GET    /api/v1/buyers/tours                   # List buyer's tours
GET    /api/v1/buyers/tours/:id               # Get tour details
GET    /api/v1/buyers/tours/:id/notes         # Get tour notes
POST   /api/v1/buyers/tours/:id/notes         # Add tour note
GET    /api/v1/buyers/tours/:id/recording     # Get tour recording
GET    /api/v1/buyers/tours/:id/transcript    # Get tour transcript
GET    /api/v1/buyers/tours/:id/highlights    # Get tour highlights
GET    /api/v1/buyers/tours/:id/summary       # Get tour summary

# Video Calls
GET    /api/v1/buyers/calls/:id               # Get call details (if authorized)
POST   /api/v1/buyers/calls/:id/join          # Join video call
POST   /api/v1/buyers/calls/:id/leave         # Leave video call
GET    /api/v1/buyers/calls/:id/recording     # Get call recording
```

### Admin Endpoints

`/api/v1/admin` (Admin-only)
- User Management: CRUD operations for all users
- Property Management: Manage all properties
- Tour Management: View all tours
- Booking Management: Manage all bookings

```
# User Management
GET    /api/v1/admin/users                    # List all users
GET    /api/v1/admin/users/:id                # Get user details
PUT    /api/v1/admin/users/:id                # Update user
DELETE /api/v1/admin/users/:id                # Delete user
POST   /api/v1/admin/users/:id/avatar         # Upload user avatar

# Property Management
GET    /api/v1/admin/properties               # List all properties
GET    /api/v1/admin/properties/:id           # Get property details
PUT    /api/v1/admin/properties/:id           # Update property
DELETE /api/v1/admin/properties/:id           # Delete property

# Tour Management
GET    /api/v1/admin/tours                    # List all tours
GET    /api/v1/admin/tours/:id                # Get tour details
PUT    /api/v1/admin/tours/:id                # Update tour
DELETE /api/v1/admin/tours/:id                # Delete tour

# Booking Management
GET    /api/v1/admin/bookings                 # List all bookings
GET    /api/v1/admin/bookings/:id             # Get booking details
PUT    /api/v1/admin/bookings/:id             # Update booking
DELETE /api/v1/admin/bookings/:id             # Cancel booking
```

</details>

<details>
<summary><strong>API Response Format</strong></summary>

```ruby
# Standard API response format
{
  "success": true,
  "data": {
    "id": 1,
    "type": "property",
    "attributes": {
      "address": "123 Main St",
      "price": 500000,
      "bedrooms": 3,
      "bathrooms": 2
    },
    "relationships": {
      "realtor": {
        "data": {
          "id": 1,
          "type": "user"
        }
      }
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0"
  }
}

# Error response format
{
  "success": false,
  "errors": [
    {
      "code": "VALIDATION_ERROR",
      "message": "Address can't be blank",
      "field": "address"
    }
  ],
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0"
  }
}
```

</details>

## Audit Logs

<details>
<summary><strong>Simple Audit Logging (for MVP)</strong></summary>

```ruby
class AuditLog < ApplicationRecord
  belongs_to :user
  
  # Flexible logging method that matches your diagram
  def self.log(action, user_id:, **details)
    # Extract resource info from details
    resource_type = details.delete(:resource_type)
    resource_id = details.delete(:resource_id)
    
    # Handle special cases where resource is passed as a key
    if details[:call]
      resource_type = "Call"
      resource_id = details.delete(:call)
    elsif details[:tour]
      resource_type = "Tour" 
      resource_id = details.delete(:tour)
    elsif details[:property]
      resource_type = "Property"
      resource_id = details.delete(:property)
    end
    
    create!(
      user_id: user_id,
      action: action,
      resource_type: resource_type,
      resource_id: resource_id,
      details: details.to_json
    )
  end
end

# Usage in controllers
class Api::V1::Realtors::PropertiesController < ApplicationController
  def create
    property = current_user.properties.create!(property_params)
    
    # Simple audit log
    AuditLog.log('property_created', user_id: current_user.id, property: property.id)
    
    render json: property, status: :created
  end
end
```
</details>

## Background Jobs

| Job Type | Description |
|----------|-------------|
| **Notification Job** | Email reminders, tour notifications, booking confirmations |
| **Tour Processing Job** | Handle tour lifecycle, recordings, transcription, highlights, summaries |
| **Image Processing Job** | Resize/compress property images on upload |

<details>
<summary><strong>Notification Jobs</strong></summary>

```ruby
# Usage examples in controllers:
class Api::V1::Buyers::BookingsController < ApplicationController
  def create
    booking = current_user.bookings.create!(booking_params)
    
    # Send notification to realtor about new booking request
    NotificationJob.perform_later('new_booking_request', { booking_id: booking.id })
    
    render json: booking, status: :created
  end
end

class Api::V1::Realtors::BookingsController < ApplicationController
  def confirm
    booking = Booking.find(params[:id])
    authorize booking, :confirm?

    Booking.transaction do
      booking.update!(status: 'confirmed')
      
      # Create tour
      tour = Tour.create!(
        booking: booking,
        property: booking.property,
        realtor: current_user,
        buyer: booking.buyer,
        scheduled_at: booking.scheduled_at
      )
      
      # Create call
      call = Call.create!(
        tour: tour,
        status: 'created',
        chime_meeting_id: SecureRandom.uuid
      )
      
      # Send confirmation to both parties
      NotificationJob.perform_later('booking_confirmation', { booking_id: booking.id })
      
      # Schedule reminder 15 minutes before tour
      reminder_time = booking.scheduled_at - 15.minutes
      NotificationJob.set(wait_until: reminder_time).perform_later('booking_reminder', { booking_id: booking.id })
      
      render json: { booking: booking, tour: tour, call: call }
    end
  end
end

class Api::V1::Realtors::ToursController < ApplicationController
  def start
    tour = Tour.find(params[:id])
    
    # Start tour processing
    TourProcessingJob.perform_later('start_tour', { tour_id: tour.id })
    
    render json: { message: 'Tour starting...' }
  end
  
  def end
    tour = Tour.find(params[:id])
    
    # End tour and process everything
    TourProcessingJob.perform_later('end_tour', { tour_id: tour.id })
    
    render json: { message: 'Tour ending...' }
  end
end

# app/jobs/notification_job.rb
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_type, data)
    case notification_type
    when 'new_booking_request'
      send_new_booking_request(data[:booking_id])
    when 'booking_confirmation'
      send_booking_confirmation(data[:booking_id])
    when 'booking_reminder'
      send_booking_reminder(data[:booking_id])
    when 'tour_start'
      send_tour_start_notification(data[:tour_id])
    when 'tour_end'
      send_tour_end_notification(data[:tour_id])
    end
  end

  private

  def send_new_booking_request(booking_id)
    booking = Booking.find(booking_id)
    BookingMailer.new_booking_request_email(booking).deliver_now
  end

  def send_booking_confirmation(booking_id)
    booking = Booking.find(booking_id)
    BookingMailer.confirmation_email(booking).deliver_now
  end

  def send_booking_reminder(booking_id)
    booking = Booking.find(booking_id)
    BookingMailer.reminder_email(booking).deliver_now
    BookingMailer.realtor_reminder_email(booking).deliver_now
  end

  def send_tour_start_notification(tour_id)
    tour = Tour.find(tour_id)
    TourMailer.start_notification(tour).deliver_now
  end

  def send_tour_end_notification(tour_id)
    tour = Tour.find(tour_id)
    TourMailer.end_notification(tour).deliver_now
  end
end
```

</details>

<details>
<summary><strong>Tour Processing Jobs</strong></summary>

```ruby
# app/jobs/tour_processing_job.rb
class TourProcessingJob < ApplicationJob
  queue_as :default

  def perform(processing_type, data)
    case processing_type
    when 'start_tour'
      start_tour(data[:tour_id])
    when 'end_tour'
      end_tour(data[:tour_id])
    when 'process_recording'
      process_recording(data[:tour_id])
    when 'generate_ai_content'
      generate_ai_content(data[:tour_id])
    end
  end

  private

  def start_tour(tour_id)
    tour = Tour.find(tour_id)
    
    # Create Chime meeting
    chime_service = ChimeService.new
    meeting = chime_service.create_meeting(tour)
    
    # Update tour
    tour.update!(
      status: 'in_progress',
      started_at: Time.current,
      chime_meeting_id: meeting.meeting_id
    )
    
    # Send notification
    NotificationJob.perform_later('tour_start', { tour_id: tour_id })
  end

  def end_tour(tour_id)
    tour = Tour.find(tour_id)
    
    # Update tour status
    tour.update!(
      status: 'completed',
      ended_at: Time.current
    )
    
    # Process recording
    process_recording(tour_id)
    
    # Send notification
    NotificationJob.perform_later('tour_end', { tour_id: tour_id })
  end

  def process_recording(tour_id)
    tour = Tour.find(tour_id)
    
    # Download and store recording
    chime_service = ChimeService.new
    video_file = chime_service.download_recording(tour.chime_meeting_id)
    
    s3_service = S3Service.new
    video_url = s3_service.upload_recording(video_file, tour.id)
    
    # Create recording record
    Recording.create!(
      tour_id: tour_id,
      video_url: video_url,
      recorded_at: tour.ended_at
    )
    
    # Generate AI content
    generate_ai_content(tour_id)
  end

  def generate_ai_content(tour_id)
    tour = Tour.find(tour_id)
    recording = tour.recording
    
    # Transcribe audio
    transcription_service = TranscriptionService.new
    transcript_data = transcription_service.transcribe(recording.video_url)
    
    # Create transcript
    Transcript.create!(
      tour_id: tour_id,
      full_text: transcript_data[:text],
      segments: transcript_data[:segments],
      confidence_score: transcript_data[:confidence]
    )
    
    # Generate highlights
    highlight_service = HighlightDetectionService.new
    highlights = highlight_service.detect_highlights(transcript_data)
    
    highlights.each do |highlight|
      Highlight.create!(
        tour_id: tour_id,
        timestamp_ms: highlight[:timestamp],
        note: highlight[:description],
        highlight_type: highlight[:type]
      )
    end
    
    # Generate summary
    summary_service = SummaryService.new
    summary = summary_service.generate_summary(tour)
    
    tour.update!(summary: summary)
  end
end
```
</details>

<details>
<summary><strong>Image Processing Job</strong></summary>

```ruby
# app/jobs/image_processing_job.rb
class ImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = PropertyImage.find(image_id)
    processed_file = ImageProcessingService.new.process(image.file)

    # Update the image record with processed file info (e.g., new URL, thumbnail, etc.)
    image.update!(
      processed_url: processed_file.url,
      thumbnail_url: processed_file.thumbnail_url
    )
  end
end
```
</details>

## Services

<details>
<summary><strong>Video Services</strong></summary>

```ruby
# app/services/chime_service.rb
class ChimeService
  def initialize
    @chime_client = Aws::ChimeSDKMeetings::Client.new(
      region: Rails.application.credentials.aws[:region],
      credentials: Aws::Credentials.new(
        Rails.application.credentials.aws[:access_key_id],
        Rails.application.credentials.aws[:secret_access_key]
      )
    )
  end

  def create_meeting(tour)
    response = @chime_client.create_meeting(
      client_request_token: SecureRandom.uuid,
      external_meeting_id: "tour_#{tour.id}",
      media_region: 'us-east-1',
      meeting_configuration: {
        audio: {
          echo_reduction: 'AVAILABLE'
        }
      }
    )
    
    response.meeting
  end

  def create_attendee(meeting_id, user)
    response = @chime_client.create_attendee(
      external_user_id: user.id.to_s,
      meeting_id: meeting_id
    )
    
    response.attendee
  end

  def download_recording(recording_id)
    # Implementation for downloading recording
  end
end

# app/services/video_processing_service.rb
class VideoProcessingService
  def process(video_file)
    # Note: For MVP, video processing is not required.
    # Chime recordings are stored and served as-is from S3.
    # This service can be implemented later if advanced video processing
    # (compression, watermarking, format conversion) is needed.
    
    # For now, we're returning the original file path
    video_file.path
  end
end
```

</details>

<details>
<summary><strong>AI Services</strong></summary>

```ruby
# app/services/transcription_service.rb
class TranscriptionService
  def initialize
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key]
    )
  end

  def transcribe(video_url)
    # Download audio from video
    audio_file = download_audio(video_url)
    
    # Transcribe using OpenAI Whisper
    response = @client.audio.transcribe(
      parameters: {
        model: "whisper-1",
        file: File.open(audio_file.path),
        response_format: "verbose_json",
        timestamp_granularities: ["segment"]
      }
    )
    
    {
      text: response.text,
      segments: response.segments,
      confidence: response.language
    }
  end

  private

  def download_audio(video_url)
    # Implementation for downloading audio from video
  end
end

# app/services/highlight_detection_service.rb
class HighlightDetectionService
  def initialize
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key]
    )
  end

  def detect_highlights(transcript)
    prompt = build_highlight_prompt(transcript.full_text)
    
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a real estate expert. Identify key moments and highlights from property tours." },
          { role: "user", content: prompt }
        ],
        temperature: 0.3
      }
    )
    
    parse_highlights(response.choices.first.message.content, transcript.segments)
  end

  private

  def build_highlight_prompt(text)
    "Analyze this property tour transcript and identify key highlights:\n\n#{text}\n\nReturn highlights in JSON format with timestamp and description."
  end

  def parse_highlights(ai_response, segments)
    # Parse AI response and map to segments
  end
end
```

</details>

<details>
<summary><strong>Email Services</strong></summary>

```ruby
# app/services/email_service.rb
class EmailService
  def send_booking_confirmation(booking)
    BookingMailer.confirmation_email(booking).deliver_now
  end

  def send_tour_reminder(booking)
    BookingMailer.reminder_email(booking).deliver_now
  end

  def send_tour_summary(tour)
    TourMailer.summary_email(tour).deliver_now
  end
end

# app/mailers/booking_mailer.rb
class BookingMailer < ApplicationMailer
  def new_booking_request_email(booking)
    @booking = booking
    @property = booking.property
    @buyer = booking.buyer
    
    mail(
      to: booking.property.realtor.email,
      subject: "New Tour Request: #{@property.address}"
    )
  end

  def confirmation_email(booking)
    @booking = booking
    @property = booking.property
    @realtor = booking.property.realtor
    
    mail(
      to: booking.buyer.email,
      subject: "Tour Confirmed: #{@property.address}"
    )
  end

  def reminder_email(booking)
    @booking = booking
    @property = booking.property
    
    mail(
      to: booking.buyer.email,
      subject: "Reminder: Your tour starts in 15 minutes"
    )
  end

  def realtor_reminder_email(booking)
    @booking = booking
    @property = booking.property
    @buyer = booking.buyer
    
    mail(
      to: booking.property.realtor.email,
      subject: "Reminder: Tour starts in 15 minutes"
    )
  end
end
```
</details>

<details>
<summary><strong>Image Processing Service</strong></summary>

```ruby
# app/services/image_processing_service.rb
class ImageProcessingService
  def process(file)
    # Example: Resize, compress, and generate thumbnail
    # (Implementation depends on the image processing library, e.g., MiniMagick)
    processed = MiniMagick::Image.open(file.path)
    processed.resize "1200x800"
    processed.write file.path

    thumbnail = processed.clone
    thumbnail.resize "300x200"
    thumbnail_path = file.path.sub(/(\.\w+)$/, '_thumb\\1')
    thumbnail.write thumbnail_path

    OpenStruct.new(
      url: upload_to_s3(file.path),
      thumbnail_url: upload_to_s3(thumbnail_path)
    )
  end

  def upload_to_s3(path)
    # Upload file to S3 and return the public URL
    # (Implementation depends on the S3 integration)
  end
end
```
</details>

## Performance & Caching

<details>
<summary><strong>Redis Caching</strong></summary>

Redis is used primarily for background job queues (Sidekiq) and session storage. For MVP, complex API response caching is not required - database queries are fast enough at this scale.

**Future Release - Advanced Redis Capabilities:**
Redis is an in-memory data store that can significantly improve application performance and scalability by caching frequently accessed data. In future releases, Redis can be expanded to include:

- **API response caching:** Store the results of expensive or frequently requested queries, reducing database load and improving response times for users.
- **Session storage:** Manage user sessions in a scalable, distributed way, especially useful for stateless APIs and multi-instance deployments.
- **Rate limiting:** Track request counts per user or IP to enforce API rate limits efficiently.
- **Background job queues:** (via Sidekiq) Redis acts as the broker for background jobs, enabling reliable and scalable job processing.

By caching data in Redis, the system can serve repeated requests much faster, reduce latency, and handle higher traffic without overloading the primary database.

</details>

<details>
<summary><strong>Database Optimization</strong></summary>

- Eager Loading: Avoid the N+1 query problem, where fetching related records causes many small queries.
- Pagination: Prevent loading too much data into memory and overwhelming the client or server.
- Indexing: Speed up lookups, filtering, and sorting on frequently queried columns.

```ruby
# app/models/property.rb
class Property < ApplicationRecord
  # Eager loading associations
  scope :with_realtor, -> { includes(:realtor) }
  scope :with_tours, -> { includes(:tours) }
  scope :with_bookings, -> { includes(:bookings) }
  
  # Pagination
  scope :paginated, ->(page: 1, per_page: 20) {
    offset((page - 1) * per_page).limit(per_page)
  }
  
  # Search
  scope :search, ->(query) {
    where("address ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  }
  
  # Performance optimizations
  scope :active, -> { where(status: 'active') }
  scope :by_realtor, ->(realtor_id) { where(realtor_id: realtor_id) }
end

# app/controllers/api/v1/realtors/properties_controller.rb
class Api::V1::Realtors::PropertiesController < ApplicationController
  def index
    properties = Property.with_realtor
                        .active
                        .search(params[:query])
                        .paginated(page: params[:page], per_page: params[:per_page])

    render json: {
      data: properties,
      meta: {
        current_page: params[:page]&.to_i || 1,
        total_pages: (properties.total_count.to_f / (params[:per_page]&.to_i || 20)).ceil,
        total_count: properties.total_count
      }
    }
  end
end
```

</details>

## Security

</details>

<details>
<summary><strong>Data Protection</strong></summary>

This Encryptable concern adds transparent encryption and decryption for sensitive fields such as email, phone number or SSN in ActiveRecord models. Using AES-256-GCM, it encrypts data before saving and decrypts it after retrieval, keeping plain-text values out of the database while allowing seamless model interaction.

```ruby
# app/models/concerns/encryptable.rb
module Encryptable
  extend ActiveSupport::Concern

  included do
    before_save :encrypt_sensitive_data
    after_find :decrypt_sensitive_data
  end

  private

  def encrypt_sensitive_data
    self.encrypted_ssn = encrypt(ssn) if ssn_changed?
    self.encrypted_phone = encrypt(phone) if phone_changed?
  end

  def decrypt_sensitive_data
    self.ssn = decrypt(encrypted_ssn) if encrypted_ssn.present?
    self.phone = decrypt(encrypted_phone) if encrypted_phone.present?
  end

  def encrypt(value)
    return nil if value.blank?
    
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.encrypt
    cipher.key = Rails.application.credentials.secret_key_base[0..31]
    cipher.iv = cipher.random_iv
    
    encrypted = cipher.update(value) + cipher.final
    auth_tag = cipher.auth_tag
    
    Base64.strict_encode64(encrypted + auth_tag)
  end

  def decrypt(encrypted_value)
    return nil if encrypted_value.blank?
    
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = Rails.application.credentials.secret_key_base[0..31]
    
    decoded = Base64.strict_decode64(encrypted_value)
    auth_tag = decoded[-16..-1]
    encrypted = decoded[0...-16]
    
    cipher.auth_tag = auth_tag
    cipher.auth_data = ""
    
    cipher.update(encrypted) + cipher.final
  end
end
```
</details>

## Error Handling

<details>
<summary><strong>Error Handling Structure</strong></summary>

| Component | Description |
|-----------|-------------|
| **Global Exception Handler** | Centralized error processing |
| **Custom Error Classes** | Domain-specific errors |
| **Error Logging** | Structured error logging |
| **Client Error Responses** | User-friendly error messages |

</details>

## Testing Strategy

<details>
<summary><strong>Test Structure</strong></summary>

```
spec/
├── controllers/
│   └── api/v1/
│       ├── auth_controller_spec.rb
│       ├── realtors/
│       │   ├── properties_controller_spec.rb
│       │   ├── tours_controller_spec.rb
│       │   ├── bookings_controller_spec.rb
│       │   └── calls_controller_spec.rb
│       ├── buyers/
│       │   ├── properties_controller_spec.rb
│       │   ├── bookings_controller_spec.rb
│       │   ├── tours_controller_spec.rb
│       │   └── calls_controller_spec.rb
│       └── admin/
│           ├── users_controller_spec.rb
│           ├── properties_controller_spec.rb
│           ├── tours_controller_spec.rb
│           └── bookings_controller_spec.rb
├── models/
│   ├── user_spec.rb
│   ├── property_spec.rb
│   ├── booking_spec.rb
│   ├── tour_spec.rb
│   ├── call_spec.rb
│   ├── tour_note_spec.rb
│   ├── transcript_spec.rb
│   ├── highlight_spec.rb
│   ├── recording_spec.rb
│   ├── audit_log_spec.rb
├── services/
│   ├── tour_lifecycle_service_spec.rb
│   ├── video_processing_service_spec.rb
│   ├── transcription_service_spec.rb
│   ├── highlight_detection_service_spec.rb
│   ├── summary_service_spec.rb
│   ├── image_processing_service_spec.rb
│   └── booking_confirmation_service_spec.rb
├── jobs/
│   ├── notification_job_spec.rb
│   ├── tour_processing_job_spec.rb
│   └── image_processing_job_spec.rb
├── concerns/
│   ├── authentication_spec.rb
│   ├── logging_spec.rb
│   └── validation_spec.rb
├── requests/
│   └── api/v1/
│       ├── auth_spec.rb
│       ├── realtors/
│       │   ├── properties_spec.rb
│       │   ├── tours_spec.rb
│       │   ├── bookings_spec.rb
│       │   └── calls_spec.rb
│       ├── buyers/
│       │   ├── properties_spec.rb
│       │   ├── bookings_spec.rb
│       │   ├── tours_spec.rb
│       │   └── calls_spec.rb
│       └── admin/
│           ├── users_spec.rb
│           ├── properties_spec.rb
│           ├── tours_spec.rb
│           └── bookings_spec.rb
└── factories/
    ├── users.rb
    ├── properties.rb
    ├── bookings.rb
    ├── tours.rb
    ├── calls.rb
    ├── tour_notes.rb
    ├── transcripts.rb
    ├── highlights.rb
    ├── recordings.rb
    └── audit_logs.rb
```
</details>

## Video SDK

<details>
<summary><strong>Chime SDK Integration</strong></summary>

### Overview

The RealtyForYou backend uses the [Amazon Chime SDK](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html) to power real-time video tours, including audio, video, and screen sharing for web and mobile clients.

---

### Backend (Rails API) Responsibilities

- **Meeting Lifecycle:**  
  - Create Chime meetings and attendees via AWS SDK or REST API.
  - End meetings and trigger post-processing (recording).
- **Security:**  
  - All Chime API calls are made server-side.
  - Use IAM roles with least-privilege access.
- **Endpoints:**  
  - `POST /api/v1/realtors/tours/:id/start` → Start tour (automatically creates Chime meeting).
  - `POST /api/v1/realtors/tours/:id/end` → End tour (automatically ends Chime meeting).
  - `POST /api/v1/realtors/calls/:id/join` → Join existing meeting (realtor).
  - `POST /api/v1/buyers/calls/:id/join` → Join existing meeting (buyer).
  - `POST /api/v1/buyers/calls/:id/leave` → Leave meeting (buyer).

**Example Ruby:**
```ruby
chime = Aws::ChimeSDKMeetings::Client.new(region: 'us-east-1')
meeting = chime.create_meeting(client_request_token: SecureRandom.uuid, media_region: 'us-east-1')
attendee = chime.create_attendee(meeting_id: meeting.meeting.meeting_id, external_user_id: user.id.to_s)
```

---

### Recording & Transcription

- **Media Pipelines:**  
  - Use Chime Media Pipelines API to record meetings and store recordings in S3.
  - All transcription is performed using OpenAI Whisper via the backend service.

---

### Security & Compliance

- All Chime API calls are made from the backend.
- We should consider using encrypted S3 buckets for recordings

---

### References

- [Chime SDK API Reference](https://docs.aws.amazon.com/chime-sdk/latest/APIReference/welcome.html)
- [Chime SDK Developer Guide](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html)

</details>

## Deployment

<details>
<summary><strong>Docker Configuration</strong></summary>

```dockerfile
# Dockerfile
FROM ruby:3.2.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/realtyforyou
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=realtyforyou
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  sidekiq:
    build: .
    command: bundle exec sidekiq
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/realtyforyou
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle

volumes:
  postgres_data:
  redis_data:
  bundle_cache:
```

</details>

<details>
<summary><strong>AWS Deployment</strong></summary>

```yaml
# .github/workflows/deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR (AWS Container Registry)
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: realtyforyou-backend
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
      
      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster realtyforyou-cluster \
            --service realtyforyou-backend \
            --force-new-deployment
```

</details>

## Final Considerations

<details>
<summary><strong>DevOps & CI/CD</strong></summary>

| Consideration | Description |
|---------------|-------------|
| **AWS ECS** | Container orchestration |
| **GitHub Actions** | Automated testing and deployment |
| **Docker** | Containerized application deployment |
| **Infrastructure as Code (IaC)** | Terraform modules provision VPCs, ECS clusters, RDS, and S3 buckets |
| **Branching Strategy** | Trunk-based development with short-lived feature branches; protected `main` branch with required status checks |
| **Environment Strategy** | Isolated **dev**, **staging**, and **production** accounts; feature flags for risky features |
| **Secrets Management** | AWS Secrets Manager and SSM Parameter Store; rotation policies for DB and JWT secrets |
| **Rollback & Release** | Blue-green by default; canary releases for high-risk changes; one-click rollback via ECS task definition history |
| **CI Quality Gates** | Linting, tests, security scans (Snyk) must pass before merge |

</details>

<details>
<summary><strong>Observability</strong></summary>

| Component | Description |
|-----------|-------------|
| **Key Metrics** | API p95 latency, video call setup time, Chime meeting duration, error rates, CPU/Memory of ECS tasks |
| **Dashboards** | Real-time Grafana dashboards for business KPIs (tours per day) and system KPIs |
| **Alerting** | PagerDuty integration; SLO-based alerts (e.g., >1% error rate for 5 min) route to on-call engineer |

</details>

<details>
<summary><strong>Scalability & Availability</strong></summary>

| Aspect | Description |
|--------|-------------|
| **Target Scale** | 10 k concurrent users / 500 simultaneous video tours in MVP phase |
| **Multi-AZ Deployment** | ECS services span at least 2 AZs; RDS in Multi-AZ mode with automatic fail-over |
| **Auto-Scaling** | ALB request count and custom Chime metrics drive ECS task scaling |
| **Read Replicas & Caching** | Add RDS read replicas and Redis caching tier when read QPS > 2 k |
| **Disaster Recovery** | Daily RDS snapshots (retain 7 days) + S3 cross-region replication |

</details>

<details>
<summary><strong>Security & Compliance</strong></summary>

| Security Measure | Description |
|------------------|-------------|
| **Data Classification** | Recordings, and transcripts stored in encrypted S3 buckets (SSE-KMS) |
| **Vulnerability Management** | Weekly Snyk scans; monthly dependency upgrades |
| **Incident Response** | Document incidents; do post-mortems within 48 h |
| **Logging & Audit** | CloudTrail enabled for all accounts |

</details>

<details>
<summary><strong>API Documentation & Tooling</strong></summary>

| Tool | Description |
|------|-------------|
| **OpenAPI (Swagger)**  | Auto-generated YAML spec from Rails controllers; hosted at `/docs` |
| **Postman Collection** | Shared with frontend, QA & partners |

</details>
