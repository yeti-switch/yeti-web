# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

describe Importing::Registration do
  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_registration, o_id: 8, name: 'HOT-Free-Telecom-REG-Test', pop_id: nil, node_id: nil
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_registration, name: 'the-same-name'
    include_context :init_registration, name: 'the-same-name'

    let(:real_item) { described_class.import_class.last }
  end
end
