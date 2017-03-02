require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

xdescribe Importing::Contractor do

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_contractor, {o_id: 8, name: 'TRN', vendor: true}
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_contractor, name: 'TRN'
    include_context :init_contractor, name: 'TRN'

    let(:real_item) { described_class.import_class.last }
  end

end
