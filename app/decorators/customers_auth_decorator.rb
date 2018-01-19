class CustomersAuthDecorator < BillingDecorator

  delegate_all
  decorates CustomersAuth

  decorates_association :gateway, with: GatewayDecorator
  decorates_association :customer, with: ContractorDecorator
  decorates_association :account, with: AccountDecorator
  decorates_association :routing_plan, with: RoutingPlanDecorator

  include RoutingTagActionDecorator

  def decorated_display_name
    if !enabled?
      h.content_tag(:font,display_name, color: :red)
    else
      display_name
    end
  end

end
