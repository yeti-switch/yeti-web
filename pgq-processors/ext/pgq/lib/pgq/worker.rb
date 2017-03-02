class Pgq::Worker
  attr_reader :logger, :consumers, :sleep_time

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
    @consumers = []

    env.config["consumers"].each do |consumer|
      require "#{ENV['ROOT_PATH']}/consumers/#{consumer}.rb"
      @consumers << consumer.camelize.constantize.new(@logger, env.config['queue'])
    end

    @sleep_time = 0.5
  end

  def process_batch
    process_count = 0
    @consumers.each do |consumer|
      process_count += consumer.perform_batch
    end
    process_count
  end

  def run
    logger.info "Worker for (#{@consumers.join(',')}) started"

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