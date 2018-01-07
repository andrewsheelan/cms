Rails.application.routes.draw do
  # === Sidekiq Monitoring

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  authenticate :admin_user do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_scope :admin_user do
    authenticated :admin_user do
      root to: redirect('/admin'), as: :authenticated_root
    end
  end
  ActiveAdmin.routes(self)
  root to: "admin/dashboard#index"
end
