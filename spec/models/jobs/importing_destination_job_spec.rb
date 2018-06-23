require 'shared_examples/shared_examples_for_importing_job'

RSpec.describe 'Importing::Destination => Destination delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_rateplan, name: 'Cost'
      include_context :init_importing_destination
      let(:preview_class) { Importing::Destination }
    end
  end
end
