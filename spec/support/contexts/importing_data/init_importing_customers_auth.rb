shared_context :init_importing_customers_auth do |args|

  args ||= {}

  before do
    fields = {
        customer_name: @contractor.name,
        customer_id: @contractor.id,
        rateplan_name: @rateplan.name,
        rateplan_id: @rateplan.id,
        enabled: true,
        account_name: @account.name,
        account_id: @account.id,
        gateway_name: @gateway.name,
        gateway_id: @gateway.id,
        routing_plan_name: @routing_plan.name,
        routing_plan_id: @routing_plan.id,
        src_rewrite_rule: ".*?0*(\\d*)$",
        src_rewrite_result: "\\1",
        dst_rewrite_rule: '',
        dst_rewrite_result: '',
        name: 'routeserver-me-pbx-TRN',
        dump_level_id: 3,
        capacity: 1,
        src_name_rewrite_rule: '',
        src_name_rewrite_result: '',
        diversion_policy_name: DiversionPolicy.find(1).name,
        diversion_policy_id: DiversionPolicy.find(1).id,
        diversion_rewrite_rule: '',
        diversion_rewrite_result: ''
    }.merge(args)

    @importing_customers_auth = FactoryGirl.create(:importing_customers_auth, fields)
  end
end
