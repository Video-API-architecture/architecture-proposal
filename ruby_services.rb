# === Service Layer Declarations ===

# == app/services/password_reset_service.rb ==
class PasswordResetService
  def self.request_reset(user)
    # generate token, save, and trigger email
  end

  def self.confirm_reset(token, new_password)
    # validate token, update password
  end
end

# == app/services/tour_lifecycle_service.rb ==
class TourLifecycleService
  def self.start(tour)
    # update status, notify participants
  end

  def self.end(tour)
    # update status, record end time, notify
  end
end

# == app/services/video_processing_service.rb ==
class VideoProcessingService
  def self.process(recording)
    # fetch mux asset, compress, store
  end
end

# == app/services/transcription_service.rb ==
class TranscriptionService
  def self.process(recording)
    # use AWS Transcribe, save transcript
  end
end

# == app/services/highlight_detection_service.rb ==
class HighlightDetectionService
  def self.generate(tour)
    # analyze video, extract moments, save highlights
  end
end

# == app/services/summary_service.rb ==
class SummaryService
  def self.generate(tour)
    # use AI to generate tour summary
  end
end

# == app/services/image_processing_service.rb ==
class ImageProcessingService
  def self.process(image)
    # resize, compress, and return
  end
end

# == app/services/external_sync_service.rb ==
class ExternalSyncService
  def self.sync_property(property)
    # send to third-party CRM
  end
end

# == app/services/audit_log_processor.rb ==
class AuditLogProcessor
  def self.process(batch)
    # push batch to cold storage or external system
  end
end
