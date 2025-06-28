# Backend Architecture Overview

## 🏗️ System Architecture

The backend is built with **Ruby on Rails 7** in API mode, designed to support real estate video tours with real-time communication, property management, and comprehensive analytics.

<details>
<summary><strong>🔧 Core Technologies</strong></summary>

- **Ruby on Rails 7** - Web framework with API mode
- **PostgreSQL** - Primary relational database
- **Redis** - Caching and session storage
- **JWT** - Authentication tokens
- **AWS Chime SDK** - Video communication
- **Active Job** - Background job processing
- **Sidekiq** - Job queue management

</details>

## 📁 Project Structure

```
app/
├── controllers/
│   └── api/v1/
│       ├── auth/
│       │   ├── registrations_controller.rb
│       │   ├── sessions_controller.rb
│       │   └── password_resets_controller.rb
│       ├── dashboards/
│       │   ├── realtor_controller.rb
│       │   └── buyer_controller.rb
│       ├── analytics/
│       │   └── realtor_controller.rb
│       ├── properties_controller.rb
│       ├── bookings_controller.rb
│       ├── calls_controller.rb
│       └── uploads_controller.rb
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
│   ├── analytics_aggregate.rb
│   ├── audit_log.rb
│   └── password_reset_token.rb
├── services/
│   ├── password_reset_service.rb
│   ├── tour_lifecycle_service.rb
│   ├── video_processing_service.rb
│   ├── transcription_service.rb
│   ├── highlight_detection_service.rb
│   ├── summary_service.rb
│   ├── image_processing_service.rb
│   ├── external_sync_service.rb
│   └── audit_log_processor.rb
├── jobs/
│   ├── booking_reminder_job.rb
│   ├── tour_start_job.rb
│   ├── tour_end_job.rb
│   ├── recording_processing_job.rb
│   ├── transcription_job.rb
│   ├── highlight_job.rb
│   ├── tour_summary_job.rb
│   ├── recording_cleanup_job.rb
│   ├── dashboard_aggregator_job.rb
│   ├── analytics_ingestion_job.rb
│   ├── image_processing_job.rb
│   ├── external_data_sync_job.rb
│   └── audit_log_processing_job.rb
└── concerns/
    ├── authentication.rb
    ├── caching.rb
    ├── logging.rb
    └── validation.rb
```

</details>

## 🗄️ Database Schema

<details>
<summary><strong>📊 Core Tables</strong></summary>

#### Users Table
```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  role VARCHAR(50) DEFAULT 'buyer',
  password_digest VARCHAR(255) NOT NULL,
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
  actor_id BIGINT REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(100),
  target_id BIGINT,
  meta JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL
);
```

#### Password Reset Tokens Table
```sql
CREATE TABLE password_reset_tokens (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id),
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL
);
```

</details>

<details>
<summary><strong>📈 Analytics Tables</strong></summary>

#### Analytics Aggregates Table
```sql
CREATE TABLE analytics_aggregates (
  id BIGSERIAL PRIMARY KEY,
  date DATE NOT NULL,
  realtor_id BIGINT REFERENCES users(id),
  metric_name VARCHAR(100) NOT NULL,
  metric_value DECIMAL(10,2),
  metadata JSONB,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE(date, realtor_id, metric_name)
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
  changes JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL
);
```

</details>

<details>
<summary><strong>🔄 Relationships & Indexes</strong></summary>

