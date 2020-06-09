# frozen_string_literal: true

class YetiProcessor
  class_attribute :logger, instance_writer: false, default: Rails.logger
  class_attribute :type, instance_writer: false, default: 'yeti'

  def self.on_error(e)
    CaptureError.capture(e, tags: { component: 'Prometheus', processor_class: name })
  rescue StandardError => e
    warn "#{name} Failed To Capture Exception due to #{e.class} #{e.message}"
    logger&.error { "#{e.class} #{e.message} #{e.backtrace.join("\n")}" }
  end

  def self.start(client: nil, frequency: 30, labels: nil)
    stop

    client ||= PrometheusExporter::Client.default
    metric_labels = labels&.dup || {}
    process_collector = new(metric_labels)

    @thread = Thread.new do
      logger.tagged(name) do
        ActiveRecord::Base.connection_pool.release_connection
        logger&.info { "#{name} thread started." }

        loop do
          begin
            logger&.info { "Collecting metrics for #{name}..." }
            metrics = process_collector.collect
            metrics.each do |metric|
              client.send_json metric
            end
            logger&.info { "Metrics collected for #{name}." }
          rescue StandardError => e
            warn "#{name} Failed To Collect Stats #{e.class} #{e.message}"
            logger&.error { "#{e.class} #{e.message} #{e.backtrace.join("\n")}" }
            on_error(e)
          end
          sleep frequency
        end
      end
    end

    true
  end

  def self.stop
    return unless defined?(@thread)

    @thread&.kill
    @thread = nil
  end

  def initialize(labels = {})
    @metric_labels = labels || {}
  end

  def collect
    ActiveRecord::Base.connection_pool.with_connection do
      now = Time.now.utc
      metrics = []

      jobs_scope = BaseJob.all
      jobs_scope.pluck(:type, :updated_at).each do |(type, updated_at)|
        metrics << format_metric(job_delay: now - updated_at, labels: { job: type })
      end

      metrics
    end
  end

  private

  def format_metric(data)
    labels = (data.delete(:labels) || {}).merge(@metric_labels)
    {
      type: type,
      metric_labels: labels,
      **data
    }
  end
end
