# frozen_string_literal: true

module CdrProcessor
  class Worker
    attr_reader :logger, :sleep_time

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
      !!interrupted
    end

    def interrupted?
      self.class.interrupted?
    end

    def initialize(logger:, processor:)
      @logger = logger
      @processor = processor
      @sleep_time = ENV.fetch('PGQ_SLEEP_INTERVAL', 0.5).to_f
      self.class.logger = logger
    end

    def process_batch
      @processor.perform_batch
    end

    def run
      logger.info "Worker for #{@processor.class.name} started"

      loop do
        CdrProcessor::Worker.check_interrupted(__FILE__, __LINE__)
        processed_count = process_batch
        sleep(@sleep_time) if processed_count == 0
      end
    end

    def self.check_interrupted(file, line)
      if interrupted?
        exit_code = graceful_exit ? 0 : 1
        logger.info { "[#{file}: #{line}] {exit_code:#{exit_code}} Worker has been halted with #{interrupted}" }
        exit(exit_code) # rubocop:disable Rails/Exit
      end
    end
  end
end
