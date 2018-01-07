class RunQuery
  include Sidekiq::Worker

  def perform(query)
    connection = ActiveRecord::Base.connection
    connection.execute(query)
  end
end
