# Backend Architecture Overview

## 🏗️ System Architecture

The backend is built with **Ruby on Rails 7** in API mode, designed to support real estate video tours with real-time communication, property management, and comprehensive analytics.

### Core Technologies
- **Ruby on Rails 7** - Web framework with API mode
- **PostgreSQL** - Primary relational database
- **Redis** - Caching and session storage
- **JWT** - Authentication tokens
- **AWS Chime SDK** - Video communication
- **Active Job** - Background job processing
- **Sidekiq** - Job queue management

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

## 🗄️ Database Schema

### Core Tables

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

## 🌐 API Endpoints

### Authentication Endpoints
```ruby
# POST /api/v1/auth/register
# Create new user account
{
  "user": {
    "full_name": "John Doe",
    "email": "john@example.com",
    "password": "secure_password",
    "role": "buyer"
  }
}

# POST /api/v1/auth/login
# Authenticate user and return JWT
{
  "email": "john@example.com",
  "password": "secure_password"
}

# POST /api/v1/auth/password-reset/request
# Send password reset email
{
  "email": "john@example.com"
}

# POST /api/v1/auth/password-reset/confirm
# Reset password with token
{
  "token": "reset_token_here",
  "password": "new_password"
}
```

### User Management
```ruby
# GET /api/v1/users/:id
# Get user profile
# Returns: User object with profile data

# PATCH /api/v1/users/:id
# Update user profile
{
  "user": {
    "full_name": "John Smith",
    "phone": "+1234567890"
  }
}
```

### Property Management
```ruby
# GET /api/v1/properties
# List properties with filters
# Query params: page, per_page, status, price_min, price_max, bedrooms, bathrooms

# POST /api/v1/properties
# Create new property (realtor only)
{
  "property": {
    "address": "123 Main St, City, State",
    "mls_id": "MLS123456",
    "description": "Beautiful home with great views",
    "price": 750000,
    "bedrooms": 3,
    "bathrooms": 2,
    "sqft": 2000
  }
}

# GET /api/v1/properties/:id
# Get property details
# Returns: Property object with full details

# PATCH /api/v1/properties/:id
# Update property
{
  "property": {
    "price": 725000,
    "description": "Updated description"
  }
}

# DELETE /api/v1/properties/:id
# Delete property (realtor only)

# POST /api/v1/properties/upload/images
# Upload property images
# Multipart form data with images[]
```

### Booking Management
```ruby
# GET /api/v1/bookings
# List user's bookings
# Query params: status, page, per_page

# POST /api/v1/bookings
# Create new booking
{
  "booking": {
    "property_id": 123,
    "scheduled_at": "2024-07-15T14:00:00Z",
    "duration_minutes": 45,
    "notes": "Interested in the backyard"
  }
}

# GET /api/v1/bookings/:id
# Get booking details

# PATCH /api/v1/bookings/:id
# Update booking (reschedule)
{
  "booking": {
    "scheduled_at": "2024-07-16T15:00:00Z"
  }
}

# DELETE /api/v1/bookings/:id
# Cancel booking
```

### Video Call Management
```ruby
# POST /api/v1/calls
# Create new video call
{
  "call": {
    "tour_id": 456,
    "duration_minutes": 30
  }
}

# GET /api/v1/calls/:id
# Get call details
# Returns: Call object with Chime meeting info

# POST /api/v1/calls/:id/join
# Join video call
# Returns: Chime meeting credentials

# POST /api/v1/calls/:id/end
# End video call
```

### Dashboard Endpoints
```ruby
# GET /api/v1/dashboards/realtor
# Get realtor dashboard data
# Returns: {
#   "total_properties": 25,
#   "active_listings": 18,
#   "pending_sales": 3,
#   "properties_sold": 4,
#   "upcoming_tours": [...],
#   "recent_activity": [...]
# }

# GET /api/v1/dashboards/buyer
# Get buyer dashboard data
# Returns: {
#   "upcoming_tours": [...],
#   "tour_history": [...],
#   "favorite_properties": [...]
# }
```

### Analytics Endpoints
```ruby
# GET /api/v1/analytics/realtor
# Get realtor analytics
# Returns: {
#   "tours_per_month": [...],
#   "conversion_rate": 0.15,
#   "average_tour_duration": 28.5,
#   "top_properties": [...]
# }
```

### Upload Endpoints
```ruby
# POST /api/v1/upload/recordings
# Upload tour recording
# Multipart form data with recording file
```

## 🔄 Background Jobs

### Job Categories

