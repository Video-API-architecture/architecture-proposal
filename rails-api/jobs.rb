# === Background Job Declarations ===

class BookingReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find(booking_id)
    # Notify buyer & realtor X minutes before
  end
end

class TourStartJob < ApplicationJob
  queue_as :default

  def perform(tour_id)
    tour = Tour.find(tour_id)
    TourLifecycleService.start(tour)
  end
end

class TourEndJob < ApplicationJob
  queue_as :default

  def perform(tour_id)
    tour = Tour.find(tour_id)
    TourLifecycleService.end(tour)
  end
end

class RecordingProcessingJob < ApplicationJob
  queue_as :default

  def perform(recording_id)
    recording = Recording.find(recording_id)
    VideoProcessingService.process(recording)
  end
end

class TranscriptionJob < ApplicationJob
  queue_as :default

  def perform(recording_id)
    recording = Recording.find(recording_id)
    TranscriptionService.process(recording)
  end
end

class HighlightJob < ApplicationJob
  queue_as :default

  def perform(tour_id)
    tour = Tour.find(tour_id)
    HighlightDetectionService.generate(tour)
  end
end

class TourSummaryJob < ApplicationJob
  queue_as :default

  def perform(tour_id)
    tour = Tour.find(tour_id)
    SummaryService.generate(tour)
  end
end

class RecordingCleanupJob < ApplicationJob
  queue_as :low_priority

  def perform
    Recording.where('recorded_at < ?', 90.days.ago).destroy_all
  end
end

class DashboardAggregatorJob < ApplicationJob
  queue_as :default

  def perform
    # Recalculate realtor dashboard metrics
  end
end

class AnalyticsIngestionJob < ApplicationJob
  queue_as :analytics

  def perform(event_payload)
    # Stream to Snowflake/Kinesis
  end
end

class ImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = ActiveStorage::Blob.find(image_id)
    ImageProcessingService.process(image)
  end
end

class ExternalDataSyncJob < ApplicationJob
  queue_as :default

  def perform(property_id)
    property = Property.find(property_id)
    ExternalSyncService.sync_property(property)
  end
end

class AuditLogProcessingJob < ApplicationJob
  queue_as :compliance

  def perform(batch)
    AuditLogProcessor.process(batch)
  end
end
