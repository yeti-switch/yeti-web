# frozen_string_literal: true

class InvoiceServiceDataDecorator < BillingDecorator
  decorates Billing::InvoiceServiceData

  def decorated_amount
    money_format :amount
  end

  def type_badge
    model.spent ? status_tag('spent', class: :blue) : status_tag('earned', class: :green)
  end

  def service_link
    if model.service
      h.link_to model.service.name, service_path(model.service)
    elsif model.service_id
      model.service_id
    else
      nil
    end
  end
end
