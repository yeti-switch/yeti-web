# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_hook'
require 'shared_examples/shared_examples_for_importing_with_routing_tags'

RSpec.describe Importing::RoutingTagDetectionRule do
  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:src_prefix])
  end

  let(:preview_item) { described_class.last }

  it_behaves_like 'resolve routing_tag_names=NULL as empty array', :init_importing_routing_tag_detection_rule

  it_behaves_like 'resolve "any tag" as NULL', :init_importing_routing_tag_detection_rule

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_routing_tag_detection_rule,
                    o_id: 8,
                    src_prefix: '111',
                    tag_action_id: nil,
                    tag_action_value: [],
                    routing_tag_ids: []

    let!(:tags) { Routing::RoutingTag.where(name: preview_item.routing_tag_names.split(', ')) }

    it 'resolve Tag names to array of IDs' do
      subject
      expect(preview_item.reload).to have_attributes(routing_tag_ids: tags.map(&:id))
    end
  end

  it_behaves_like 'after_import_hook when real items match' do
    let!(:routing_tag_detection_rule) { FactoryBot.create(:routing_tag_detection_rule, src_prefix: '111') }

    include_context :init_importing_routing_tag_detection_rule, src_prefix: '111'

    let(:real_item) { described_class.import_class.last }
  end
end
