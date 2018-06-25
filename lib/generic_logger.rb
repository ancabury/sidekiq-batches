require 'logger'

class GenericLogger
  def self.log(message)
    new.log(message)
  end

  def initialize
    @logger ||= Logger.new('logs/development.log')
  end

  def log(message)
    @logger.info message
  end
end
