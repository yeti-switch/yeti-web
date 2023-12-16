# frozen_string_literal: true

class InvoiceDecorator < BillingDecorator
  delegate_all
  decorates Billing::Invoice

  decorates_association :originated_destinations, with: InvoiceOriginatedDestinationDecorator, scope: :for_invoice
  decorates_association :terminated_destinations, with: InvoiceTerminatedDestinationDecorator, scope: :for_invoice
  decorates_association :originated_networks, with: InvoiceOriginatedNetworkDecorator, scope: :for_invoice
  decorates_association :terminated_networks, with: InvoiceTerminatedNetworkDecorator, scope: :for_invoice

  def decorated_amount_total
    money_format :amount_total
  end

  def decorated_amount_spent
    money_format :amount_spent
  end

  def decorated_amount_earned
    money_format :amount_earned
  end

  def decorated_originated_amount_spent
    money_format :originated_amount_spent
  end

  def decorated_originated_amount_earned
    money_format :originated_amount_earned
  end

  def decorated_terminated_amount_spent
    money_format :terminated_amount_spent
  end

  def decorated_terminated_amount_earned
    money_format :terminated_amount_earned
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
