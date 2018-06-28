class WorkflowWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'workers'

  def initialize(size)
    @size = size
  end

  def perform
    batch = Sidekiq::Batch.new
    batch.description = 'base batch'
    batch.on(:complete, 'WorkflowCallbacks#finished')

    batch.jobs do
      GenericLogger.log '==== Performing logic on LEVEL 0 ===='
      GenericLogger.log '==== Performing jobs on LEVEL 0, job: 0 ===='

      Level1Worker.perform_async(@size - 1)
    end
  end
end
