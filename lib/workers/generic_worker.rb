class GenericWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'workers'

  def perform(number, level)
    GenericLogger.log "==== Performing jobs on LEVEL #{level}, job: #{number} ==== "
  end
end
