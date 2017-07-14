require 'rest-client'
class  HttpExample < Pgq::ConsumerGroup
  @consumer_name = 'http_example'

  def initialize(logger, queue, consumer, options)
    super
    Dir['models/*.rb'].each { |file| require_relative File.join("../", file) }
    p options
    key=options['mode']
    ::RoutingBase.establish_connection options['databases'][key]

    #dbkey = @config['mode'] || 'development'
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
    response = RestClient.try(:post, 'http://yeti-switch.org', group)
    return
  end

end
