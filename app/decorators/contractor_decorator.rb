# frozen_string_literal: true

class ContractorDecorator < BillingDecorator
  delegate_all
  decorates Contractor

  def decorated_vendor_display_name
    if !is_enabled? || !vendor?
      h.content_tag(:font, display_name, color: :red)
    else
      display_name
    end
  end

  def decorated_customer_display_name
    if !is_enabled? || !customer?
      h.content_tag(:font, display_name, color: :red)
    else
      display_name
    end
  end

  def decorated_display_name
    if !is_enabled?
      h.content_tag(:font, display_name, color: :red)
    else
      display_name
    end
  end
end
