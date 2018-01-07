class RunAppboy
  include Sidekiq::Worker

  def perform(query)
    Schedulex::ScheduleTrackAppboy.perform_async(query)
  end
end
