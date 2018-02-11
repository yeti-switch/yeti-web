require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_job'

describe 'Importing::CustomersAuth => CustomersAuth delayed_job' do
  it_behaves_like 'Jobs for importing data' do
     include_context :init_importing_delayed_job do
       include_context :init_contractor, name: 'iBasis', vendor: true, customer: true
       include_context :init_rateplan
       include_context :init_routing_group
       include_context :init_routing_plan
       include_context :init_account
       include_context :init_gateway_group, name: 'iBasis Gateway Group'
       include_context :init_codec_group
       include_context :init_gateway, name: 'iBasis GW'
       include_context :init_importing_customers_auth
       let(:preview_class) { Importing::CustomersAuth }
    end
  end
end
