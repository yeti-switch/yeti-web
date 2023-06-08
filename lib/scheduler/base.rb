# frozen_string_literal: true

require 'rufus-scheduler'
require 'securerandom'

class Scheduler::Base
  RunOptions = Struct.new(
    :name,
    :handler_class,
    :job,
    :time,
    :started_at,
    :ended_at,
    :duration,
    :success,
    :exception
  )

  class_attribute :logger, instance_writer: false
  class_attribute :scheduler, instance_accessor: false
  class_attribute :_cron_handlers, instance_writer: false, default: []
  class_attribute :_every_handlers, instance_writer: false, default: []
  class_attribute :_middlewares, instance_writer: false, default: []
  class_attribute :_before_run_callbacks, instance_writer: false, default: []
  class_attribute :_on_error_callback, instance_writer: false

  class << self
    def inherited(subclass)
      subclass.scheduler = nil
      subclass._cron_handlers = []
      subclass._every_handlers = []
      subclass._middlewares = []
      subclass._before_run_callbacks = []
      subclass._on_error_callback = nil
      super
    end

    # Starts scheduler thread.
    # @param options [Hash]
    #   :wait [Boolean] default true.
    def start!(options = {})
      raise ArgumentError, 'scheduler already started' if started?

      self.scheduler = new(options)
      scheduler.run!
    end

    # @return [Boolean]
    def started?
      !scheduler.nil? && scheduler.running?
    end

    # @param wait_jobs [Boolean] whether wait current job to be finished or not (default true).
    def shutdown(wait_jobs: true)
      return if scheduler.nil?

      scheduler.shutdown(wait_jobs: wait_jobs)
    end

    # handler_class [Class<Scheduler::Job::Base>]
    def cron(handler_class)
      _cron_handlers.push(handler_class)
    end

    def every(handler_class)
      _every_handlers.push(handler_class)
    end

    # @param middleware_class [Class<Scheduler::Middleware::Base>]
    # @param prepend [Boolean] default false.
    # @param options [Hash] default empty hash.
    def use(middleware_class, prepend: false, **options)
      callable = proc { |app| middleware_class.new(app, options) }
      if prepend
        _middlewares.unshift(callable)
      else
        _middlewares.push(callable)
      end
    end

    # @param callable [#call] block can be used instead.
    # @yield if callable omitted.
    def before_run(callable = nil, &block)
      raise ArgumentError, 'callable or block must be passed' if callable.nil? && block.nil?

      _before_run_callbacks.push(callable || block)
    end

    # @param callable [#call] block can be used instead.
    # @yield if callable omitted.
    def on_error(callable = nil, &block)
      raise ArgumentError, 'callable or block must be passed' if callable.nil? && block.nil?
      raise ArgumentError, 'error callback already registered' unless _on_error_callback.nil?

      self._on_error_callback = callable || block
    end
  end

  attr_reader :rufus_scheduler, :opts

  # @param opts [Hash]
  #   :wait [Boolean] whether block execution until scheduler shutdown (default true).
  #   :request_id [Boolean] whether add unique uuid to log tags on each run (default false).
  def initialize(opts = {})
    @opts = opts
    @rufus_scheduler = nil
  end

  # Starts scheduler thread.
  def run!
    raise ArgumentError, 'scheduler already running' if running?

    @rufus_scheduler = Rufus::Scheduler.new
    puts 'Scheduler started.' # rubocop:disable Rails/Output

    Kernel.trap('TERM') do
      puts "TERM received.\nShutting down..." # rubocop:disable Rails/Output
      shutdown
    end
    Kernel.trap('INT') do
      puts "\nINT received.\nShutting down..." # rubocop:disable Rails/Output
      shutdown
    end

    _cron_handlers.each do |handler_class|
      rufus_scheduler.cron(handler_class.cron_line, handler_class.scheduler_options) do |job, time|
        run_handler(handler_class, job, time)
      end
    end
    _every_handlers.each do |handler_class|
      rufus_scheduler.every(handler_class.every_interval, handler_class.scheduler_options) do |job, time|
        run_handler(handler_class, job, time)
      end
    end

    _before_run_callbacks.each(&:call)
    rufus_scheduler.join if opts.fetch(:wait, true)
  end

  # @param wait_jobs [Boolean] whether wait current job to be finished or not (default true).
  def shutdown(wait_jobs: true)
    return unless running?

    rufus_scheduler.shutdown(kill: !wait_jobs)
    @rufus_scheduler = nil
  end

  # @return [Boolean]
  def running?
    !rufus_scheduler.nil?
  end

  # @param handler_class [Class<Scheduler::Job::Base>]
  # @param job [Rufus::Scheduler::CronJob]
  # @param time [EtOrbi::EoTime]
  def run_handler(handler_class, job, time)
    start_clock = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)

    options = RunOptions.new(job.name, handler_class, job, time, now_time)
    log_tags = [self.class.name, Process.pid]
    log_tags += [SecureRandom.uuid] if opts[:request_id]
    with_log_tags(*log_tags) do
      log_run_start(options)
      handler_callable = build_handler_callable(handler_class, start_clock)
      handler = wrap_with_middlewares(handler_callable)
      handler.call(options)
      log_run_end(options)
      _on_error_callback&.call(options.exception, options) if options.exception
    end
  end

  private

  # @param handler_class [Class<Scheduler::Job::Base>]
  # @param start_clock [Numeric]
  # @return [#call]
  def build_handler_callable(handler_class, start_clock)
    proc do |options|
      begin
        handler_class.call(options)
        options.success = true
      rescue StandardError => e
        options.success = false
        options.exception = e
      end
      options.ended_at = now_time
      options.duration = (::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - start_clock).round(6)
    end
  end

  # @param handler_callable [#call]
  def wrap_with_middlewares(handler_callable)
    _middlewares.reverse.inject(handler_callable) { |acc, elem| elem.call(acc) }
  end

  # @param options [Scheduler::Base::RunOptions]
  def log_run_start(options)
    return if logger.nil?

    logger.info do
      started_at = log_time_formatted(options.started_at)
      "Job #{options.handler_class} started at #{started_at}."
    end
  end

  # @param options [Scheduler::Base::RunOptions]
  def log_run_end(options)
    return if logger.nil?

    if options.success
      logger.info do
        ended_at = log_time_formatted(options.ended_at)
        "Job #{options.handler_class} succeed at #{ended_at} (#{options.duration} sec)."
      end
    else
      logger.info do
        ended_at = log_time_formatted(options.ended_at)
        error = log_error_formatted(options.exception)
        "Job #{options.handler_class} failed at #{ended_at} (#{options.duration} sec)\n#{error}."
      end
    end
  end

  # @param time [Time]
  def log_time_formatted(time)
    time.to_fs(:db)
  end

  # @param exception [Exception]
  # @param causes [Array<Exception>]
  def log_error_formatted(exception, causes: [])
    return if exception.nil?

    text = "#{exception.class} #{exception.message}\n#{exception.backtrace&.join("\n")}"
    if exception.cause && exception.cause != exception && causes.exclude?(exception.cause)
      new_causes = causes + [exception]
      text += "\n\nCaused by:\n" + log_error_formatted(exception.cause, causes: new_causes)
    end
    text
  end

  # @param tags [Array<String>]
  # yield within tagged logger if logger assigned.
  def with_log_tags(*tags)
    return yield if logger.nil?

    logger.tagged(*tags) { yield }
  end

  # @return [Time] current time.
  def now_time
    Time.zone.now
  end
end
