# frozen_string_literal: true

class CustomersAuthDecorator < BillingDecorator
  delegate_all
  decorates CustomersAuth

  decorates_association :gateway, with: GatewayDecorator
  decorates_association :customer, with: ContractorDecorator
  decorates_association :account, with: AccountDecorator
  decorates_association :routing_plan, with: RoutingPlanDecorator

  def privacy_mode_name
    CustomersAuth::PRIVACY_MODES[privacy_mode_id]
  end

  def display_tag_action_value
    h.tag_action_values_badges(model.tag_action_value)
  end

  def decorated_display_name
    if !enabled?
      h.content_tag(:font, display_name, color: :red)
    else
      display_name
    end
  end

  CustomersAuth::CONST::MATCH_CONDITION_ATTRIBUTES.each do |attribute_name|
    define_method attribute_name do
      model.public_send(attribute_name).map(&:strip).join(', ')
    end
  end

  # TODO: when AA fixe probjec with decorated objec on create use this:
  # https://github.com/activeadmin/activeadmin/blob/15eb4a05b2ee759b7d03ceaaa92d070986a1c282/spec/support/templates/post_decorator.rb
end
