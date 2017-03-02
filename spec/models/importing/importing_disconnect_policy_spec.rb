require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

describe Importing::DisconnectPolicy do

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_disconnect_policy, {o_id: 8, name: 'example_name_here_200'}
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_disconnect_policy, name: 'can_not_send_503'
    # Real Disconnect Policy "can_not_send_503" was created by fixtures

    let(:real_item) { described_class.import_class.last }
  end

end
