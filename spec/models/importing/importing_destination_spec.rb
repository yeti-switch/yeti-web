require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

describe Importing::Destination do

  include_context :init_rateplan, name: 'Cost'

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:prefix])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_destination, {
      o_id: 8,
      prefix: '373900',
      rateplan_id: nil,
      rate_policy_id: nil,
      routing_tag_ids: []
    }

    it 'resolve Tag names to array of IDs' do
      tags = Routing::RoutingTag.where(name: preview_item.routing_tag_names.split(', '))

      subject

      expect(preview_item.reload).to have_attributes(
        routing_tag_ids: tags.map(&:id)
      )
    end
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_destination, prefix: '373900'
    include_context :init_destination, prefix: '373900'

    let(:real_item) { described_class.import_class.last }
  end

end
