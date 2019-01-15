# frozen_string_literal: true

class ReportCustomDataDecorator < BillingDecorator
  delegate_all
  decorates Report::CustomData

  def decorated_agg_calls_duration
    time_format_min :agg_calls_duration
  end

  def decorated_agg_calls_acd
    time_format_min :agg_calls_acd
  end

  def decorated_agg_asr_origination
    asr_format :agg_asr_origination
  end

  def decorated_agg_asr_termination
    asr_format :agg_asr_termination
  end

  def decorated_agg_customer_price
    money_format :agg_customer_price
  end

  def decorated_agg_vendor_price
    money_format :agg_vendor_price
  end

  def decorated_agg_profit
    money_format :agg_profit
  end
end