#### High Priority Jobs (default queue)
```ruby
class BookingReminderJob < ApplicationJob
  queue_as :default
  
  def perform(booking_id)
    booking = Booking.find(booking_id)
    # Send email/SMS reminders 15 minutes before tour
    NotificationService.send_reminder(booking)
  end
end

class TourStartJob < ApplicationJob
  queue_as :default
  
  def perform(tour_id)
    tour = Tour.find(tour_id)
    TourLifecycleService.start(tour)
    # Notify participants, update status
  end
end

class TourEndJob < ApplicationJob
  queue_as :default
  
  def perform(tour_id)
    tour = Tour.find(tour_id)
    TourLifecycleService.end(tour)
    # Trigger recording processing, generate summary
  end
end
```

#### Media Processing Jobs
```ruby
class RecordingProcessingJob < ApplicationJob
  queue_as :default
  
  def perform(recording_id)
    recording = Recording.find(recording_id)
    VideoProcessingService.process(recording)
    # Fetch from Mux, compress, store in S3
  end
end

class TranscriptionJob < ApplicationJob
  queue_as :default
  
  def perform(recording_id)
    recording = Recording.find(recording_id)
    TranscriptionService.process(recording)
    # Use AWS Transcribe, save transcript
  end
end

class ImageProcessingJob < ApplicationJob
  queue_as :default
  
  def perform(image_id)
    image = ActiveStorage::Blob.find(image_id)
    ImageProcessingService.process(image)
    # Resize, compress, generate thumbnails
  end
end
```

#### AI/ML Jobs
```ruby
class HighlightJob < ApplicationJob
  queue_as :default
  
  def perform(tour_id)
    tour = Tour.find(tour_id)
    HighlightDetectionService.generate(tour)
    # Analyze video, extract key moments
  end
end

class TourSummaryJob < ApplicationJob
  queue_as :default
  
  def perform(tour_id)
    tour = Tour.find(tour_id)
    SummaryService.generate(tour)
    # Generate AI summary from transcript and notes
  end
end
```

#### Analytics Jobs
```ruby
class DashboardAggregatorJob < ApplicationJob
  queue_as :default
  
  def perform
    # Nightly aggregation of dashboard metrics
    User.find_each do |user|
      AnalyticsAggregator.aggregate_for_user(user)
    end
  end
end

class AnalyticsIngestionJob < ApplicationJob
  queue_as :analytics
  
  def perform(event_payload)
    # Stream events to data warehouse
    AnalyticsService.ingest_event(event_payload)
  end
end
```

#### Maintenance Jobs
```ruby
class RecordingCleanupJob < ApplicationJob
  queue_as :low_priority
  
  def perform
    # Archive old recordings based on retention policy
    Recording.where('recorded_at < ?', 90.days.ago).find_each do |recording|
      RecordingCleanupService.archive(recording)
    end
  end
end

class AuditLogProcessingJob < ApplicationJob
  queue_as :compliance
  
  def perform(batch)
    # Process audit logs for compliance reporting
    AuditLogProcessor.process(batch)
  end
end
```

## 🛠️ Service Layer

### Authentication Services
```ruby
class PasswordResetService
  def self.request_reset(user)
    token = SecureRandom.hex(32)
    expires_at = 1.hour.from_now
    
    PasswordResetToken.create!(
      user: user,
      token: token,
      expires_at: expires_at
    )
    
    # Send email with reset link
    PasswordResetMailer.reset_email(user, token).deliver_later
  end

  def self.confirm_reset(token, new_password)
    reset_token = PasswordResetToken.find_by(token: token)
    
    return false unless reset_token && reset_token.expires_at > Time.current
    
    reset_token.user.update!(password: new_password)
    reset_token.update!(used_at: Time.current)
    true
  end
end
```

### Tour Lifecycle Services
```ruby
class TourLifecycleService
  def self.start(tour)
    tour.update!(
      status: 'in_progress',
      started_at: Time.current
    )
    
    # Create Chime meeting
    call = Call.create!(
      tour: tour,
      chime_meeting_id: ChimeService.create_meeting(tour),
      status: 'created'
    )
    
    # Notify participants
    TourNotificationService.notify_start(tour)
  end

  def self.end(tour)
    tour.update!(
      status: 'completed',
      ended_at: Time.current
    )
    
    # End Chime meeting
    tour.call&.update!(status: 'ended', ended_at: Time.current)
    
    # Trigger post-tour processing
    RecordingProcessingJob.perform_later(tour.recording.id) if tour.recording
    TranscriptionJob.perform_later(tour.recording.id) if tour.recording
    HighlightJob.perform_later(tour.id)
    TourSummaryJob.perform_later(tour.id)
  end
end
```

