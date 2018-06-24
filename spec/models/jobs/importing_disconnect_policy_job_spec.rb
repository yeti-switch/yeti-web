require 'shared_examples/shared_examples_for_importing_job'

RSpec.describe 'Importing::DisconnectPolicy => DisconnectPolicy delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_importing_disconnect_policy
      let(:preview_class) { Importing::DisconnectPolicy }
    end
  end
end
