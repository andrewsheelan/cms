module Schedulex
  class ScheduleGoogleAnalytics
    include Sidekiq::Worker
    sidekiq_options queue: 'analytics'
  end
end
