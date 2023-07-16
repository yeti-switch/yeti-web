# frozen_string_literal: true

class PaymentDecorator < BillingDecorator
  delegate_all
  decorates Payment

  def status_formatted
    status_tag(status, class: status_color)
  end

  private

  def status_color
    if model.completed?
      :ok
    elsif model.pending?
      :warning
    elsif model.canceled?
      :error
    end
  end
end
