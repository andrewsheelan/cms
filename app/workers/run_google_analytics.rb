class RunGoogleAnalytics
  include Sidekiq::Worker

  def perform(query)
    Schedulex::ScheduleGoogleAnalytics.perform_async(query)
  end
end