#### Key Indexes
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
CREATE INDEX idx_analytics_aggregates_date_realtor ON analytics_aggregates(date, realtor_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Full-text search indexes
CREATE INDEX idx_properties_address_gin ON properties USING gin(to_tsvector('english', address));
CREATE INDEX idx_properties_description_gin ON properties USING gin(to_tsvector('english', description));
```

</details>

## 🔐 Authentication & Authorization

<details>
<summary><strong>🔑 JWT Implementation</strong></summary>

```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      @decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      @current_user = User.find(@decoded[0]['user_id'])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def user_signed_in?
    !!current_user
  end
end
```

</details>

<details>
<summary><strong>🛡️ Authorization Policies</strong></summary>

```ruby
# app/policies/property_policy.rb
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

## 🎯 API Design

<details>
<summary><strong>📋 API Endpoints</strong></summary>

### Authentication Endpoints
```
POST   /api/v1/auth/register          # User registration
POST   /api/v1/auth/login             # User login
POST   /api/v1/auth/logout            # User logout
POST   /api/v1/auth/refresh           # Token refresh
POST   /api/v1/auth/password-reset    # Password reset request
POST   /api/v1/auth/password-reset/confirm # Password reset confirmation
```

### Property Endpoints
```
GET    /api/v1/properties             # List properties
POST   /api/v1/properties             # Create property
GET    /api/v1/properties/:id         # Get property details
PUT    /api/v1/properties/:id         # Update property
DELETE /api/v1/properties/:id         # Delete property
GET    /api/v1/properties/:id/tours   # Get property tours
```

### Booking Endpoints
```
GET    /api/v1/bookings               # List bookings
POST   /api/v1/bookings               # Create booking
GET    /api/v1/bookings/:id           # Get booking details
PUT    /api/v1/bookings/:id           # Update booking
DELETE /api/v1/bookings/:id           # Cancel booking
```

### Tour Endpoints
```
GET    /api/v1/tours                  # List tours
POST   /api/v1/tours                  # Create tour
GET    /api/v1/tours/:id              # Get tour details
PUT    /api/v1/tours/:id              # Update tour
POST   /api/v1/tours/:id/start        # Start tour
POST   /api/v1/tours/:id/end          # End tour
GET    /api/v1/tours/:id/notes        # Get tour notes
POST   /api/v1/tours/:id/notes        # Add tour note
```

### Analytics Endpoints
```
GET    /api/v1/analytics/realtor      # Realtor analytics
GET    /api/v1/analytics/dashboard    # Dashboard metrics
GET    /api/v1/analytics/tours        # Tour analytics
```

</details>

<details>
<summary><strong>📝 API Response Format</strong></summary>

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

## 🔄 Background Jobs

<details>
<summary><strong>📧 Email Jobs</strong></summary>

```ruby
# app/jobs/booking_reminder_job.rb
class BookingReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    
    # Send reminder email to buyer
    BookingMailer.reminder_email(booking).deliver_now
    
    # Send reminder email to realtor
    BookingMailer.realtor_reminder_email(booking).deliver_now
    
    # Log the reminder
    Rails.logger.info "Reminder sent for booking #{booking_id}"
  end
end

# app/jobs/tour_start_job.rb
class TourStartJob < ApplicationJob
  queue_as :default

  def perform(tour_id)
    tour = Tour.find(tour_id)
    
    # Create Chime meeting
    chime_service = ChimeService.new
    meeting = chime_service.create_meeting(tour)
    
    # Update tour with meeting details
    tour.update!(
      status: 'in_progress',
      started_at: Time.current,
      chime_meeting_id: meeting.meeting_id
    )
    
    # Send notifications
    TourNotificationService.new(tour).send_start_notification
  end
end
```

</details>

<details>
<summary><strong>🎥 Video Processing Jobs</strong></summary>

```ruby
# app/jobs/recording_processing_job.rb
class RecordingProcessingJob < ApplicationJob
  queue_as :video_processing

  def perform(recording_id)
    recording = Recording.find(recording_id)
    
    # Download recording from Chime
    chime_service = ChimeService.new
    video_file = chime_service.download_recording(recording.chime_recording_id)
    
    # Process video (compress, add watermark, etc.)
    video_processor = VideoProcessingService.new
    processed_video = video_processor.process(video_file)
    
    # Upload to S3
    s3_service = S3Service.new
    video_url = s3_service.upload_recording(processed_video, recording.id)
    
    # Update recording record
    recording.update!(
      status: 'processed',
      video_url: video_url,
      processed_at: Time.current
    )
    
    # Trigger transcription
    TranscriptionJob.perform_later(recording.id)
  end
end

# app/jobs/transcription_job.rb
class TranscriptionJob < ApplicationJob
  queue_as :video_processing

  def perform(recording_id)
    recording = Recording.find(recording_id)
    
    # Transcribe audio
    transcription_service = TranscriptionService.new
    transcript_data = transcription_service.transcribe(recording.video_url)
    
    # Create transcript record
    Transcript.create!(
      tour_id: recording.tour_id,
      full_text: transcript_data[:text],
      segments: transcript_data[:segments],
      confidence_score: transcript_data[:confidence]
    )
    
    # Trigger highlight detection
    HighlightJob.perform_later(recording.tour_id)
  end
end
```

</details>

<details>
<summary><strong>📊 Analytics Jobs</strong></summary>

```ruby
# app/jobs/dashboard_aggregator_job.rb
class DashboardAggregatorJob < ApplicationJob
  queue_as :analytics

  def perform(realtor_id = nil)
    realtors = realtor_id ? [User.find(realtor_id)] : User.where(role: 'realtor')
    
    realtors.each do |realtor|
      # Calculate daily metrics
      daily_metrics = calculate_daily_metrics(realtor)
      
      # Store in analytics aggregates
      daily_metrics.each do |metric|
        AnalyticsAggregate.create_or_find_by(
          date: Date.current,
          realtor_id: realtor.id,
          metric_name: metric[:name]
        ).update!(metric_value: metric[:value])
      end
    end
  end

  private

  def calculate_daily_metrics(realtor)
    [
      {
        name: 'tours_completed',
        value: realtor.tours.where(status: 'completed', created_at: Date.current.all_day).count
      },
      {
        name: 'bookings_created',
        value: realtor.bookings.where(created_at: Date.current.all_day).count
      },
      {
        name: 'properties_viewed',
        value: realtor.properties.joins(:tours).where(tours: { created_at: Date.current.all_day }).distinct.count
      }
    ]
  end
end
```

</details>

## 🔧 Services

<details>
<summary><strong>🎥 Video Services</strong></summary>

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
    # Use FFmpeg for video processing
    output_path = Rails.root.join('tmp', "processed_#{SecureRandom.uuid}.mp4")
    
    system("ffmpeg -i #{video_file.path} -c:v libx264 -c:a aac -b:v 1M -b:a 128k #{output_path}")
    
    output_path
  end
end
```

</details>

<details>
<summary><strong>🤖 AI Services</strong></summary>

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
<summary><strong>📧 Email Services</strong></summary>

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
end
```

</details>

## 🚀 Performance & Caching

<details>
<summary><strong>💾 Redis Caching</strong></summary>

```ruby
# app/controllers/concerns/caching.rb
module Caching
  extend ActiveSupport::Concern

  included do
    before_action :set_cache_headers
  end

  private

  def set_cache_headers
    response.headers['Cache-Control'] = 'public, max-age=300' # 5 minutes
  end

  def cache_key(record, *additional_keys)
    keys = [record.class.name, record.id, record.updated_at.to_i]
    keys.concat(additional_keys) if additional_keys.any?
    keys.join('/')
  end

  def cached_property(property_id)
    Rails.cache.fetch("property:#{property_id}", expires_in: 1.hour) do
      Property.includes(:realtor, :tours).find(property_id)
    end
  end

  def cached_user_properties(user_id)
    Rails.cache.fetch("user_properties:#{user_id}", expires_in: 30.minutes) do
      Property.where(realtor_id: user_id).includes(:tours)
    end
  end
end
```

</details>

<details>
<summary><strong>📊 Database Optimization</strong></summary>

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

# app/controllers/api/v1/properties_controller.rb
class Api::V1::PropertiesController < ApplicationController
  include Caching

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

## 🔒 Security

<details>
<summary><strong>🛡️ Security Measures</strong></summary>

```ruby
# config/application.rb
module RealtyForYou
  class Application < Rails::Application
    # Security headers
    config.middleware.use Rack::Attack
    config.middleware.insert_before ActionDispatch::Static, Rack::Deflater
    
    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins Rails.application.credentials.allowed_origins
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end
  end
end

# config/initializers/rack_attack.rb
class Rack::Attack
  # Rate limiting
  throttle('requests by ip', limit: 300, period: 5.minutes) do |request|
    request.ip
  end

  # Login rate limiting
  throttle('login attempts by ip', limit: 5, period: 20.seconds) do |request|
    if request.path == '/api/v1/auth/login' && request.post?
      request.ip
    end
  end

  # API rate limiting
  throttle('api requests by user', limit: 1000, period: 1.hour) do |request|
    if request.path.start_with?('/api/')
      request.env['jwt.payload']&.dig('user_id')
    end
  end
end
```

</details>

<details>
<summary><strong>🔐 Data Protection</strong></summary>

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

## 🧪 Testing Strategy

<details>
<summary><strong>🧪 Test Structure</strong></summary>

```
spec/
├── controllers/
│   └── api/v1/
│       ├── auth/
│       ├── properties_controller_spec.rb
│       ├── bookings_controller_spec.rb
│       └── tours_controller_spec.rb
├── models/
│   ├── user_spec.rb
│   ├── property_spec.rb
│   ├── booking_spec.rb
│   └── tour_spec.rb
├── services/
│   ├── chime_service_spec.rb
│   ├── transcription_service_spec.rb
│   └── email_service_spec.rb
├── jobs/
│   ├── booking_reminder_job_spec.rb
│   └── recording_processing_job_spec.rb
└── requests/
    └── api/
        └── v1/
            ├── properties_spec.rb
            ├── bookings_spec.rb
            └── tours_spec.rb
```

</details>

<details>
<summary><strong>🔧 Test Configuration</strong></summary>

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  
  # Database cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end
  
  config.before(:each) do
    DatabaseCleaner.start
  end
  
  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    full_name { "John Doe" }
    password { "password123" }
    role { "buyer" }
    
    trait :realtor do
      role { "realtor" }
    end
    
    trait :admin do
      role { "admin" }
    end
  end
end
```

</details>

## 🚀 Deployment

<details>
<summary><strong>🐳 Docker Configuration</strong></summary>

```dockerfile
# Dockerfile
FROM ruby:3.2.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    nodejs \
    ffmpeg \
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
<summary><strong>☁️ AWS Deployment</strong></summary>

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
      
      - name: Login to Amazon ECR
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

This comprehensive backend architecture provides a robust foundation for the real estate video tour platform with proper security, performance optimization, and scalability considerations. 