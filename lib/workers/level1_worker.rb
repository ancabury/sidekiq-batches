class Level1Worker
  include Sidekiq::Worker
  sidekiq_options queue: 'workers'

  def perform(size)
    GenericLogger.log '==== Performing logic on LEVEL 1 ==== '
    batch.jobs do
      level1_batch = Sidekiq::Batch.new
      level1_batch.description = 'LEVEL 1 batch'
      level1_batch.on(:complete, 'WorkflowCallbacks#level1_finished', size: size, current: size/2)

      level1_batch.jobs do
        (1..(size/2)).each do |current|
          GenericWorker.perform_async(current, 1)
        end
      end
    end
  end
end
