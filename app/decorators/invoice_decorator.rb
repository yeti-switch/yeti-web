class InvoiceDecorator < BillingDecorator

  delegate_all
  decorates Billing::Invoice

  decorates_association :destinations, with: InvoiceDestinationDecorator

  def decorated_amount
    money_format :amount
  end

  def decorated_calls_duration
    time_format_min :calls_duration
  end

  def decorated_calls_duration_kolon
    time_format_min_kolon :calls_duration
  end

  def decorated_calls_duration_dec
    time_format_min_dec :calls_duration
  end

end