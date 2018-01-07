module Schedulex
  class ScheduleTrackAppboy
    include Sidekiq::Worker
    sidekiq_options queue: 'scheduler'
  end
end
