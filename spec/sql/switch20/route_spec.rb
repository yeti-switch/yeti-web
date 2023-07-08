# frozen_string_literal: true

RSpec.describe '#routing logic' do
  def routing_sp
    SqlCaller::Yeti.select_all('set search_path to switch20,sys,public')
    SqlCaller::Yeti.select_all_serialized(
      "SELECT * from switch20.route_#{mode}(
        ?::integer,
        ?::integer,
        ?::smallint,
        ?::inet,
        ?::integer,
        ?::inet,
        ?::integer,
        ?::varchar,
        ?::varchar,
        ?::varchar,
        ?::integer,
        ?::varchar,
        ?::varchar,
        ?::integer,
        ?::varchar,
        ?::varchar,
        ?::integer,
        ?::varchar,
        ?::varchar,
        ?::integer, /* i_auth_id */
        ?::json, /* i_identity */
        ?::varchar,
        ?::varchar,
        ?::inet,
        ?::integer,
        ?::smallint,
        ?::varchar,
        ?::varchar,
        ?::varchar,
        ?::varchar,
        ?::varchar
      )",
      node_id,
      pop_id,
      protocol_id,
      remote_ip,
      remote_port,
      local_ip,
      local_port,
      from_dsp,
      from_name,
      from_domain,
      from_port,
      to_name,
      to_domain,
      to_port,
      contact_name,
      contact_domain,
      contact_port,
      uri_name,
      uri_domain,
      auth_id,
      identity,
      x_yeti_auth,
      diversion,
      x_orig_ip,
      x_orig_port,
      x_orig_protocol_id,
      pai,
      ppi,
      privacy,
      rpid,
      rpid_privacy
    )
  end

  subject do
    routing_sp
  end

  let(:node_id) { 1 }
  let(:pop_id) { 12 }
  let(:protocol_id) { 1 }
  let(:remote_ip) { '1.1.1.1' }
  let(:remote_port) { 5060 }
  let(:local_ip) { '2.2.2.2' }
  let(:local_port) { 5060 }
  let(:from_dsp) { 'from display name' }
  let(:from_name) { 'from_username' }
  let(:from_domain) { 'from-domain' }
  let(:from_port) { 5060 }
  let(:to_name) { 'to_username' }
  let(:to_domain) { 'to-domain' }
  let(:to_port) { 5060 }
  let(:contact_name) { 'contact-username' }
  let(:contact_domain) { 'contact-domain' }
  let(:contact_port) { 5060 }
  let(:uri_name) { 'uri-name' }
  let(:uri_domain) { 'uri-domain' }
  let(:auth_id) { nil }
  let(:identity) { '[]' }
  let(:x_yeti_auth) { nil }
  let(:diversion) { 'diversion' }
  let(:x_orig_ip) { '3.3.3.3' }
  let(:x_orig_port) { 6050 }
  let(:x_orig_protocol_id) { 2 }
  let(:pai) { 'pai' }
  let(:ppi) { 'ppi' }
  let(:privacy) { 'privacy' }
  let(:rpid) { 'rpid' }
  let(:rpid_privacy) { 'rpid-privacy' }

  shared_examples 'routing' do
    context 'Use X-SRC-IP if originator is trusted load balancer' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')
      end
      let!(:customer_auth) { FactoryBot.create(:customers_auth, customer_auth_attrs) }
      let(:customer_auth_attrs) { { ip: x_orig_ip } }
      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'return 404 ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:customer_auth_id]).to eq customer_auth.id
        expect(subject.first[:customer_auth_external_id]).to be_nil
        expect(subject.first[:customer_auth_external_type]).to be_nil
      end

      context 'when customer_auth has external_id only' do
        let(:customer_auth_attrs) do
          super().merge external_id: 123
        end

        it 'return 404 ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to eq(customer_auth.id)
          expect(subject.first[:customer_auth_external_id]).to eq(123)
          expect(subject.first[:customer_auth_external_type]).to be_nil
        end
      end

      context 'when customer_auth has external_id and external_type' do
        let(:customer_auth_attrs) do
          super().merge external_id: 123, external_type: 'term'
        end

        it 'return 404 ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to eq(customer_auth.id)
          expect(subject.first[:customer_auth_external_id]).to eq(123)
          expect(subject.first[:customer_auth_external_type]).to eq('term')
        end
      end
    end

    context 'Use remote IP if originator is not trusted load balancer' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '5.5.5.5')

        FactoryBot.create(:customers_auth,
                          ip: '3.3.3.3')
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'return 404 ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:customer_auth_id]).to be_nil
        expect(subject.first[:disconnect_code_id]).to eq(110) # #Cant find customer or customer locked
      end
    end

    context 'Authentification' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')
        @ca = FactoryBot.create(:customers_auth, :with_incoming_auth, ca_attrs)
      end
      let(:ca_attrs) { { ip: '3.3.3.3' } }

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      context 'No auth data' do
        it 'Reject with 401' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be_nil
          expect(subject.first[:customer_auth_external_id]).to be_nil
          expect(subject.first[:customer_auth_external_type]).to be_nil
          expect(subject.first[:aleg_auth_required]).to eq(true)
        end
      end

      context 'Authorized' do
        let(:auth_id) { @ca.gateway_id }

        it 'Pass auth' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to eq(@ca.id)
          expect(subject.first[:customer_auth_external_id]).to be_nil
          expect(subject.first[:customer_auth_external_type]).to be_nil
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance
        end

        context 'when customer_auth has external_id only' do
          let(:ca_attrs) do
            super().merge external_id: 123
          end

          it 'Pass auth' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to eq(@ca.id)
            expect(subject.first[:customer_auth_external_id]).to eq(123)
            expect(subject.first[:customer_auth_external_type]).to be_nil
            expect(subject.first[:aleg_auth_required]).to be_nil
            expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance
          end
        end

        context 'when customer_auth has external_id and external_type' do
          let(:ca_attrs) do
            super().merge external_id: 123, external_type: 'term'
          end

          it 'Pass auth' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to eq(@ca.id)
            expect(subject.first[:customer_auth_external_id]).to eq(123)
            expect(subject.first[:customer_auth_external_type]).to eq('term')
            expect(subject.first[:aleg_auth_required]).to be_nil
            expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance
          end
        end
      end
    end

    context 'Authentification+Reject' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')
        @ca = FactoryBot.create(:customers_auth, :with_incoming_auth, :with_reject, ca_attrs)
      end
      let(:ca_attrs) { { ip: '3.3.3.3' } }
      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      context 'No auth data' do
        it 'Reject with 401' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be_nil
          expect(subject.first[:aleg_auth_required]).to eq(true)
        end
      end

      context 'Authorized' do
        let(:auth_id) { CustomersAuth.take!.gateway_id }

        it 'Pass auth' do
          expect(subject.size).to eq(1)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

          expect(subject.first[:customer_auth_id]).to eq(@ca.id)
          expect(subject.first[:customer_auth_external_id]).to be_nil
          expect(subject.first[:customer_auth_external_type]).to be_nil
          expect(subject.first[:customer_id]).to eq(@ca.customer_id)
          expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
          expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
          expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
          expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
          expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
        end

        context 'when customer_auth has external_id only' do
          let(:ca_attrs) do
            super().merge external_id: 123
          end

          it 'Pass auth' do
            expect(subject.size).to eq(1)
            expect(subject.first[:aleg_auth_required]).to be_nil
            expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

            expect(subject.first[:customer_auth_id]).to eq(@ca.id)
            expect(subject.first[:customer_auth_external_id]).to eq(123)
            expect(subject.first[:customer_auth_external_type]).to be_nil
            expect(subject.first[:customer_id]).to eq(@ca.customer_id)
            expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
            expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
            expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
            expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
            expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
          end
        end

        context 'when customer_auth has external_id and external_type' do
          let(:ca_attrs) do
            super().merge external_id: 123, external_type: 'term'
          end

          it 'Pass auth' do
            expect(subject.size).to eq(1)
            expect(subject.first[:aleg_auth_required]).to be_nil
            expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

            expect(subject.first[:customer_auth_id]).to eq(@ca.id)
            expect(subject.first[:customer_auth_external_id]).to eq(123)
            expect(subject.first[:customer_auth_external_type]).to eq('term')
            expect(subject.first[:customer_id]).to eq(@ca.customer_id)
            expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
            expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
            expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
            expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
            expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
          end
        end
      end
    end

    context 'Reject calls without Authentification' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')
        @ca = FactoryBot.create(:customers_auth, :with_reject, ca_attrs)
      end
      let(:ca_attrs) { { ip: '3.3.3.3' } }
      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'Reject' do
        expect(subject.size).to eq(1)
        expect(subject.first[:aleg_auth_required]).to be_nil
        expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

        expect(subject.first[:customer_auth_id]).to eq(@ca.id)
        expect(subject.first[:customer_auth_external_id]).to be_nil
        expect(subject.first[:customer_auth_external_type]).to be_nil
        expect(subject.first[:customer_id]).to eq(@ca.customer_id)
        expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
        expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
        expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
        expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
        expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
      end

      context 'when customer_auth has external_id only' do
        let(:ca_attrs) do
          super().merge external_id: 123
        end

        it 'Reject' do
          expect(subject.size).to eq(1)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

          expect(subject.first[:customer_auth_id]).to eq(@ca.id)
          expect(subject.first[:customer_auth_external_id]).to eq(123)
          expect(subject.first[:customer_auth_external_type]).to be_nil
          expect(subject.first[:customer_id]).to eq(@ca.customer_id)
          expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
          expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
          expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
          expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
          expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
        end
      end

      context 'when customer_auth has external_id and external_type' do
        let(:ca_attrs) do
          super().merge external_id: 123, external_type: 'term'
        end

        it 'Reject' do
          expect(subject.size).to eq(1)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

          expect(subject.first[:customer_auth_id]).to eq(@ca.id)
          expect(subject.first[:customer_auth_external_id]).to eq(123)
          expect(subject.first[:customer_auth_external_type]).to eq('term')
          expect(subject.first[:customer_id]).to eq(@ca.customer_id)
          expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
          expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
          expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
          expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
          expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
        end
      end
    end

    context 'Authorized but customer has no enough balance' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')

        @ca = FactoryBot.create(:customers_auth,
                                ip: '3.3.3.3')
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'reject ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:aleg_auth_required]).to be_nil
        expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance

        expect(subject.first[:customer_auth_id]).to eq(@ca.id)
        expect(subject.first[:customer_auth_external_id]).to eq(@ca.external_id)
        expect(subject.first[:customer_id]).to eq(@ca.customer_id)
        expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
        expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
        expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
        expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
        expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
      end
    end

    context 'Authorized, Balance checking disabled' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')

        FactoryBot.create(:customers_auth,
                          ip: '3.3.3.3',
                          check_account_balance: false,
                          customer: customer,
                          gateway: customer_gateway,
                          dump_level_id: dump_level)
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }
      let!(:customer) do
        create(:contractor, customer: true)
      end
      let!(:customer_gateway) {
        create(:gateway,
               contractor: customer,
               orig_disconnect_policy_id: dp.id)
      }
      let(:dp) {
        create(:disconnect_policy)
      }
      let(:dump_level) { CustomersAuth::DUMP_LEVEL_CAPTURE_SIP }

      it 'reject ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:customer_auth_id]).to be
        expect(subject.first[:customer_id]).to be
        expect(subject.first[:disconnect_code_id]).to eq(111) # Can't find destination prefix
        expect(subject.first[:aleg_policy_id]).to eq(dp.id)
        expect(subject.first[:dump_level_id]).to eq(dump_level)
      end
    end

    context 'Authorized, Balance checking disabled, LNP' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')

        FactoryBot.create(:customers_auth,
                          ip: '3.3.3.3',
                          check_account_balance: false,
                          routing_plan_id: routing_plan.id)
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }
      let!(:routing_plan) { create(:routing_plan, use_lnp: true) }
      let!(:lnp_rule) { create(:lnp_routing_plan_lnp_rule, routing_plan_id: routing_plan.id, drop_call_on_error: drop_call_on_error, rewrite_call_destination: rewrite_call_destination) }

      context 'Authorized, Balance checking disabled, LNP Error' do
        let(:drop_call_on_error) { true }
        let(:rewrite_call_destination) { false }

        it 'LNP fail ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(8003) # no LNP Error
          expect(subject.first[:lrn]).to eq(nil) # No LRN
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
        end
      end

      context 'Authorized, Balance checking disabled, LNP Error failover' do
        let(:drop_call_on_error) { false }
        let(:rewrite_call_destination) { false }

        it 'LNP fail ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(111) # no destination
          expect(subject.first[:lrn]).to eq(nil) # No LRN
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
        end
      end

      context 'Authorized, Balance checking disabled, LNP cache without redirect' do
        let(:drop_call_on_error) { true }
        let(:rewrite_call_destination) { false }
        let!(:lnp_cache) { create(:lnp_cache, database_id: lnp_rule.database_id, dst: 'uri-name', lrn: 'lrn111') }

        it 'LNP fail ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(111) # no destination
          expect(subject.first[:lrn]).to eq('lrn111') # LRN from cache
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
        end
      end

      context 'Authorized, Balance checking disabled, LNP cache with redirect' do
        let(:drop_call_on_error) { true }
        let(:rewrite_call_destination) { true }
        let!(:lnp_cache) { create(:lnp_cache, database_id: lnp_rule.database_id, dst: 'uri-name', lrn: 'lrn111') }

        it 'LNP fail ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(111) # no destination
          expect(subject.first[:lrn]).to eq('lrn111') # LRN from cache
          expect(subject.first[:dst_prefix_out]).to eq('lrn111') # Destination rewrited
          expect(subject.first[:dst_prefix_routing]).to eq('lrn111') # Destination rewrited
        end
      end
    end

    context 'Authorized, Successful routing' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')

        FactoryBot.create(:customers_auth,
                          ip: '3.3.3.3',
                          check_account_balance: false,
                          customer: customer,
                          account: customer_account,
                          gateway: customer_gateway,
                          rateplan_id: rateplan.id,
                          routing_plan_id: routing_plan.id,
                          send_billing_information: send_billing_information,
                          diversion_policy_id: customer_auth_diversion_policy_id,
                          diversion_rewrite_rule: customer_auth_diversion_rewrite_rule,
                          diversion_rewrite_result: customer_auth_diversion_rewrite_result,
                          cps_limit: customer_auth_cps_limit,
                          src_numberlist_id: customer_auth_src_numberlist_id,
                          dst_numberlist_id: customer_auth_dst_numberlist_id,
                          dump_level_id: customer_auth_dump_level,
                          src_numberlist_use_diversion: customer_auth_src_numberlist_use_diversion,
                          rewrite_ss_status_id: customer_auth_rewrite_ss_status_id
        )
      end

      let!(:send_billing_information) { false }
      let(:customer_auth_diversion_policy_id) { 1 } # do not accept diversion header
      let(:customer_auth_diversion_rewrite_rule) { nil } # removing +380
      let(:customer_auth_diversion_rewrite_result) { nil }
      let(:customer_auth_cps_limit) { nil }
      let(:customer_auth_src_numberlist_id) { nil }
      let(:customer_auth_dst_numberlist_id) { nil }
      let(:customer_auth_dump_level) { CustomersAuth::DUMP_LEVEL_CAPTURE_SIP }
      let(:customer_auth_src_numberlist_use_diversion) { false }
      let(:customer_auth_rewrite_ss_status_id) { nil }

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }
      let!(:vendor) { create(:contractor, vendor: true, enabled: true) }
      let!(:vendor_account) { create(:account, contractor_id: vendor.id, max_balance: 100_500) }
      let!(:vendor_gateway) {
        create(:gateway,
               contractor_id: vendor.id,
               enabled: true,
               host: vendor_gw_host,
               allow_termination: true,
               term_append_headers_req: vendor_gw_term_append_headers_req,
               diversion_send_mode_id: vendor_gw_diversion_send_mode_id,
               diversion_domain: vendor_gw_diversion_domain,
               diversion_rewrite_rule: vendor_gw_diversion_rewrite_rule,
               diversion_rewrite_result: vendor_gw_diversion_rewrite_result,
               pai_send_mode_id: vendor_gw_pai_send_mode_id,
               pai_domain: vendor_gw_pai_domain,
               registered_aor_mode_id: vendor_gw_registered_aor_mode_id,
               stir_shaken_mode_id: vendor_gw_stir_shaken_mode_id,
               stir_shaken_crt_id: vendor_gw_stir_shaken_crt_id)
      }
      let(:vendor_gw_host) { '1.1.2.3' }
      let(:vendor_gw_term_append_headers_req) { '' }
      let(:vendor_gw_diversion_send_mode_id) { 1 } # do not send
      let(:vendor_gw_diversion_domain) { nil }
      let(:vendor_gw_diversion_rewrite_rule) { nil }
      let(:vendor_gw_diversion_rewrite_result) { nil }

      let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_NO_SEND }
      let(:vendor_gw_pai_domain) { nil }

      let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_NO_USE }

      let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_DISABLE }
      let(:vendor_gw_stir_shaken_crt_id) { nil }

      let!(:customer) { create(:contractor, customer: true, enabled: true) }
      let!(:customer_account) { create(:account, contractor: customer, min_balance: -100_500) }
      let!(:customer_gateway) {
        create(:gateway,
               contractor: customer,
               enabled: true,
               allow_origination: true,
               orig_append_headers_reply: orig_append_headers_reply,
               orig_disconnect_policy_id: orig_disconnect_policy.id)
      }

      let(:orig_disconnect_policy) {
        create(:disconnect_policy)
      }

      let!(:orig_append_headers_reply) { [] }

      let!(:rate_group) { create(:rate_group) }
      let!(:rateplan) { create(:rateplan, rate_groups: [rate_group]) }
      let!(:destination) { create(:destination, prefix: '', enabled: true, rate_group_id: rate_group.id) }

      let!(:routing_group) { create(:routing_group) }
      let!(:routing_plan) {
        create(:routing_plan,
               use_lnp: false,
               routing_groups: [routing_group],
               sorting_id: routing_plan_sorting_id,
               validate_dst_number_format: validate_dst_number_format,
               validate_dst_number_network: validate_dst_number_network,
               validate_src_number_format: validate_src_number_format,
               validate_src_number_network: validate_src_number_network)
      }
      let!(:routing_plan_sorting_id) { 1 }
      let!(:validate_dst_number_format) { false }
      let!(:validate_dst_number_network) { false }
      let!(:validate_src_number_format) { false }
      let!(:validate_src_number_network) { false }

      let!(:dialpeer) {
        create(:dialpeer,
               prefix: '',
               enabled: true,
               routing_group_id: routing_group.id,
               vendor_id: vendor.id,
               account_id: vendor_account.id,
               gateway_id: vendor_gateway.id)
      }

      context 'Authorized, customer auth CPS Limit' do
        let!(:customer_auth_cps_limit) { 10 }

        # calling routing sp 100 times to consume cps limit
        before do
          100.times { routing_sp }
        end

        it 'response with CPS limit' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:disconnect_code_id]).to eq(8012) # CPS Limit
        end
      end

      context 'Authorized, DST numberlist' do
        let!(:nl) {
          create(:numberlist,
                 mode_id: nl_mode,
                 default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                 default_src_rewrite_rule: nl_default_src_rewrite_rule,
                 default_src_rewrite_result: nl_default_src_rewrite_result,
                 defer_src_rewrite: nl_defer_src_rewrite,
                 default_dst_rewrite_rule: nl_default_dst_rewrite_rule,
                 default_dst_rewrite_result: nl_default_dst_rewrite_result,
                 defer_dst_rewrite: nl_defer_dst_rewrite)
        }
        let!(:nl_item) {
          create(:numberlist_item,
                 numberlist_id: nl.id,
                 key: '12345678',
                 action_id: ni_action_id,
                 src_rewrite_rule: ni_src_rewrite_rule,
                 src_rewrite_result: ni_src_rewrite_result,
                 defer_src_rewrite: ni_defer_src_rewrite,
                 dst_rewrite_rule: ni_dst_rewrite_rule,
                 dst_rewrite_result: ni_dst_rewrite_result,
                 defer_dst_rewrite: ni_defer_dst_rewrite)
        }
        let(:ni_action_id) { Routing::NumberlistItem::ACTION_REJECT }
        let(:ni_src_rewrite_rule) { nil }
        let(:ni_src_rewrite_result) { nil }
        let(:ni_defer_src_rewrite) { false }
        let(:ni_dst_rewrite_rule) { nil }
        let(:ni_dst_rewrite_result) { nil }
        let(:ni_defer_dst_rewrite) { false }

        let(:nl_default_src_rewrite_rule) { nil }
        let(:nl_default_src_rewrite_result) { nil }
        let(:nl_defer_src_rewrite) { false }

        let(:nl_default_dst_rewrite_rule) { nil }
        let(:nl_default_dst_rewrite_result) { nil }
        let(:nl_defer_dst_rewrite) { false }

        let(:customer_auth_dst_numberlist_id) { nl.id }

        let(:uri_name) { '12345678' }

        context 'not matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:uri_name) { '122' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).not_to eq(8001)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end

          context 'with default rewrites' do
            let(:nl_default_src_rewrite_rule) { '(.*)' }
            let(:nl_default_src_rewrite_result) { 'src_rewrite_default\1' }

            let(:nl_default_dst_rewrite_rule) { '(.*)' }
            let(:nl_default_dst_rewrite_result) { 'dst_rewrite_default\1' }

            context 'not defered' do
              let(:nl_defer_src_rewrite) { false }
              let(:nl_defer_dst_rewrite) { false }

              it 'not defered rewrite' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:src_prefix_routing]).to eq("src_rewrite_default#{from_name}")
                expect(subject.first[:src_prefix_out]).to eq("src_rewrite_default#{from_name}")
                expect(subject.first[:dst_prefix_routing]).to eq("dst_rewrite_default#{uri_name}")
                expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite_default#{uri_name}")
              end
            end

            context 'defered' do
              let(:nl_defer_src_rewrite) { true }
              let(:nl_defer_dst_rewrite) { true }

              it 'defered rewrite' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:src_prefix_routing]).to eq(from_name)
                expect(subject.first[:src_prefix_out]).to eq("src_rewrite_default#{from_name}")
                expect(subject.first[:dst_prefix_routing]).to eq(uri_name)
                expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite_default#{uri_name}")
              end
            end
          end
        end

        context 'matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8001)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched ITEM in strict mode + rewrites' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:ni_action_id) { Routing::NumberlistItem::ACTION_ACCEPT }

          let(:ni_src_rewrite_rule) { '(.*)' }
          let(:ni_src_rewrite_result) { 'src_rewrite\1' }

          let(:ni_dst_rewrite_rule) { '(.*)' }
          let(:ni_dst_rewrite_result) { 'dst_rewrite\1' }

          context 'not defered' do
            let(:ni_defer_src_rewrite) { false }
            let(:ni_defer_dst_rewrite) { false }

            it 'not defered rewrite' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:src_prefix_routing]).to eq("src_rewrite#{from_name}")
              expect(subject.first[:src_prefix_out]).to eq("src_rewrite#{from_name}")
              expect(subject.first[:dst_prefix_routing]).to eq("dst_rewrite#{uri_name}")
              expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite#{uri_name}")
            end
          end

          context 'defered' do
            let(:ni_defer_src_rewrite) { true }
            let(:ni_defer_dst_rewrite) { true }

            it 'defered rewrite' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:src_prefix_routing]).to eq(from_name)
              expect(subject.first[:src_prefix_out]).to eq("src_rewrite#{from_name}")
              expect(subject.first[:dst_prefix_routing]).to eq(uri_name)
              expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite#{uri_name}")
            end
          end
        end

        context 'matched in prefix mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_PREFIX }
          let(:uri_name) { '123456780000000' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8001)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched in random mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_RANDOM }
          let(:uri_name) { '123456780000000' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8001)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end
      end

      context 'Authorized, SRC numberlist' do
        let!(:nl) {
          create(:numberlist,
                 mode_id: nl_mode,
                 default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                 default_src_rewrite_rule: nl_default_src_rewrite_rule,
                 default_src_rewrite_result: nl_default_src_rewrite_result,
                 defer_src_rewrite: nl_defer_src_rewrite,
                 default_dst_rewrite_rule: nl_default_dst_rewrite_rule,
                 default_dst_rewrite_result: nl_default_dst_rewrite_result,
                 defer_dst_rewrite: nl_defer_dst_rewrite)
        }

        let!(:nl_item) {
          create(:numberlist_item,
                 numberlist_id: nl.id,
                 key: '12345678',
                 action_id: ni_action_id,
                 src_rewrite_rule: ni_src_rewrite_rule,
                 src_rewrite_result: ni_src_rewrite_result,
                 defer_src_rewrite: ni_defer_src_rewrite,
                 dst_rewrite_rule: ni_dst_rewrite_rule,
                 dst_rewrite_result: ni_dst_rewrite_result,
                 defer_dst_rewrite: ni_defer_dst_rewrite)
        }

        let(:ni_action_id) { Routing::NumberlistItem::ACTION_REJECT }
        let(:ni_src_rewrite_rule) { nil }
        let(:ni_src_rewrite_result) { nil }
        let(:ni_defer_src_rewrite) { false }
        let(:ni_dst_rewrite_rule) { nil }
        let(:ni_dst_rewrite_result) { nil }
        let(:ni_defer_dst_rewrite) { false }

        let(:nl_default_src_rewrite_rule) { nil }
        let(:nl_default_src_rewrite_result) { nil }
        let(:nl_defer_src_rewrite) { false }

        let(:nl_default_dst_rewrite_rule) { nil }
        let(:nl_default_dst_rewrite_result) { nil }
        let(:nl_defer_dst_rewrite) { false }

        let(:customer_auth_src_numberlist_id) { nl.id }

        let(:from_name) { '12345678' }

        context 'not matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:from_name) { '122' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).not_to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end

          context 'with default rewrites' do
            let(:nl_default_src_rewrite_rule) { '(.*)' }
            let(:nl_default_src_rewrite_result) { 'src_rewrite_default2\1' }

            let(:nl_default_dst_rewrite_rule) { '(.*)' }
            let(:nl_default_dst_rewrite_result) { 'dst_rewrite_default2\1' }

            context 'not defered' do
              let(:nl_defer_src_rewrite) { false }
              let(:nl_defer_dst_rewrite) { false }

              it 'not defered rewrite' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:src_prefix_routing]).to eq("src_rewrite_default2#{from_name}")
                expect(subject.first[:src_prefix_out]).to eq("src_rewrite_default2#{from_name}")
                expect(subject.first[:dst_prefix_routing]).to eq("dst_rewrite_default2#{uri_name}")
                expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite_default2#{uri_name}")
              end
            end

            context 'defered' do
              let(:nl_defer_src_rewrite) { true }
              let(:nl_defer_dst_rewrite) { true }

              it 'defered rewrite' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:src_prefix_routing]).to eq(from_name)
                expect(subject.first[:src_prefix_out]).to eq("src_rewrite_default2#{from_name}")
                expect(subject.first[:dst_prefix_routing]).to eq(uri_name)
                expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite_default2#{uri_name}")
              end
            end
          end
        end

        context 'matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:src_prefix_out]).to eq(from_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched ITEM in strict mode + rewrites' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:ni_action_id) { Routing::NumberlistItem::ACTION_ACCEPT }

          let(:ni_src_rewrite_rule) { '(.*)' }
          let(:ni_src_rewrite_result) { 'src_rewrite3\1' }

          let(:ni_dst_rewrite_rule) { '(.*)' }
          let(:ni_dst_rewrite_result) { 'dst_rewrite3\1' }

          context 'not defered' do
            let(:ni_defer_src_rewrite) { false }
            let(:ni_defer_dst_rewrite) { false }

            it 'not defered rewrite' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:src_prefix_routing]).to eq("src_rewrite3#{from_name}")
              expect(subject.first[:src_prefix_out]).to eq("src_rewrite3#{from_name}")
              expect(subject.first[:dst_prefix_routing]).to eq("dst_rewrite3#{uri_name}")
              expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite3#{uri_name}")
            end
          end

          context 'defered' do
            let(:ni_defer_src_rewrite) { true }
            let(:ni_defer_dst_rewrite) { true }

            it 'defered rewrite' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:src_prefix_routing]).to eq(from_name)
              expect(subject.first[:src_prefix_out]).to eq("src_rewrite3#{from_name}")
              expect(subject.first[:dst_prefix_routing]).to eq(uri_name)
              expect(subject.first[:dst_prefix_out]).to eq("dst_rewrite3#{uri_name}")
            end
          end
        end

        context 'matched in prefix mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_PREFIX }
          let(:uri_name) { '123456780000000' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:src_prefix_out]).to eq(from_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched in random mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_RANDOM }
          let(:uri_name) { '123456780000000' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:src_prefix_out]).to eq(from_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end
      end

      context 'Authorized, SRC numberlist, fallback to Diversion' do
        let(:customer_auth_src_numberlist_use_diversion) { true }
        let(:customer_auth_diversion_policy_id) { 2 } # accept

        let!(:nl) {
          create(:numberlist, mode_id: nl_mode, default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT)
        }
        let!(:nl_item) {
          create(:numberlist_item,
                 numberlist_id: nl.id,
                 key: '12345678',
                 action_id: Routing::NumberlistItem::ACTION_REJECT)
        }
        let(:customer_auth_src_numberlist_id) { nl.id }

        let(:from_name) { '111111111' } ## not matching
        let(:diversion) { '12345678,111' }

        context 'not matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:from_name) { '122' }
          let(:diversion) { '100500' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).not_to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:src_prefix_out]).to eq(from_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched in prefix mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_PREFIX }
          let(:uri_name) { '123456780000000' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:src_prefix_out]).to eq(from_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end

        context 'matched in random mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_RANDOM }
          let(:uri_name) { '123456780000000' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:src_prefix_out]).to eq(from_name) # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(8002)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end
      end

      context 'Authorized, sorting = 1' do
        let(:routing_plan_sorting_id) { 1 }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, sorting = 2' do
        let(:routing_plan_sorting_id) { 2 }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, sorting = 3' do
        let(:routing_plan_sorting_id) { 3 }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, sorting = 4' do
        let(:routing_plan_sorting_id) { 4 }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, sorting = 5' do
        # routing test require passing vendor id in number
        let(:uri_name) { "#{vendor.id}*uri-name" }

        let(:routing_plan_sorting_id) { 5 }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, sorting = 6' do
        let(:routing_plan_sorting_id) { 6 }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, sorting = 7' do
        let(:routing_plan_sorting_id) { Routing::RoutingPlan::SORTING_STATIC_ONLY_NOCONTROL }
        # this sorting requires additional routing_plan_static_route object
        let!(:routing_plan_static_route) { create(:routing_plan_static_route, routing_plan: routing_plan, vendor: vendor) }
        it 'response OK' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no  Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, send_billing_information enabled, no additional headers' do
        let!(:send_billing_information) { true }
        let!(:orig_append_headers_reply) { [] }
        let!(:expected_headers) {
          [
            "X-VND-INIT-INT:#{dialpeer.initial_interval}",
            "X-VND-NEXT-INT:#{dialpeer.next_interval}",
            "X-VND-INIT-RATE:#{dialpeer.initial_rate}",
            "X-VND-NEXT-RATE:#{dialpeer.next_rate}",
            "X-VND-CF:#{dialpeer.connect_fee}"
          ]
        }

        it 'response with X-VND headers ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no LNP Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination

          expect(subject.first[:aleg_append_headers_reply]).to eq(expected_headers.join('\r\n'))

          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, send_billing_information disabled, no additional headers' do
        let!(:send_billing_information) { false }
        let!(:orig_append_headers_reply) { [] }

        it 'response without X-VND headers ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no LNP Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination

          expect(subject.first[:aleg_append_headers_reply]).to eq(orig_append_headers_reply.join('\r\n'))

          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, send_billing_information disabled, additional headers present' do
        let!(:send_billing_information) { false }
        let!(:orig_append_headers_reply) { ['header1: value1', 'header2: value2'] }

        it 'response without X-VND headers ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no LNP Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination

          expect(subject.first[:aleg_append_headers_reply]).to eq(orig_append_headers_reply.join('\r\n'))

          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, send_billing_information enabled, additional headers present' do
        let!(:send_billing_information) { true }
        let!(:orig_append_headers_reply) { ['header5:value5', 'header6: value7'] }
        let!(:expected_headers) {
          [
            "X-VND-INIT-INT:#{dialpeer.initial_interval}",
            "X-VND-NEXT-INT:#{dialpeer.next_interval}",
            "X-VND-INIT-RATE:#{dialpeer.initial_rate}",
            "X-VND-NEXT-RATE:#{dialpeer.next_rate}",
            "X-VND-CF:#{dialpeer.connect_fee}"
          ] + orig_append_headers_reply
        }

        it 'response with X-VND headers ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil) # no LNP Error
          expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
          expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination

          expect(subject.first[:aleg_append_headers_reply]).to eq(expected_headers.join('\r\n'))

          expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
        end
      end

      context 'Authorized, send_billing_information enabled, Diversion processing' do
        let(:customer_auth_diversion_policy_id) { 2 } # Accept
        let(:customer_auth_diversion_rewrite_rule) { '^\+380(.*)$' } # removing +380
        let(:customer_auth_diversion_rewrite_result) { '\1' }
        let(:diversion) { '+38067689798989,+3800000000' }

        let(:vendor_gw_term_append_headers_req) { '' }
        let(:vendor_gw_diversion_send_mode_id) { 2 } # send Diversion as SIP URI
        let(:vendor_gw_diversion_domain) { 'diversion.com' }
        let(:vendor_gw_diversion_rewrite_rule) { '^(.*)' } # adding 10
        let(:vendor_gw_diversion_rewrite_result) { '10\1' }

        let!(:expected_headers) {
          [
            "Diversion: <sip:1067689798989@#{vendor_gw_diversion_domain}>",
            "Diversion: <sip:100000000@#{vendor_gw_diversion_domain}>"
          ]
        }

        context 'without append headers, SIP ' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:diversion) { '+38067689798989,+3800000000' }

          let!(:expected_headers) {
            [
              "Diversion: <sip:1067689798989@#{vendor_gw_diversion_domain}>",
              "Diversion: <sip:100000000@#{vendor_gw_diversion_domain}>"
            ]
          }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'without append headers, TEL' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:diversion) { '+38067689798989,+3800000001' }
          let(:vendor_gw_diversion_send_mode_id) { 3 } # send Diversion as TEL

          let!(:expected_headers) {
            [
              'Diversion: <tel:1067689798989>',
              'Diversion: <tel:100000001>'
            ]
          }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'without append headers, TEL, NULL diversion' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:diversion) { nil }
          let(:vendor_gw_diversion_send_mode_id) { 3 } # send Diversion as TEL

          it 'response ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'without append headers, TEL, empty diversion' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:diversion) { '' }
          let(:vendor_gw_diversion_send_mode_id) { 3 } # send Diversion as TEL

          it 'response ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'with append headers' do
          let(:vendor_gw_term_append_headers_req) { 'Header5: value5\r\nHeader6: value7' }
          let(:diversion) { '+38067689798989,+3800000000' }
          let!(:expected_headers) {
            [
              "Diversion: <sip:1067689798989@#{vendor_gw_diversion_domain}>",
              "Diversion: <sip:100000000@#{vendor_gw_diversion_domain}>",
              'Header5: value5',
              'Header6: value7'
            ]
          }
          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
      end

      context 'Authorized, PAI send modes' do
        let(:from_name) { '123456789' }

        context 'without append headers, SIP ' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:vendor_gw_pai_send_mode_id) { 2 } # sip URI
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let!(:expected_headers) {
            [
              "P-Asserted-Identity: <sip:123456789@#{vendor_gw_pai_domain}>"
            ]
          }

          let!(:expected_pai_out) {
            [
              "<sip:123456789@#{vendor_gw_pai_domain}>"
            ]
          }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.first[:pai_out]).to eq(expected_pai_out.join(','))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'without append headers, TEL' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:vendor_gw_pai_send_mode_id) { 1 } # tel: URI

          let!(:expected_headers) {
            [
              'P-Asserted-Identity: <tel:123456789>'
            ]
          }

          let!(:expected_pai_out) {
            [
              '<tel:123456789>'
            ]
          }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.first[:pai_out]).to eq(expected_pai_out.join(','))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'with append headers' do
          let(:vendor_gw_term_append_headers_req) { 'Header5: value5\r\nHeader6: value7' }
          let(:vendor_gw_pai_send_mode_id) { 2 } # sip: URI
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let!(:expected_headers) {
            [
              "P-Asserted-Identity: <sip:123456789@#{vendor_gw_pai_domain}>",
              'Header5: value5',
              'Header6: value7'
            ]
          }

          let!(:expected_pai_out) {
            [
              "<sip:123456789@#{vendor_gw_pai_domain}>"
            ]
          }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.first[:pai_out]).to eq(expected_pai_out.join(','))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
      end

      context 'Authorized, registered Aor modes' do
        let(:uri_name) { '+1234567890' }
        let(:vendor_gw_host) { 'pai.test.domain.com' }

        context 'registered aor mode - disable' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_NO_USE }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{vendor_gateway.host}")
            expect(subject.first[:registered_aor_id]).to eq(nil)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_NO_USE)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'registered aor mode - As is' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_AS_IS }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{vendor_gateway.host}")
            expect(subject.first[:registered_aor_id]).to eq(vendor_gateway.id)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_AS_IS)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'registered aor mode - replace userpart' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_REPLACE_USERPART }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{vendor_gateway.host}")
            expect(subject.first[:registered_aor_id]).to eq(vendor_gateway.id)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_REPLACE_USERPART)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
      end

      context 'Authorized, STIR/SHAKEN modes' do

        let(:customer_auth_rewrite_ss_status_id) { CustomersAuth::SS_STATUS_B }

        context 'STIR/SHAKEN mode - disable' do
          let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_DISABLE }

          it 'response without ss' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:ss_crt_id]).to eq(nil)
            expect(subject.first[:ss_otn]).to eq(nil)
            expect(subject.first[:ss_dtn]).to eq(nil)
            expect(subject.first[:legb_ss_status_id]).to eq(nil)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'STIR/SHAKEN mode - insert' do
          let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_INSERT }
          let(:crt) { create(:stir_shaken_signing_certificate) }
          let(:vendor_gw_stir_shaken_crt_id) { crt.id }

          context 'Valid identity on LegA' do
            it 'response without ss' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:ss_crt_id]).to eq(crt.id)
              expect(subject.first[:ss_otn]).to eq(subject.first[:src_prefix_routing])
              expect(subject.first[:ss_dtn]).to eq(subject.first[:dst_prefix_routing])
              expect(subject.first[:ss_attest_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.first[:legb_ss_status_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'Invalid identity on LegA' do
            let(:customer_auth_rewrite_ss_status_id) { CustomersAuth::SS_STATUS_INVALID }
            it 'response without ss' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:ss_crt_id]).to eq(nil)
              expect(subject.first[:ss_otn]).to eq(nil)
              expect(subject.first[:ss_dtn]).to eq(nil)
              expect(subject.first[:ss_attest_id]).to eq(CustomersAuth::SS_STATUS_INVALID)
              expect(subject.first[:legb_ss_status_id]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

        end
      end

      context 'SRC Number format validation enabled' do
        let(:validate_src_number_format) { true }

        context 'Number is valid' do
          let(:from_name) { '3809611111111' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is anonymous(valid)' do
          let(:from_name) { 'anonymous' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is AnonYmous(valid)' do
          let(:from_name) { 'AnonYmous' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is not valid' do
          let(:from_name) { '#%%3809611111111' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8011) # last profile with invalid SRS number format error
          end
        end
      end

      context 'SRC Number network validation enabled' do
        let(:validate_src_number_network) { true }

        context 'Number is valid' do
          let(:from_name) { '3809611111111' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is anonymous(valid)' do
          let(:from_name) { 'anonymous' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is AnonYmous(valid)' do
          let(:from_name) { 'AnonYmous' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is not valid' do
          let(:from_name) { '000003809611111111' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8010) # last profile with invalid SRC number network error
          end
        end
      end

      context 'DST Number format validation enabled' do
        let(:validate_dst_number_format) { true }

        context 'Number is valid' do
          let(:uri_name) { '3809611111111' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is not valid' do
          let(:uri_name) { '#%%3809611111111' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8008) # last profile with invalid DST number format error
          end
        end
      end

      context 'DST Number network validation enabled' do
        let(:validate_dst_number_network) { true }

        context 'Number is valid' do
          let(:uri_name) { '3809611111111' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
        context 'Number is not valid' do
          let(:uri_name) { '000003809611111111' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8007) # last profile with invalid DST number network error
          end
        end
      end
    end
  end

  it_behaves_like 'routing' do
    let(:mode) { 'debug' }
  end

  it_behaves_like 'routing' do
    let(:mode) { 'release' }
  end
end
