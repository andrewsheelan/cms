ActiveAdmin.register AppboyPostEvent do
  menu priority: 2
  scope :all
  scope :pending, default: true
  scope :invalid
  scope :processed
  action_item only: :index do
    link_to 'Send Pending to Appboy', send_appboy_admin_appboy_post_events_path if AppboyPostEvent.pending.any?
  end
  action_item only: :index do
    link_to 'Validate Emails', validate_admin_appboy_post_events_path if AppboyPostEvent.invalid.any?
  end

  collection_action :send_appboy, method: 'get' do
    # AppboyPostEvent.push_to_dynamo
    redirect_to collection_path, notice: "Processing: Events to Lambda! Checkback on updates"
  end

  collection_action :validate, method: 'get' do
    before = AppboyPostEvent.invalid.count
    AppboyPostEvent.validate_emails
    after = AppboyPostEvent.invalid.count
    processed = before - after
    redirect_to collection_path, notice: "#{processed} updated - Validated! "
  end
end
