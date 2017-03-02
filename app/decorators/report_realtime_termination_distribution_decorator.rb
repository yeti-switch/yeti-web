class ReportRealtimeTerminationDistributionDecorator < BillingDecorator

  delegate_all
  decorates Report::Realtime::TerminationDistribution

  def decorated_calls_duration
    time_format_min :calls_duration
  end

  def decorated_cps
    cps_format :cps
  end

  def decorated_origination_asr
    asr_format :origination_asr
  end

  def decorated_termination_asr
    asr_format :termination_asr
  end

  def decorated_acd
    time_format_min :acd
  end

  def decorated_customer_price
    money_format :customer_price
  end

  def decorated_vendor_price
    money_format :vendor_price
  end

  def decorated_profit
    money_format :profit
  end

  def decorated_offered_load
    offered_load_format :offered_load
  end

  def decorated_routing_delay
    avg_routing_delay.nil? ? nil : "#{avg_routing_delay.round(4)} (#{min_routing_delay.round(4)}..#{max_routing_delay.round(4)})"
  end

end