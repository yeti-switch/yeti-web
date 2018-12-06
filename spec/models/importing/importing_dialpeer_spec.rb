require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'
require 'shared_examples/shared_examples_for_importing_with_routing_tags'

describe Importing::Dialpeer do

  include_context :init_contractor, name: 'iBasis', vendor: true, customer: true
  include_context :init_routing_group
  include_context :init_account

  include_context :init_rateplan
  include_context :init_gateway_group, name: 'iBasis Gateway Group'
  include_context :init_codec_group
  include_context :init_gateway, name: 'iBasis UA'
  include_context :init_routeset_discriminator

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:prefix])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_dialpeer,
                    {
                        o_id: 8,
                        routing_group_id: nil,
                        vendor_id: nil,
                        account_id: nil,
                        routing_tag_mode_id: nil,
                        routing_tag_ids: []
                    }

    it 'resolve Tag names to array of IDs' do
      tags = Routing::RoutingTag.where(name: preview_item.routing_tag_names.split(', '))

      subject

      expect(preview_item.reload).to have_attributes(
        routing_tag_mode_id: Routing::RoutingTagMode.find_by(name: preview_item.routing_tag_mode_name).id,
        routing_tag_ids: tags.map(&:id)
      )
    end
  end

  it_behaves_like 'resolve routing_tag_names=NULL as empty array', :init_importing_dialpeer

  it_behaves_like 'resolve "any tag" as NULL', :init_importing_dialpeer

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_dialpeer, prefix: '111'
    include_context :init_dialpeer, prefix: '111'

    let(:real_item) { described_class.import_class.last }
  end

end
