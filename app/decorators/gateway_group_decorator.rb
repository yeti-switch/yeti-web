class GatewayGroupDecorator < BillingDecorator

  delegate_all
  decorates GatewayGroup

  decorates_association :vendor, with: ContractorDecorator

  def decorated_display_name
    if !have_valid_gateways?
      h.content_tag(:font,display_name, color: :red)
    else
      display_name
    end
  end

end