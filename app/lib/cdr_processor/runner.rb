# frozen_string_literal: true

module CdrProcessor
  class Runner
    def initialize(processor_name:, config_file: nil)
      @processor_name = processor_name
      @config_file = config_file || default_config_file
    end

    def start
      Process.setproctitle("cdr_processor:#{@processor_name}")

      config = load_config
      logger = build_logger
      setup_signals

      processor_class = resolve_processor_class(config)
      processor = processor_class.new(logger, config['queue'], config['consumer'], config)
      worker = CdrProcessor::Worker.new(logger: logger, processor: processor)

      pid_file = ENV['pid_file']
      if pid_file.present?
        raise 'pid file exists!' if File.exist?(pid_file)

        File.open(pid_file, 'w') { |f| f.puts Process.pid }
      end

      begin
        worker.run
      ensure
        File.delete(pid_file) if pid_file.present? && File.exist?(pid_file)
      end
    end

    private

    def default_config_file
      Rails.root.join('config/cdr_processors.yml').to_s
    end

    def load_config
      raise "Configuration file #{@config_file} does not exist." unless File.exist?(@config_file)

      all_config = YAML.safe_load(File.read(@config_file), permitted_classes: [Symbol])
      config = all_config[@processor_name]

      if config.blank?
        raise "Invalid configuration file #{@config_file} or section #{@processor_name} does not exist."
      end

      config
    end

    def resolve_processor_class(config)
      class_name = config['class']
      raise "Missing 'class' in config section '#{@processor_name}'" if class_name.blank?

      "CdrProcessor::Processors::#{class_name.camelize}".constantize
    end

    def build_logger
      $stdout.sync = true
      logger = Logger.new($stdout)
      logger.level = Logger::INFO
      logger
    end

    def setup_signals
      trap('HUP') { CdrProcessor::Worker.shutdown!('HUP') }
      trap('TERM') { CdrProcessor::Worker.shutdown!('TERM') }
      trap('INT') { CdrProcessor::Worker.shutdown!('INT') }
    end
  end
end
