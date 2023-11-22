# frozen_string_literal: true

class InvoiceDecorator < BillingDecorator
  delegate_all
  decorates Billing::Invoice

  decorates_association :originated_destinations, with: InvoiceOriginatedDestinationDecorator
  decorates_association :terminated_destinations, with: InvoiceTerminatedDestinationDecorator
  decorates_association :originated_networks, with: InvoiceOriginatedNetworkDecorator
  decorates_association :terminated_networks, with: InvoiceTerminatedNetworkDecorator

  def decorated_originated_amount
    money_format :originated_amount
  end

  def decorated_terminated_amount
    money_format :terminated_amount
  end

  def decorated_originated_calls_duration
    time_format_min :originated_calls_duration
  end

  def decorated_terminated_calls_duration
    time_format_min :terminated_calls_duration
  end

  def decorated_originated_billing_duration
    time_format_min :originated_billing_duration
  end

  def decorated_terminated_billing_duration
    time_format_min :terminated_billing_duration
  end

  def decorated_originated_calls_duration_kolon
    time_format_min_kolon :originated_calls_duration
  end

  def decorated_terminated_calls_duration_kolon
    time_format_min_kolon :terminated_calls_duration
  end

  def decorated_originated_calls_duration_dec
    time_format_min_dec :originated_calls_duration
  end

  def decorated_terminated_calls_duration_dec
    time_format_min_dec :terminated_calls_duration
  end
end
