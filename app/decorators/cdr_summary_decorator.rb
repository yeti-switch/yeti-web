# frozen_string_literal: true

class CdrSummaryDecorator < BillingDecorator
  # delegate_all
  # decorates Report::CustomerTrafficDataByDestination

  def decorated_calls_duration
    time_format_min :calls_duration
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

  def decorated_calls_durarion
    time_format_min :calls_duration
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
end
