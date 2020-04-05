# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

describe Importing::Rateplan do
  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_rateplan,
                    o_id: 8,
                    name: 'Cost+15%',
                    profit_control_mode_id: nil
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_rateplan, name: 'DIDWW Rateplan'
    include_context :init_rateplan, name: 'DIDWW Rateplan'

    let(:real_item) { described_class.import_class.last }
  end
end
