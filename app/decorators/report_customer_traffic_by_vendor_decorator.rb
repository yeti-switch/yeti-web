# frozen_string_literal: true

class ReportCustomerTrafficByVendorDecorator < BillingDecorator
  delegate_all
  decorates Report::CustomerTrafficDataByVendor

  def decorated_calls_duration
    time_format_min :calls_duration
  end

  def decorated_asr
    asr_format :asr
  end

  def decorated_acd
    time_format_min :acd
  end

  def decorated_origination_cost
    money_format :origination_cost
  end

  def decorated_termination_cost
    money_format :termination_cost
  end

  def decorated_profit
    money_format :profit
  end
end
