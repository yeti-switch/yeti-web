# frozen_string_literal: true

class TransactionDecorator < BillingDecorator
  decorates Billing::Transaction

  def service_link
    if object.service
      h.link_to object.service.display_name, h.service_path(object.service)
    else
      object.service_id
    end
  end
end
