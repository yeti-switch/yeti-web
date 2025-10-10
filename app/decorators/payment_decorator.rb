# frozen_string_literal: true

class PaymentDecorator < BillingDecorator
  delegate_all
  decorates Payment

  def status_formatted
    status_tag(model.status, class: status_color)
  end

  def type_formatted
    status_tag(model.type_name, class: :no)
  end

  private

  def status_color
    if model.completed?
      :ok
    elsif model.pending?
      :warning
    elsif model.canceled? || model.rolled_back?
      :error
    end
  end
end
