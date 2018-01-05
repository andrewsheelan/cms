require 'sidekiq-limit_fetch'

redis_options = {
  url: ENV['REDIS_SERVER_URL'],
  namespace: "cms:exq:production"
}
Sidekiq.configure_server do |config|
  config.redis = redis_options
end

Sidekiq.configure_client do |config|
  config.redis = redis_options
end

Searchkick.redis = ConnectionPool.new { Redis.new(redis_options) }
