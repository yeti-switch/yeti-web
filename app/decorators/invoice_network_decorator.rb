# frozen_string_literal: true

class InvoiceNetworkDecorator < BillingDecorator
  delegate_all
  decorates Billing::InvoiceNetwork

  def decorated_amount
    money_format :amount
  end

  def decorated_calls_duration
    time_format_min :calls_duration
  end

  def decorated_customer_calls_duration
    time_format_min :customer_calls_duration
  end

  def decorated_vendor_calls_duration
    time_format_min :vendor_calls_duration
  end

  def decorated_calls_duration_kolon
    time_format_min_kolon :calls_duration
  end

  def decorated_calls_duration_dec
    time_format_min_dec :calls_duration
  end
end
