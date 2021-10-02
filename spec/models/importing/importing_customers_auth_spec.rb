# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_hook'

RSpec.describe Importing::CustomersAuth do
  include_context :init_pop
  include_context :init_contractor, name: 'iBasis', vendor: true, customer: true

  include_context :init_rateplan
  include_context :init_routing_plan
  include_context :init_account

  include_context :init_gateway_group, name: 'iBasis Gateway Group'

  include_context :init_codec_group

  include_context :init_gateway, name: 'SameName'

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_customers_auth,
                    o_id: 8,
                    customer_id: nil,
                    routing_plan_id: nil,
                    rateplan_id: nil,
                    account_id: nil,
                    gateway_id: nil,
                    diversion_policy_id: nil,
                    tag_action_id: nil,
                    tag_action_value: []

    it 'convert tag_action_value to array of IDs' do
      tag_action = Routing::TagAction.find_by(name: preview_item.tag_action_name)
      tags = Routing::RoutingTag.where(name: preview_item.tag_action_value_names.split(', '))

      subject

      expect(preview_item.reload).to have_attributes(
        tag_action_id: tag_action.id,
        tag_action_value: tags.map(&:id)
      )
    end

    include_examples :increments_customers_auth_state_seq
  end

  context 'when tag_action_value_names is NULL' do
    include_context :init_importing_customers_auth,
                    tag_action_value_names: nil,
                    tag_action_value: []

    it 'tag_action_value is empty array' do
      subject
      expect(preview_item.reload).to have_attributes(
        tag_action_value_names: nil,
        tag_action_value: []
      )
    end

    include_examples :increments_customers_auth_state_seq
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_customers_auth, name: 'SameName'
    include_context :init_customers_auth, name: 'SameName'

    let(:real_item) { described_class.import_class.last }

    include_examples :increments_customers_auth_state_seq
  end
end