### Media Processing Services
```ruby
class VideoProcessingService
  def self.process(recording)
    # Fetch from Mux
    mux_asset = MuxService.get_asset(recording.mux_asset_id)
    
    # Download and compress
    compressed_file = VideoCompressor.compress(mux_asset.playback_url)
    
    # Upload to S3
    s3_url = S3Service.upload_recording(compressed_file, recording.id)
    
    # Update recording
    recording.update!(
      playback_url: s3_url,
      duration_seconds: mux_asset.duration,
      file_size_bytes: compressed_file.size
    )
  end
end

class TranscriptionService
  def self.process(recording)
    # Use AWS Transcribe
    transcript_data = AwsTranscribeService.transcribe(recording.playback_url)
    
    # Create transcript record
    Transcript.create!(
      tour: recording.tour,
      full_text: transcript_data.full_text,
      segments: transcript_data.segments,
      confidence_score: transcript_data.confidence
    )
  end
end
```

### AI/ML Services
```ruby
class HighlightDetectionService
  def self.generate(tour)
    # Analyze video for key moments
    highlights = VideoAnalyzer.analyze(tour.recording.playback_url)
    
    highlights.each do |highlight|
      Highlight.create!(
        tour: tour,
        timestamp_ms: highlight.timestamp,
        note: highlight.description,
        image_url: highlight.screenshot_url,
        highlight_type: highlight.type
      )
    end
  end
end

class SummaryService
  def self.generate(tour)
    # Combine transcript and notes for AI summary
    content = [
      tour.transcript&.full_text,
      tour.tour_notes.pluck(:content)
    ].compact.join("\n")
    
    # Generate summary using OpenAI
    summary = OpenAIService.generate_summary(content)
    
    # Store summary (could be in a separate table or as a note)
    TourNote.create!(
      tour: tour,
      user: tour.realtor,
      content: summary,
      tag: 'ai_summary'
    )
  end
end
```

## 🔐 Security & Authentication

### JWT Implementation
```ruby
class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret_key

  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
  rescue JWT::DecodeError
    nil
  end
end

class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JwtService.decode(token)
    
    if payload && payload['user_id']
      @current_user = User.find(payload['user_id'])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
end
```

### Role-Based Access Control
```ruby
class PunditPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    @user.realtor? || @user.admin?
  end

  def update?
    @user.realtor? && @record.realtor_id == @user.id || @user.admin?
  end

  def destroy?
    @user.realtor? && @record.realtor_id == @user.id || @user.admin?
  end
end
```

### Rate Limiting
```ruby
class RateLimiter
  def self.check_limit(key, limit, window)
    current = Redis.current.get(key)
    
    if current && current.to_i >= limit
      false
    else
      Redis.current.multi do |multi|
        multi.incr(key)
        multi.expire(key, window)
      end
      true
    end
  end
end

class ApplicationController < ActionController::API
  before_action :check_rate_limit
  
  private
  
  def check_rate_limit
    key = "rate_limit:#{current_user.id}:#{action_name}"
    unless RateLimiter.check_limit(key, 100, 3600) # 100 requests per hour
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end
  end
end
```

## 📊 Monitoring & Observability

### Key Metrics
```ruby
class MetricsCollector
  def self.record_api_call(endpoint, duration, status)
    StatsD.timing("api.#{endpoint}.duration", duration)
    StatsD.increment("api.#{endpoint}.count")
    StatsD.increment("api.#{endpoint}.#{status}")
  end

  def self.record_video_call_setup(duration)
    StatsD.timing("video_call.setup_time", duration)
  end

  def self.record_tour_completion(tour_id)
    StatsD.increment("tours.completed")
    StatsD.gauge("tours.active", Tour.where(status: 'in_progress').count)
  end
end
```

### Error Handling
```ruby
class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

  private

  def handle_standard_error(exception)
    Rails.logger.error("Unhandled error: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))
    
    Sentry.capture_exception(exception)
    
    render json: { 
      error: 'Internal server error',
      message: 'Something went wrong'
    }, status: :internal_server_error
  end

  def handle_not_found(exception)
    render json: { 
      error: 'Not found',
      message: 'The requested resource was not found'
    }, status: :not_found
  end

  def handle_validation_error(exception)
    render json: { 
      error: 'Validation failed',
      message: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end
end
```

## 🚀 Deployment & Infrastructure

### Docker Configuration
```dockerfile
# Dockerfile
FROM ruby:3.2-alpine

# Install dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    nodejs \
    yarn

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

# Start application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### Environment Configuration
```ruby
# config/application.rb
module RealtyForYou
  class Application < Rails::Application
    # API mode
    config.api_only = true
    
    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV['ALLOWED_ORIGINS']&.split(',') || ['http://localhost:3000']
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end
    
    # Background job configuration
    config.active_job.queue_adapter = :sidekiq
    
    # Cache configuration
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_URL'],
      connect_timeout: 30,
      read_timeout: 0.2,
      write_timeout: 0.2
    }
  end
