# frozen_string_literal: true

class InvoiceTerminatedDestinationDecorator < BillingDecorator
  delegate_all
  decorates Billing::InvoiceTerminatedDestination

  def decorated_amount
    money_format :amount
  end

  def decorated_calls_duration
    time_format_min :calls_duration
  end

  def decorated_billing_duration
    time_format_min :billing_duration
  end

  def decorated_calls_duration_kolon
    time_format_min_kolon :calls_duration
  end

  def decorated_calls_duration_dec
    time_format_min_dec :calls_duration
  end
end
