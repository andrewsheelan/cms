module Schedulex
  class TrackPostAppboy
    include Sidekiq::Worker
    sidekiq_options queue: 'exq'
  end
end
