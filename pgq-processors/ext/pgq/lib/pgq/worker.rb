class Pgq::Worker
  attr_reader :logger, :class, :sleep_time

  cattr_accessor :interrupted do false end
  cattr_accessor :graceful_exit do true end
  cattr_accessor :logger

  def self.shutdown!(signal)
    if signal.is_a?(StandardError)
      self.interrupted = "<#{signal.class}> #{signal.message}"
      self.graceful_exit = false
    else
      self.interrupted = signal
      self.graceful_exit = true
    end
  end

  def self.interrupted?
    !!self.interrupted
  end

  def interrupted?
    self.class.interrupted?
  end

  def initialize(env)
    @logger = env.logger
    @class_name = env.config["class"]

    require "#{ENV['ROOT_PATH']}/processors/#{@class_name}.rb"
    @class = @class_name.camelize.constantize.new(
        @logger,
        env.config['queue'],
        env.config['consumer'],
        env.config.config
    )
    @sleep_time = 0.5
  end

  def process_batch
    @class.perform_batch
  end

  def run
    logger.info "Worker for #{@class_name} started"

    loop do
      Pgq::Worker.check_interrupted(__FILE__, __LINE__)
      processed_count = process_batch
      sleep(@sleep_time) if processed_count == 0
    end
  end


  def self.check_interrupted(file, line)
    if interrupted?
      exit_code = graceful_exit ? 0 : 1
      logger.info { "[#{file}: #{line}] {exit_code:#{exit_code}} Worker has been halted with #{interrupted}" }
      exit(exit_code)
    end
  end

end
