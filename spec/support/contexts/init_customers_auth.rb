shared_context :init_customers_auth do |args|

  args ||= {}

  before do
    fields = {
        name: 'routeserver-me-pbx-TRN',
        customer_id: @contractor.id,
        rateplan_id: @rateplan.id,
        enabled: true,
        ip: '46.19.211.14',
        account_id: @account.id,
        gateway_id: @gateway.id,
        routing_plan_id: @routing_plan.id,
        src_rewrite_rule: ".*?0*(\\d*)$",
        src_rewrite_result: "\\1",
        dst_rewrite_rule: '',
        dst_rewrite_result: '',
        src_prefix: '7499918',
        dst_prefix: '7',
        x_yeti_auth: 'RS-STATIC',
        dump_level_id: 3,
        capacity: 1,
        uri_domain: 'telefonica-eu.com',
        src_name_rewrite_rule: '',
        src_name_rewrite_result: '',
        diversion_policy_id: DiversionPolicy.find(1).id,
        diversion_rewrite_rule: '',
        diversion_rewrite_result: ''
    }.merge(args)

    @customers_auth = FactoryGirl.create(:customers_auth, fields)
  end
end
