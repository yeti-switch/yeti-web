# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_job'

RSpec.xdescribe 'Importing::Gateway => Gateway delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_contractor, name: 'iBasis', vendor: true
      include_context :init_gateway_group, name: 'iBasis Gateway Group'
      include_context :init_codec_group
      include_context :init_importing_gateway
      let(:preview_class) { Importing::Gateway }
    end
  end
end
