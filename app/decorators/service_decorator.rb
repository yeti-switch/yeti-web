# frozen_string_literal: true

class ServiceDecorator < BillingDecorator
  decorates Billing::Service

  def state_badge
    status_tag(object.state, class: state_color)
  end

  private

  def state_color
    object.state_id == Billing::Service::STATE_ID_ACTIVE ? 'ok' : 'red'
  end
end
