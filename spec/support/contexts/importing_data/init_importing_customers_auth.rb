shared_context :init_importing_customers_auth do |args|

  include_context :init_routing_tag_collection

  args ||= {}

  before do
    fields = {
        customer_name: @contractor.name,
        customer_id: @contractor.id,
        rateplan_name: @rateplan.name,
        rateplan_id: @rateplan.id,
        enabled: true,
        ip: '1.1.1.1',
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
        src_prefix: '7499918',
        dst_prefix: '7',
        x_yeti_auth: 'RS-STATIC',
        name: 'routeserver-me-pbx-TRN',
        dump_level_id: 3,
        capacity: 1,
        uri_domain: 'telefonica-eu.com',
        src_name_rewrite_rule: '',
        src_name_rewrite_result: '',
        diversion_policy_name: DiversionPolicy.find(1).name,
        diversion_policy_id: DiversionPolicy.find(1).id,
        diversion_rewrite_rule: '',
        diversion_rewrite_result: '',
        tag_action_id: Routing::TagAction.take.id,
        tag_action_value: [@tag_ua.id, @tag_us.id]
    }.merge(args)

    @importing_customers_auth = FactoryGirl.create(:importing_customers_auth, fields)
  end
end
