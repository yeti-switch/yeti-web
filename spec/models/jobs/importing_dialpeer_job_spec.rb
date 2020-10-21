# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_job'

RSpec.describe 'Importing::Dialpeer => Dialpeer delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_pop
      include_context :init_contractor, name: 'iBasis', vendor: true, customer: true
      include_context :init_routing_group
      include_context :init_account
      include_context :init_rateplan
      include_context :init_gateway_group, name: 'iBasis Gateway Group'
      include_context :init_codec_group
      include_context :init_gateway, name: 'iBasis UA'
      include_context :init_routeset_discriminator
      include_context :init_importing_dialpeer
      let(:preview_class) { Importing::Dialpeer }
    end
  end
end
