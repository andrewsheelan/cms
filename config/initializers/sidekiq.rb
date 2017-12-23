redis_options = {
  url: ENV['REDIS_SERVER_URL'],
  namespace: "cms:production"
}
Sidekiq.configure_server do |config|
  config.redis = redis_options
end

Sidekiq.configure_client do |config|
  config.redis = redis_options
end
