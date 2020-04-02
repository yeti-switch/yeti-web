# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

describe Importing::Account do
  include_context :init_contractor, name: 'PBXww', vendor: false, customer: true

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_account, o_id: 8, name: 'TRN-ACC', contractor_id: nil
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_account, name: 'SameName'
    include_context :init_account, name: 'SameName'

    let(:real_item) { described_class.import_class.last }
  end
end
