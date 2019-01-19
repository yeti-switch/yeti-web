# frozen_string_literal: true

class DialpeerDecorator < BillingDecorator
  delegate_all
  decorates Dialpeer

  include RoutingTagIdsDecorator

  decorates_association :gateway, with: GatewayDecorator
  decorates_association :gateway_group, with: GatewayGroupDecorator
  decorates_association :vendor, with: ContractorDecorator
  decorates_association :account, with: AccountDecorator

  def decorated_display_name
    if !enabled?
      h.content_tag(:font, display_name, color: :red)
    elsif locked?
      h.content_tag(:font, display_name, color: :orange)
    else
      display_name
    end
  end

  def decorated_valid_from
    is_valid_from? ? valid_from : h.content_tag(:font, valid_from, color: :red)
  end

  def decorated_valid_till
    is_valid_till? ? valid_till : h.content_tag(:font, valid_till, color: :red)
  end
end