end
```

### Database Configuration
```ruby
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV['DATABASE_URL'] %>

development:
  <<: *default
  database: realty_for_you_development

test:
  <<: *default
  database: realty_for_you_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 25 } %>
  sslmode: require
```

## 🧪 Testing Strategy

### Unit Tests
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:full_name) }
  end

  describe 'associations' do
    it { should have_many(:properties) }
    it { should have_many(:bookings) }
  end

  describe '#realtor?' do
    it 'returns true for realtor role' do
      user = build(:user, role: 'realtor')
      expect(user.realtor?).to be true
    end
  end
end
```

### Controller Tests
```ruby
# spec/controllers/api/v1/properties_controller_spec.rb
RSpec.describe Api::V1::PropertiesController, type: :controller do
  let(:realtor) { create(:user, role: 'realtor') }
  let(:property) { create(:property, realtor: realtor) }

  before { authenticate_user(realtor) }

  describe 'GET #index' do
    it 'returns properties for realtor' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(json_response['properties']).to be_present
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        property: {
          address: '123 Main St',
          price: 500000,
          bedrooms: 3,
          bathrooms: 2
        }
      }
    end

    it 'creates a new property' do
      expect {
        post :create, params: valid_params
      }.to change(Property, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end
end
```

### Service Tests
```ruby
# spec/services/tour_lifecycle_service_spec.rb
RSpec.describe TourLifecycleService do
  let(:tour) { create(:tour) }

  describe '.start' do
    it 'updates tour status and creates call' do
      expect(ChimeService).to receive(:create_meeting).with(tour)
      
      described_class.start(tour)
      
      expect(tour.reload.status).to eq('in_progress')
      expect(tour.call).to be_present
    end
  end

  describe '.end' do
    it 'updates tour status and triggers processing jobs' do
      expect(RecordingProcessingJob).to receive(:perform_later)
      
      described_class.end(tour)
      
      expect(tour.reload.status).to eq('completed')
    end
  end
end
```

### Integration Tests
```ruby
# spec/requests/api/v1/tours_spec.rb
RSpec.describe 'Tours API', type: :request do
  let(:realtor) { create(:user, role: 'realtor') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:property) { create(:property, realtor: realtor) }
  let(:tour) { create(:tour, property: property, realtor: realtor, buyer: buyer) }

  describe 'POST /api/v1/calls' do
    it 'creates a new video call' do
      post '/api/v1/calls', params: { call: { tour_id: tour.id } },
           headers: auth_headers(realtor)
      
      expect(response).to have_http_status(:created)
      expect(json_response['call']['chime_meeting_id']).to be_present
    end
  end
end
```

## 📈 Performance Optimization

### Database Optimization
```ruby
# Add indexes for common queries
class AddIndexesToTables < ActiveRecord::Migration[7.0]
  def change
    add_index :properties, [:realtor_id, :status]
    add_index :bookings, [:buyer_id, :scheduled_at]
    add_index :tours, [:property_id, :scheduled_at]
    add_index :tour_notes, [:tour_id, :timestamp_ms]
    add_index :audit_logs, [:actor_id, :created_at]
  end
end

# Use counter caches
class Property < ApplicationRecord
  belongs_to :realtor, counter_cache: true
  has_many :bookings, counter_cache: true
end
```

### Caching Strategy
```ruby
# Fragment caching for property listings
class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:realtor)
                         .where(status: 'active')
                         .order(created_at: :desc)
                         .page(params[:page])
    
    render json: @properties, cached: true
  end
end

# Redis caching for dashboard data
class DashboardService
  def self.realtor_dashboard(user_id)
    Rails.cache.fetch("dashboard:realtor:#{user_id}", expires_in: 15.minutes) do
      # Calculate dashboard metrics
      {
        total_properties: Property.where(realtor_id: user_id).count,
        active_listings: Property.where(realtor_id: user_id, status: 'active').count,
        # ... more metrics
      }
    end
  end
end
```

### Background Job Optimization
```ruby
# Use different queues for different job types
class RecordingProcessingJob < ApplicationJob
  queue_as :media_processing
  
  def perform(recording_id)
    # Process recording with higher priority
  end
end

class AnalyticsIngestionJob < ApplicationJob
  queue_as :analytics
  
  def perform(event_payload)
    # Lower priority analytics processing
  end
end

# Configure Sidekiq
# config/sidekiq.yml
:concurrency: 25
:queues:
  - [critical, 3]
  - [default, 2]
  - [media_processing, 2]
  - [analytics, 1]
  - [low_priority, 1]
```

This backend architecture provides a robust, scalable foundation for the real estate video tour platform with comprehensive API endpoints, background job processing, security measures, and monitoring capabilities. 