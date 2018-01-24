ActiveAdmin.register Scheduler do
  require 'sidekiq'

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
    Sidekiq::Cron::Job.destroy_all!
    Scheduler.where(active: true).map do |scheduler|
      schedule_job(scheduler)
    end
    redirect_to admin_schedulers_path, notice: 'Rescheduled!'
  end

  action_item :run_now, only: :show, :edit do
     link_to 'Run now', run_now_admin_scheduler_path(membership)
  end
  # Allows admins to run tasks
  member_action :run_now, method: :get do
    run_now(Scheduler.find(params[:id]))
    redirect_to admin_schedulers_path, notice: 'Executing!'
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :worker, collection: ['Query', 'Appboy', 'Google Analytics']
      f.input :process_statement
      f.input :process_time
      f.input :active
    end
    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  index do
    selectable_column
    id_column

    column :worker
    column :process_statement
    column :process_time
    column :active
    column :created_at
    column :updated_at

    actions
  end

  controller do
    # This code is evaluated within the controller class

    def schedule_job(scheduler)
      if scheduler.worker == 'Query'
        Sidekiq::Cron::Job.create(
          name: "Schedule: #{scheduler.id}",
          cron: scheduler.process_time,
          class: 'RunQuery',
          args: [scheduler.process_statement]
        )
      elsif scheduler.worker == 'Appboy'
        Sidekiq::Cron::Job.create(
          name: "Schedule: #{scheduler.id}",
          cron: scheduler.process_time,
          class: 'RunAppboy',
          args: [JSON.parse(scheduler.process_statement)]
        )
      elsif scheduler.worker == 'Google Analytics'
        Sidekiq::Cron::Job.create(
          name: "Schedule: #{scheduler.id}",
          cron: scheduler.process_time,
          class: 'RunGoogleAnalytics',
          args: [JSON.parse(scheduler.process_statement)]
        )
      end
    end

    def run_now(scheduler)
      if scheduler.worker == 'Query'
        RunQuery.new.perform([scheduler.process_statement])
      elsif scheduler.worker == 'Appboy'
        RunAppboy.new.perform([JSON.parse(scheduler.process_statement)])
      elsif scheduler.worker == 'Google Analytics'
        RunGoogleAnalytics.new.perform([JSON.parse(scheduler.process_statement)])
      end
    end

  end
end
