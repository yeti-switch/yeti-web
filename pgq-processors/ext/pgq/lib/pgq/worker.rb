class Pgq::Worker
  attr_reader :logger, :class, :sleep_time

  cattr_accessor :interrupted do false end
  cattr_accessor :logger

  def self.shutdown!(signal)
     self.interrupted = signal
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
    if self.interrupted?
        logger.info  "[#{file}: #{line}] Worker has been halted with #{self.interrupted}"
        exit(0)
    end
  end

end