module SidekiqHelpers
  require 'sidekiq/api'

  def clear_all_jobs
    Sidekiq::Queue.new.clear
  end
end
