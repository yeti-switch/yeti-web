# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_hook'

RSpec.describe Importing::RoutingGroup do
  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_routing_group, o_id: 8, name: 'Canada-RG-GG'
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_routing_group, name: 'Same Name'
    include_context :init_routing_group, name: 'Same Name'

    let(:real_item) { described_class.import_class.last }
  end
end
