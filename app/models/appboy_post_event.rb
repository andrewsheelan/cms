class AppboyPostEvent < ApplicationRecord
  acts_as_copy_target
  scope :pending, -> { where(date_sent: nil, user_id: nil, email_valid: nil) }
  scope :invalid, -> { where(user_id: nil, email_valid: false) }
  scope :processed, -> { where('date_sent IS NOT NULL') }

  def self.validate_emails
    sql = %(
      UPDATE appboy_post_events SET user_id = users.id FROM users
      WHERE appboy_post_events.email = users.email AND
      appboy_post_events.user_id IS NULL
    )
    ActiveRecord::Base.connection.update(sql)
  end

  def self.push_to_dynamo
  end
end
