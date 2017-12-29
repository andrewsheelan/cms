class AppboyPostEvent < ApplicationRecord
  scope :pending, -> { where('date_processed IS NULL and user_id IS NOT NULL') }
  scope :invalid, -> { where('user_id IS NULL') }
  scope :processed, -> { where('date_processed IS NOT NULL') }

  def self.validate_emails
    sql =  %[
      UPDATE appboy_post_events SET user_id = users.id FROM users
      WHERE appboy_post_events.email = users.email AND
      appboy_post_events.user_id IS NULL
    ]
    ActiveRecord::Base.connection.update(sql)
  end
  
  def self.push_to_dynamo
  end
end
