# == app/models/user.rb ==
class User < ApplicationRecord
  has_many :properties, foreign_key: :realtor_id
  has_many :bookings, foreign_key: :buyer_id
  has_many :tour_notes
  has_many :audit_logs, foreign_key: :actor_id

  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
end

# == app/models/password_reset_token.rb ==
class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
end

# == app/models/property.rb ==
class Property < ApplicationRecord
  belongs_to :realtor, class_name: 'User'
  has_many :bookings
  has_many :tours

  validates :address, :mls_id, presence: true
end

# == app/models/booking.rb ==
class Booking < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :property
  has_one :tour

  validates :scheduled_at, presence: true
end

# == app/models/tour.rb ==
class Tour < ApplicationRecord
  belongs_to :property
  belongs_to :realtor, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  has_many :tour_notes
  has_one :transcript
  has_many :highlights
  has_one :recording
  has_one :call

  validates :scheduled_at, presence: true
end

# == app/models/call.rb ==
class Call < ApplicationRecord
  belongs_to :tour

  validates :chime_meeting_id, presence: true
end

# == app/models/tour_note.rb ==
class TourNote < ApplicationRecord
  belongs_to :tour
  belongs_to :user

  validates :content, presence: true
end

# == app/models/transcript.rb ==
class Transcript < ApplicationRecord
  belongs_to :tour
end

# == app/models/highlight.rb ==
class Highlight < ApplicationRecord
  belongs_to :tour
end

# == app/models/recording.rb ==
class Recording < ApplicationRecord
  belongs_to :tour
end

# == app/models/analytics_aggregate.rb ==
class AnalyticsAggregate < ApplicationRecord
  belongs_to :realtor, class_name: 'User'
end

# == app/models/audit_log.rb ==
class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: 'User'
end
