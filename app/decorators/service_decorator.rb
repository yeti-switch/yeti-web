# frozen_string_literal: true

class ServiceDecorator < BillingDecorator
  decorates Billing::Service

  def state_badge
    status_tag(object.state, class: state_color)
  end

  private

  def state_color
    case object.state_id
    when Billing::Service::STATE_ID_ACTIVE
      'ok'
    when Billing::Service::STATE_ID_SUSPENDED
      'warning'
    when Billing::Service::STATE_ID_TERMINATED
      'error'
    else
      'warning'
    end
  end
end
