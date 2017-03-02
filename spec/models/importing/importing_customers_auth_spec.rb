require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

xdescribe Importing::CustomersAuth do

  include_context :init_contractor, name: 'iBasis', vendor: true, customer: true

  include_context :init_rateplan
  include_context :init_routing_group
  include_context :init_routing_plan
  include_context :init_account

  include_context :init_gateway_group, name: 'iBasis Gateway Group'

  include_context :init_codec_group

  include_context :init_gateway, name: 'SameName'


  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:name])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_customers_auth,
                    {
                        o_id: 8,
                        customer_id: nil,
                        routing_group_id: nil,
                        routing_plan_id: nil,
                        rateplan_id: nil,
                        account_id: nil,
                        gateway_id: nil,
                        diversion_policy_id: nil
                    }
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_customers_auth, name: 'SameName'
    include_context :init_customers_auth, name: 'SameName'

    let(:real_item) { described_class.import_class.last }
  end

end
