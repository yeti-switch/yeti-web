# frozen_string_literal: true

class CdrBilling < Pgq::ConsumerGroup
  @consumer_name = 'cdr_billing'

  def initialize(logger, queue, consumer, options)
    super
    Dir['models/*.rb'].each { |file| require_relative File.join('../', file) }
    key = options['mode']
    ::RoutingBase.establish_connection options['databases'][key]['primary']

    # dbkey = @config['mode'] || 'development'
  end

  def perform_events(events)
    group = []
    events.each do |event|
      group << event.data
    end
    perform_group(group)
  end

  # {'type' => [events]}
  def perform_group(group)
    ::RoutingBase.execute_sp('SELECT * FROM billing.bill_cdr_batch(?, ?)', @batch_id, coder.dump(group))
  end
end
