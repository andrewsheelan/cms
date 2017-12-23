ActiveAdmin.register Scheduler do
  require 'sidekiq'
  require 'sidekiq/scheduler'

  menu priority: 3

  action_item only: %i[index show] do
    link_to 'Clear Cache', clear_cache_admin_schedulers_path
  end

  action_item only: %i[index show] do
    link_to 'Re-Schedule', reschedule_admin_schedulers_path
  end

  # Allows admins to clear rails cache
  collection_action :clear_cache, method: :get do
    Rails.cache.clear
    redirect_to admin_schedulers_path, notice: 'Cache cleared!'
  end

  # Allows admins to Reschedule tasks
  collection_action :reschedule, method: :get do
    Sidekiq.schedule = Scheduler.all.map do |scheduler|
      {
        scheduler.id => {
          cron: scheduler.process_time,
          class: RunQuery,
          args: scheduler.process_statement,
          description: "Run Query #{scheduler.process_statement} at #{scheduler.process_time}"
        }
      }
    end.to_yaml
    Sidekiq::Scheduler.reload_schedule!
    redirect_to admin_schedulers_path, notice: 'Rescheduled!'
  end
end


# clear_leaderboards_contributors:
#   cron: '0 30 6 * * 1'
#   class: ClearLeaderboards
#   queue: low
#   args: contributors
#   description: 'This job resets the weekly leaderboard for contributions'
