# frozen_string_literal: true

class CustomersAuthDecorator < BillingDecorator
  delegate_all
  decorates CustomersAuth

  decorates_association :gateway, with: GatewayDecorator
  decorates_association :customer, with: ContractorDecorator
  decorates_association :account, with: AccountDecorator
  decorates_association :routing_plan, with: RoutingPlanDecorator

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

  def decorated_ip
    h.safe_join([
                  *(h.tag.span(transport_protocol_name, class: 'status_tag ok') unless transport_protocol_id.nil?),
                  ip,
                  *(h.tag.span('Require Auth', class: 'status_tag warn') if require_incoming_auth?)
                ], ' ')
  end

  def decorated_enabled
    h.safe_join([
                  h.tag.span(enabled? ? 'Yes' : 'No', class: enabled? ? 'status_tag ok' : 'status_tag'),
                  *(h.tag.span('Reject calls', class: 'status_tag red') if reject_calls?)
                ], ' ')
  end

  CustomersAuth::CONST::MATCH_CONDITION_ATTRIBUTES.each do |attribute_name|
    define_method attribute_name do
      model.public_send(attribute_name).map(&:strip).join(', ')
    end
  end

  # TODO: when AA fixe probjec with decorated objec on create use this:
  # https://github.com/activeadmin/activeadmin/blob/15eb4a05b2ee759b7d03ceaaa92d070986a1c282/spec/support/templates/post_decorator.rb
end
