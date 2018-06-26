class WorkflowCallbacks
  def level1_finished(status, opts)
    GenericLogger.log '==== Logic on LEVEL 1 finished ===='
    GenericLogger.log '==== Performing logic on LEVEL 2 ===='
    size = opts['size']
    current = opts['current'] + 1

    level2_batch = Sidekiq::Batch.new
    level2_batch.description = 'LEVEL 2 batch'
    level2_batch.on(:complete, 'WorkflowCallbacks#level2_finished', size: size, current: current)

    level2_batch.jobs do
      GenericWorker.perform_async(current, 2)
    end
  end

  def level2_finished(status, opts)
    GenericLogger.log '==== Logic on LEVEL 2 finished ===='
    GenericLogger.log '==== Performing logic on LEVEL 3 ===='
    size = opts['size']
    current = opts['current'] + 1

    level3_batch = Sidekiq::Batch.new
    level3_batch.description = 'LEVEL 3 batch'
    level3_batch.on(:complete, 'WorkflowCallbacks#level3_finished', size: size, current: 3*size/4)

    level3_batch.jobs do
      (current..(3*size/4)).each do |crt|
        GenericWorker.perform_async(crt, 3)
      end
    end
  end

  def level3_finished(status, opts)
    GenericLogger.log '==== Logic on LEVEL 3 finished ===='
    GenericLogger.log '==== Performing logic on LEVEL 4 ===='
    size = opts['size']
    current = opts['current'] + 1

    (current..size).each  do |crt|
      GenericWorker.perform_async(crt, 4)
    end
  end

  def finished(_status, _opts)
    GenericLogger.log '==== Logic on LEVEL 4 finished ===='
    GenericLogger.log '==== Execution finished ===='
  end
end
