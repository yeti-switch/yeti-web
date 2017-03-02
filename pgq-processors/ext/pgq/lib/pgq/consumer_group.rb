# for consuming full batch (usefull if need group events for some group processing)
# usually group is ~500 events

require 'pgq/consumer'

class Pgq::ConsumerGroup < Pgq::Consumer
  
  # {'type' => [events]}
  def perform_group(events_hash)
    raise "realize me"
  end
  
  def perform_events(events)
    events = sum_events(events)
    # log_info "consume events (#{self.queue_name}): #{events.map{|k,v| [k, v.size]}.inspect}"
    perform_group(events) if events.present?
  end

  def sum_events(events)
    events.inject({}) do |result, event|
      result[event.type] ||= []
      result[event.type] << event
      result
    end
  end

end
