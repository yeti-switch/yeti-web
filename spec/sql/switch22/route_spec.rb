# frozen_string_literal: true

RSpec.describe '#routing logic' do
  def routing_sp
    SqlCaller::Yeti.select_all('set search_path to switch22,sys,public')
    SqlCaller::Yeti.select_all_serialized(
      "SELECT * from switch22.route_#{mode}(
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
        ?::varchar, /* interface */
        ?::varchar, /* x_yeti_auth */
        ?::json, /* i_diversion */
        ?::inet, /* i_x_orig_ip */
        ?::integer, /* i_x_orig_port */
        ?::smallint, /* i_x_orig_protocol_id */
        ?::json, /* i_pai */
        ?::json, /* i_ppi */
        ?::varchar, /* i_privacy */
        ?::json, /* i_rpid */
        ?::varchar /* i_rpid_privacy */
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
      i_interface,
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
  let(:i_interface) { 'primary' }
  let(:x_yeti_auth) { nil }
  let(:diversion) {
    '[
    {"h": "domain1", "n": null, "p": 5060, "s": "sip", "u": "user1", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]},
    {"h": "domain2", "n": "test2", "p": 5061, "s": "sip", "u": "user2", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]},
    {"h": "domain3", "n": "test3", "p": 5062, "s": "sips", "u": "user3", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]},
    {"s": "tel", "u": "1234567890"}]'
  }
  let(:x_orig_ip) { '3.3.3.3' }
  let(:x_orig_port) { 6050 }
  let(:x_orig_protocol_id) { 2 }
  let(:pai) {
    '[
    {"h": "domain1", "n": null, "p": 5060, "s": "sip", "u": "user1", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]},
    {"h": "domain2", "n": "test2", "p": 5061, "s": "sip", "u": "user2", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]},
    {"h": "domain3", "n": "test3", "p": 5062, "s": "sips", "u": "user3", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]},
    {"s": "tel", "u": "1234567890"}
  ]'
  }
  let(:ppi) { '{"h": "domain1", "n": null, "p": 5060, "s": "sip", "u": "user1", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]}' }
  let(:privacy) { 'none' }
  let(:rpid) { '[ {"h": "domain1", "n": null, "p": 5060, "s": "sip", "u": "user1", "np_arr": ["nparam1:nval1"], "uh_arr": ["uhdr1:uhval1"], "up_arr": ["uparam1:uval11","uparam2:uval12"]}]' }
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
        expect(subject.first[:customer_auth_external_id]).to eq customer_auth.external_id
        expect(subject.first[:customer_auth_external_type]).to eq customer_auth.external_type
      end

      context 'when customer_auth external_id and external_type is null' do
        let(:customer_auth_attrs) do
          super().merge external_id: nil, external_type: nil
        end

        it 'return 404 ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to eq(customer_auth.id)
          expect(subject.first[:customer_auth_external_id]).to be_nil
          expect(subject.first[:customer_auth_external_type]).to be_nil
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

    context 'Authentification by username/password' do
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
          expect(subject.first[:customer_auth_external_id]).to eq(@ca.external_id)
          expect(subject.first[:customer_auth_external_type]).to eq(@ca.external_type)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance
        end

        context 'when customer_auth external_id and external_type is null' do
          let(:ca_attrs) do
            super().merge external_id: nil, external_type: nil
          end

          it 'Pass auth' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to eq(@ca.id)
            expect(subject.first[:customer_auth_external_id]).to be_nil
            expect(subject.first[:customer_auth_external_type]).to be_nil
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
          expect(subject.first[:customer_auth_external_id]).to eq(@ca.external_id)
          expect(subject.first[:customer_auth_external_type]).to eq(@ca.external_type)
          expect(subject.first[:customer_auth_name]).to eq(@ca.name)

          expect(subject.first[:customer_id]).to eq(@ca.customer_id)
          expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
          expect(subject.first[:customer_name]).to eq(@ca.customer.name)

          expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
          expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
          expect(subject.first[:customer_account_name]).to eq(@ca.account.name)

          expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
          expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
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
        expect(subject.first[:customer_auth_external_id]).to eq(@ca.external_id)
        expect(subject.first[:customer_auth_external_type]).to eq(@ca.external_type)
        expect(subject.first[:customer_auth_name]).to eq(@ca.name)

        expect(subject.first[:customer_id]).to eq(@ca.customer_id)
        expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
        expect(subject.first[:customer_name]).to eq(@ca.customer.name)

        expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
        expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
        expect(subject.first[:customer_account_name]).to eq(@ca.account.name)

        expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
        expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
      end

      context 'when customer_auth has external_id and external_type are null' do
        let(:ca_attrs) do
          super().merge external_id: nil, external_type: nil
        end

        it 'Reject' do
          expect(subject.size).to eq(1)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

          expect(subject.first[:customer_auth_id]).to eq(@ca.id)
          expect(subject.first[:customer_auth_external_id]).to be_nil
          expect(subject.first[:customer_auth_external_type]).to be_nil
          expect(subject.first[:customer_auth_name]).to eq(@ca.name)

          expect(subject.first[:customer_id]).to eq(@ca.customer_id)
          expect(subject.first[:customer_external_id]).to eq(@ca.customer.external_id)
          expect(subject.first[:customer_name]).to eq(@ca.customer.name)

          expect(subject.first[:customer_acc_id]).to eq(@ca.account_id)
          expect(subject.first[:customer_acc_external_id]).to eq(@ca.account.external_id)
          expect(subject.first[:customer_account_name]).to eq(@ca.account.name)

          expect(subject.first[:rateplan_id]).to eq(@ca.rateplan_id)
          expect(subject.first[:routing_plan_id]).to eq(@ca.routing_plan_id)
        end
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
                          interface: customer_auth_interface,
                          reject_calls: customer_auth_reject_calls,
                          require_incoming_auth: customer_auth_require_incoming_auth,
                          check_account_balance: customer_auth_check_account_balance,
                          customer: customer,
                          account: customer_account,
                          gateway: customer_gateway,
                          rateplan_id: rateplan.id,
                          routing_plan_id: routing_plan.id,
                          send_billing_information: send_billing_information,
                          diversion_policy_id: customer_auth_diversion_policy_id,
                          diversion_rewrite_rule: customer_auth_diversion_rewrite_rule,
                          diversion_rewrite_result: customer_auth_diversion_rewrite_result,
                          pai_policy_id: customer_auth_pai_policy_id,
                          pai_rewrite_rule: customer_auth_pai_rewrite_rule,
                          pai_rewrite_result: customer_auth_pai_rewrite_result,
                          cps_limit: customer_auth_cps_limit,
                          src_numberlist_id: customer_auth_src_numberlist_id,
                          dst_numberlist_id: customer_auth_dst_numberlist_id,
                          dump_level_id: customer_auth_dump_level,
                          src_numberlist_use_diversion: customer_auth_src_numberlist_use_diversion,
                          rewrite_ss_status_id: customer_auth_rewrite_ss_status_id,
                          ss_mode_id: customer_auth_ss_mode_id,
                          ss_no_identity_action_id: customer_auth_ss_no_identity_action_id,
                          ss_invalid_identity_action_id: customer_auth_ss_invalid_identity_action_id,
                          ss_src_rewrite_rule: customer_auth_ss_src_rewrite_rule,
                          ss_src_rewrite_result: customer_auth_ss_src_rewrite_result,
                          ss_dst_rewrite_rule: customer_auth_ss_dst_rewrite_rule,
                          ss_dst_rewrite_result: customer_auth_ss_dst_rewrite_result,
                          stir_shaken_crt_id: customer_auth_stir_shaken_crt_id,
                          privacy_mode_id: customer_auth_privacy_mode_id,
                          src_name_field_id: customer_auth_src_name_field_id,
                          src_number_field_id: customer_auth_src_number_field_id,
                          variables: customer_auth_variables)
      end

      let!(:customer_auth_check_account_balance) { true }
      let!(:send_billing_information) { false }
      let(:customer_auth_interface) { [] }
      let(:customer_auth_reject_calls) { false }
      let(:customer_auth_require_incoming_auth) { false }
      let(:customer_auth_diversion_policy_id) { CustomersAuth::DIVERSION_POLICY_NOT_ACCEPT }
      let(:customer_auth_diversion_rewrite_rule) { nil } # removing +380
      let(:customer_auth_diversion_rewrite_result) { nil }
      let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_NOT_ACCEPT }
      let(:customer_auth_pai_rewrite_rule) { nil }
      let(:customer_auth_pai_rewrite_result) { nil }
      let(:customer_auth_cps_limit) { nil }
      let(:customer_auth_src_numberlist_id) { nil }
      let(:customer_auth_dst_numberlist_id) { nil }
      let(:customer_auth_dump_level) { CustomersAuth::DUMP_LEVEL_CAPTURE_SIP }
      let(:customer_auth_src_numberlist_use_diversion) { false }
      let(:customer_auth_rewrite_ss_status_id) { nil }
      let(:customer_auth_ss_mode_id) { CustomersAuth::SS_MODE_DISABLE }
      let(:customer_auth_ss_no_identity_action_id) { CustomersAuth::SS_NO_IDENTITY_ACTION_NOTHING }
      let(:customer_auth_ss_invalid_identity_action_id) { CustomersAuth::SS_INVALID_IDENTITY_ACTION_NOTHING }

      let(:customer_auth_ss_src_rewrite_rule) { nil }
      let(:customer_auth_ss_src_rewrite_result) { nil }
      let(:customer_auth_ss_dst_rewrite_rule) { nil }
      let(:customer_auth_ss_dst_rewrite_result) { nil }
      let(:customer_auth_stir_shaken_crt_id) { nil }
      let(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_REJECT_ANONYMOUS }
      let(:customer_auth_src_name_field_id) { CustomersAuth::SRC_NAME_FIELD_FROM_DSP }
      let(:customer_auth_src_number_field_id) { CustomersAuth::SRC_NUMBER_FIELD_FROM_USERPART }
      let(:customer_auth_variables) { {} }

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }
      let!(:vendor) { create(:contractor, vendor: true, enabled: true) }
      let!(:vendor_account) { create(:account, contractor_id: vendor.id, max_balance: 100_500) }
      let!(:vendor_gateway_group) {
        create(:gateway_group, vendor_id: vendor.id, balancing_mode_id: vendor_gateway_group_balancing_mode_id)
      }
      let(:vendor_gateway_group_balancing_mode_id) { GatewayGroup::BALANCING_MODE_PRIO_WEIGHT }

      let!(:vendor_gateway) {
        create(:gateway,
               contractor_id: vendor.id,
               gateway_group_id: vendor_gateway_group.id,
               enabled: true,
               sip_schema_id: vendor_gw_sip_schema_id,
               host: vendor_gw_host,
               port: vendor_gw_port,
               allow_termination: true,
               termination_capacity: vendor_gw_termination_capacity,
               termination_subscriber_capacity: vendor_gw_termination_subscriber_capacity,
               termination_cps_limit: vendor_gw_termination_cps_limit,
               termination_cps_wsize: vendor_gw_termination_cps_wsize,
               termination_subscriber_cps_limit: vendor_gw_termination_subscriber_cps_limit,
               termination_subscriber_cps_wsize: vendor_gw_termination_subscriber_cps_wsize,
               termination_dst_numberlist_id: vendor_gw_dst_numberlist_id,
               termination_src_numberlist_id: vendor_gw_src_numberlist_id,
               term_append_headers_req: vendor_gw_term_append_headers_req,
               diversion_send_mode_id: vendor_gw_diversion_send_mode_id,
               diversion_domain: vendor_gw_diversion_domain,
               diversion_rewrite_rule: vendor_gw_diversion_rewrite_rule,
               diversion_rewrite_result: vendor_gw_diversion_rewrite_result,
               dst_rewrite_rule: vendor_gw_dst_rewrite_rule,
               dst_rewrite_result: vendor_gw_dst_rewrite_result,
               to_rewrite_rule: vendor_gw_to_rewrite_rule,
               to_rewrite_result: vendor_gw_to_rewrite_result,
               pai_send_mode_id: vendor_gw_pai_send_mode_id,
               pai_domain: vendor_gw_pai_domain,
               registered_aor_mode_id: vendor_gw_registered_aor_mode_id,
               stir_shaken_mode_id: vendor_gw_stir_shaken_mode_id,
               stir_shaken_crt_id: vendor_gw_stir_shaken_crt_id,
               send_lnp_information: vendor_gw_send_lnp_information,
               privacy_mode_id: vendor_gw_privacy_mode_id,
               contact_user: vendor_gw_contact_user)
      }
      let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
      let(:vendor_gw_sip_schema_id) { Gateway::SIP_SCHEMA_SIP }
      let(:vendor_gw_host) { '1.1.2.3' }
      let(:vendor_gw_port) { nil }
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

      let(:vendor_gw_dst_rewrite_rule) { nil }
      let(:vendor_gw_dst_rewrite_result) { nil }
      let(:vendor_gw_to_rewrite_rule) { nil }
      let(:vendor_gw_to_rewrite_result) { nil }

      let(:vendor_gw_send_lnp_information) { false }

      let(:vendor_gw_termination_capacity) { nil }
      let(:vendor_gw_termination_subscriber_capacity) { nil }
      let(:vendor_gw_termination_cps_limit) { nil }
      let(:vendor_gw_termination_cps_wsize) { 1 }
      let(:vendor_gw_termination_subscriber_cps_limit) { nil }
      let(:vendor_gw_termination_subscriber_cps_wsize) { 1 }
      let(:vendor_gw_src_numberlist_id) { nil }
      let(:vendor_gw_dst_numberlist_id) { nil }
      let(:vendor_gw_contact_user) { nil }

      let!(:customer) { create(:contractor, customer: true, enabled: true) }
      let!(:customer_account) {
        create(:account,
               contractor: customer,
               destination_rate_limit: customer_account_destination_rate_limit,
               min_balance: customer_account_min_balance,
               balance: customer_account_balance)
      }

      let!(:customer_account_min_balance) { -100_500 }
      let!(:customer_account_balance) { 0 }
      let!(:customer_account_destination_rate_limit) { nil }

      let!(:customer_gateway) {
        create(:gateway,
               contractor: customer,
               enabled: customer_gw_enabled,
               allow_origination: true,
               orig_append_headers_reply: orig_append_headers_reply,
               orig_append_headers_req: orig_append_headers_req,
               orig_disconnect_policy_id: orig_disconnect_policy.id,
               incoming_auth_username: customer_gw_incoming_auth_username,
               incoming_auth_password: customer_gw_incoming_auth_password,
               contact_user: customer_gw_contact_user)
      }

      let(:customer_gw_enabled) { true }
      let(:customer_gw_incoming_auth_username) { nil }
      let(:customer_gw_incoming_auth_password) { nil }
      let(:customer_gw_contact_user) { nil }

      let(:orig_disconnect_policy) {
        create(:disconnect_policy)
      }

      let!(:orig_append_headers_reply) { [] }
      let!(:orig_append_headers_req) { [] }

      let!(:rate_group) { create(:rate_group) }
      let!(:rateplan) { create(:rateplan, rate_groups: [rate_group]) }
      let!(:destination) {
        create(:destination,
                                  prefix: '',
                                  enabled: true,
                                  initial_interval: destination_initial_interval,
                                  next_interval: destination_next_interval,
                                  initial_rate: destination_rate,
                                  next_rate: destination_rate,
                                  rate_group_id: rate_group.id,
                                  allow_package_billing: destination_allow_package_billing)
      }
      let!(:destination_allow_package_billing) { false }
      let!(:destination_rate) { 0.11 }
      let!(:destination_initial_interval) { 1 }
      let!(:destination_next_interval) { 1 }

      let!(:routing_group) { create(:routing_group) }
      let!(:routing_plan) {
        create(:routing_plan,
               use_lnp: false,
               routing_groups: [routing_group],
               sorting_id: routing_plan_sorting_id,
               validate_dst_number_format: validate_dst_number_format,
               validate_dst_number_network: validate_dst_number_network,
               validate_src_number_format: validate_src_number_format,
               validate_src_number_network: validate_src_number_network,
               dst_numberlist_id: routing_plan_dst_numberlist_id,
               src_numberlist_id: routing_plan_src_numberlist_id)
      }
      let!(:routing_plan_sorting_id) { 1 }
      let!(:validate_dst_number_format) { false }
      let!(:validate_dst_number_network) { false }
      let!(:validate_src_number_format) { false }
      let!(:validate_src_number_network) { false }
      let!(:routing_plan_dst_numberlist_id) { nil }
      let!(:routing_plan_src_numberlist_id) { nil }

      let!(:dialpeer) {
        create(:dialpeer,
               prefix: '',
               enabled: true,
               routing_group_id: routing_group.id,
               vendor_id: vendor.id,
               account_id: vendor_account.id,
               gateway_id: dialpeer_gateway_id,
               gateway_group_id: dialpeer_gateway_group_id)
      }

      let(:dialpeer_gateway_id) { vendor_gateway.id }
      let(:dialpeer_gateway_group_id) { nil }

      # we are creating sampling rule to match all traffic there
      # to be sure routing will not crash when sampling rule matched.
      let!(:traffic_sampling_rule) {
        create(:traffic_sampling_rule,
               customer_id: nil,
               customers_auth_id: nil,
               dump_rate: traffic_sampling_rule_dump_rate,
               dump_level_id: traffic_sampling_rule_dump_level_id,
               recording_rate: traffic_sampling_rule_recording_rate)
      }

      let!(:traffic_sampling_rule_dump_rate) { 100 }
      let!(:traffic_sampling_rule_dump_level_id) { Routing::TrafficSamplingRule::DUMP_LEVEL_CAPTURE_ALL }
      let!(:traffic_sampling_rule_recording_rate) { 100 }

      context 'Authorized by IP, checking interface' do
        let!(:i_interface) { 'secondary' }

        let!(:customer_auth_reject_calls) { true }

        context 'When CA interface is empty' do
          let!(:customer_auth_interface) { [] }
          it 'authorizes call' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_CUSTOMER_AUTH_REJECT)
          end
        end

        context 'When CA interface same as routing interface' do
          let!(:customer_auth_interface) { ['secondary'] }
          it 'authorizes call' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_CUSTOMER_AUTH_REJECT) # reject by customer auth
          end
        end

        context 'When CA interface includes routing interface' do
          let!(:customer_auth_interface) { %w[primary secondary] }
          it 'authorizes call' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_CUSTOMER_AUTH_REJECT)
          end
        end

        context 'When CA interface not includes routing interface' do
          let!(:customer_auth_interface) { %w[primary1 secondary2] }
          it 'CA lookup failed' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be_nil
            expect(subject.first[:customer_id]).to be_nil
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_CUSTOMER_AUTH_MATCHED)
          end
        end
      end

      context 'Authorized by IP + username/password, checking interface' do
        let!(:i_interface) { 'secondary' }

        let!(:customer_auth_reject_calls) { true }
        let(:customer_auth_require_incoming_auth) { true }
        let(:customer_gw_incoming_auth_username) { 'test-user' }
        let(:customer_gw_incoming_auth_password) { 'test-password' }
        let(:auth_id) { customer_gateway.id }

        context 'When CA interface is empty' do
          let!(:customer_auth_interface) { [] }
          it 'authorizes call' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_CUSTOMER_AUTH_REJECT)
          end
        end

        context 'When CA interface same as routing interface' do
          let!(:customer_auth_interface) { ['secondary'] }
          it 'authorizes call' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_CUSTOMER_AUTH_REJECT) # reject by customer auth
          end
        end

        context 'When CA interface includes routing interface' do
          let!(:customer_auth_interface) { %w[primary secondary] }
          it 'authorizes call' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_CUSTOMER_AUTH_REJECT)
          end
        end

        context 'When CA interface not includes routing interface' do
          let!(:customer_auth_interface) { %w[primary1 secondary2] }
          it 'CA lookup failed' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be_nil
            expect(subject.first[:customer_id]).to be_nil
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_CUSTOMER_AUTH_MATCHED)
          end
        end
      end

      context 'Authorized, customer auth CPS Limit' do
        let!(:customer_auth_cps_limit) { 5 }

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

      context 'Authorized, orig gw disabled' do
        let!(:customer_gw_enabled) { false }

        it 'reject ' do
          expect(subject.size).to eq(1) # reject before routing. there will be only one profile
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:customer_acc_id]).to eq(customer_account.id)
          expect(subject.first[:customer_acc_external_id]).to eq(customer_account.external_id)
          expect(subject.first[:orig_gw_id]).to eq(customer_gateway.id)
          expect(subject.first[:disconnect_code_id]).to eq(8005) # Orig gw disabled
        end
      end

      context 'Authorized, privacy policy reject' do
        let!(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_REJECT }
        let!(:privacy) { 'id' }

        it 'reject ' do
          expect(subject.size).to eq(1) # reject before routing. there will be only one profile
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:customer_acc_id]).to eq(customer_account.id)
          expect(subject.first[:customer_acc_external_id]).to eq(customer_account.external_id)
          expect(subject.first[:orig_gw_id]).to eq(customer_gateway.id)
          expect(subject.first[:disconnect_code_id]).to eq(8013)
        end
      end

      context 'Authorized, privacy policy reject critical' do
        let!(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_REJECT_CRITICAL }
        let!(:privacy) { 'id;critical' }

        it 'reject ' do
          expect(subject.size).to eq(1) # reject before routing. there will be only one profile
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:customer_acc_id]).to eq(customer_account.id)
          expect(subject.first[:customer_acc_external_id]).to eq(customer_account.external_id)
          expect(subject.first[:orig_gw_id]).to eq(customer_gateway.id)
          expect(subject.first[:disconnect_code_id]).to eq(8014)
        end
      end

      context 'Authorized, privacy policy reject anonymous' do
        let!(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_REJECT_ANONYMOUS }
        let!(:from_name) { 'anonymous' }
        let!(:pai) { nil }
        let!(:ppi) { nil }
        # let!(:privacy) { 'id;critical' }

        it 'reject ' do
          expect(subject.size).to eq(1) # reject before routing. there will be only one profile
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:customer_acc_id]).to eq(customer_account.id)
          expect(subject.first[:customer_acc_external_id]).to eq(customer_account.external_id)
          expect(subject.first[:orig_gw_id]).to eq(customer_gateway.id)
          expect(subject.first[:disconnect_code_id]).to eq(8015)
        end
      end

      context 'Authorized, privacy policy Allow all' do
        let!(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_ALLOW }
        let!(:from_name) { 'anonymous' }
        let!(:privacy) { 'id;critical' }

        it 'not reject ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:aleg_auth_required]).to be_nil
        end
      end

      context 'Authorized, Customer has no enough balance' do
        let!(:customer_auth_check_account_balance) { true }
        let!(:customer_account_min_balance) { 0 }
        let!(:customer_account_balance) { -10_000_000 }

        it 'reject ' do
          expect(subject.size).to eq(1) # reject before routing. there will be only one profile
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance
        end
      end

      context 'Authorized, Customer has no enough balance for first billing interval' do
        let!(:customer_auth_check_account_balance) { true }
        let!(:customer_account_min_balance) { 0 }
        let!(:customer_account_balance) { 0.00001 }
        let!(:destination_rate) { 1.0 }

        it 'reject ' do
          expect(subject.size).to eq(2) # reject after routing
          expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_ENOUGH_CUSTOMER_BALANCE)
          expect(subject.second[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_ROUTES)
        end
      end

      context 'Authorized, Customer has enough balance. Checking time limit' do
        let!(:customer_auth_check_account_balance) { true }
        let!(:customer_account_min_balance) { 0 }
        let!(:customer_account_balance) { 60 }

        let!(:destination_rate) { 3.0 }
        let!(:destination_initial_interval) { 1.0 }
        let!(:destination_next_interval) { 1.0 }

        it 'routing OK ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:disconnect_code_id]).to eq(nil)
          expect(subject.first[:destination_initial_rate]).to eq(destination_rate)
          expect(subject.first[:time_limit]).to eq(1200)
          expect(subject.second[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_ROUTES)
        end
      end

      context 'Authorized, Customer has no enough balance, Balance checking disabled' do
        let!(:customer_auth_check_account_balance) { false }
        let!(:customer_account_min_balance) { 0 }
        let!(:customer_account_balance) { -1_000_000 }

        it 'routing OK ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil)
        end
      end

      context 'Authorized, Call terminated to GW group' do
        let!(:dialpeer_gateway_id) { nil }
        let!(:dialpeer_gateway_group_id) { vendor_gateway_group.id }

        # we are checking our routing procedure not crashing for all balancing modes.
        # there is no real check of balancing modes logic there
        GatewayGroup::BALANCING_MODES.each_key do |bm|
          context "Balancing mode #{bm}" do
            let!(:vendor_gateway_group_balancing_mode_id) { bm }
            it 'routing OK ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:term_gw_id]).to eq(vendor_gateway.id)
              expect(subject.first[:disconnect_code_id]).to eq(nil)
            end
          end
        end
      end

      context 'Authorized, Src name field' do
        let(:from_dsp) { 'from_display_name' }
        let(:from_name) { 'from_username' }

        context 'From Display name' do
          let!(:customer_auth_src_name_field_id) { CustomersAuth::SRC_NAME_FIELD_FROM_DSP }
          it 'routing OK ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:src_name_in]).to eq('from_display_name')
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end

        context 'From Userpart' do
          let!(:customer_auth_src_name_field_id) { CustomersAuth::SRC_NAME_FIELD_FROM_USERPART }
          it 'routing OK ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:src_name_in]).to eq('from_username')
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end
      end

      context 'Authorized, Src number field' do
        let(:from_dsp) { 'from_display_name' }
        let(:from_name) { 'from_username' }
        let(:uri_name) { 'ruri_username' }
        let(:to_name) { 'to_username' }

        context 'From User part' do
          let!(:customer_auth_src_number_field_id) { CustomersAuth::SRC_NUMBER_FIELD_FROM_USERPART }
          it 'routing OK ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:src_prefix_in]).to eq('from_username')
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end

        context 'From display name' do
          let!(:customer_auth_src_number_field_id) { CustomersAuth::SRC_NUMBER_FIELD_FROM_DSP }
          it 'routing OK ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:src_prefix_in]).to eq('from_display_name')
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end

        context 'R-URI User part' do
          let!(:customer_auth_src_number_field_id) { CustomersAuth::SRC_NUMBER_FIELD_RURI_USERPART }
          it 'routing OK ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:src_prefix_in]).to eq('ruri_username')
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end

        context 'To User part' do
          let!(:customer_auth_src_number_field_id) { CustomersAuth::SRC_NUMBER_FIELD_TO_USERPART }
          it 'routing OK ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:src_prefix_in]).to eq('to_username')
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end
      end

      context 'Authorized, no destination by max_destination_rate limit' do
        let!(:destination_rate) { 0.11 }
        let!(:customer_account_destination_rate_limit) { 0.11 }

        it 'Routing OK ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil)
        end

        context 'account dst rate limit too low' do
          let!(:customer_account_destination_rate_limit) { 0.1 }

          it 'No destination found' do
            expect(subject.size).to eq(1)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_DESTINATION_WITH_APPROPRIATE_RATE)
          end
        end
      end

      context 'Authorized, destination and package billing' do
        let!(:destination_rate) { 0.11 }
        let!(:customer_account_destination_rate_limit) { 0.11 }

        before do
          create(:billing_package_counter,
                 account_id: customer_account.id,
                 duration: 48,
                 prefix: '')
        end

        it 'Routing OK without package ' do
          expect(subject.size).to eq(2)
          expect(subject.first[:customer_auth_id]).to be
          expect(subject.first[:customer_id]).to be
          expect(subject.first[:destination_id]).to be
          expect(subject.first[:destination_prefix]).to be
          expect(subject.first[:destination_initial_rate]).to be
          expect(subject.first[:destination_next_rate]).to be
          expect(subject.first[:destination_initial_interval]).to be
          expect(subject.first[:destination_next_interval]).to be
          expect(subject.first[:disconnect_code_id]).to eq(nil)
        end

        context 'More specific package counter' do
          let!(:destination_allow_package_billing) { true }
          before do
            create(:billing_package_counter,
                   account_id: customer_account.id,
                   duration: 480,
                   prefix: 'uri-name',
                   exclude: false)
          end

          it 'Destination found' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:destination_id]).to be
            expect(subject.first[:destination_prefix]).to be
            expect(subject.first[:destination_initial_rate]).to eq(nil)
            expect(subject.first[:destination_next_rate]).to eq(nil)
            expect(subject.first[:destination_initial_interval]).to be
            expect(subject.first[:destination_next_interval]).to be
            expect(subject.first[:package_counter_id]).to be
            expect(subject.first[:time_limit]).to eq(480)
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end
        context 'More specific, excluded package counter' do
          let!(:destination_allow_package_billing) { true }
          before do
            create(:billing_package_counter,
                   account_id: customer_account.id,
                   duration: 480,
                   prefix: 'uri-name',
                   exclude: true)
          end

          it 'Destination found' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:destination_id]).to be
            expect(subject.first[:destination_prefix]).to be
            expect(subject.first[:destination_initial_rate]).to be
            expect(subject.first[:destination_next_rate]).to be
            expect(subject.first[:destination_initial_interval]).to be
            expect(subject.first[:destination_next_interval]).to be
            expect(subject.first[:package_counter_id]).to eq(nil)
            expect(subject.first[:disconnect_code_id]).to eq(nil)
          end
        end
      end

      context 'Authorized, CustomerAuth DST numberlist' do
        let!(:traffic_sampling_rule_dump_rate) { 0 }
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

      context 'Authorized, CustomerAuth SRC numberlist' do
        let!(:traffic_sampling_rule_dump_rate) { 0 }
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

      context 'Authorized, CustomerAuth SRC numberlist, fallback to Diversion' do
        let!(:traffic_sampling_rule_dump_rate) { 0 }
        let(:customer_auth_src_numberlist_use_diversion) { true }
        let(:customer_auth_diversion_policy_id) { CustomersAuth::DIVERSION_POLICY_ACCEPT }

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
        let(:diversion) {
          '[
          {"s": "sip", "n": "name1", "u": "12345678", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
          {"s": "sip", "n": "name2", "u": "111", "h": "domain2", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}
        ]'
        }

        context 'not matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:from_name) { '122' }
          let(:diversion) { '[{"s": "sip", "n": "name1", "u": "100500", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}]' }

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

      context 'Authorized, RoutingPlan DST numberlist' do
        let!(:traffic_sampling_rule_dump_rate) { 0 }
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

        let(:routing_plan_dst_numberlist_id) { nl.id }

        let(:uri_name) { '12345678' }

        context 'not matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:uri_name) { '122' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).not_to eq(8016)
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
            expect(subject.first[:disconnect_code_id]).to eq(8016)
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
            expect(subject.first[:disconnect_code_id]).to eq(8016)
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
            expect(subject.first[:disconnect_code_id]).to eq(8016)
            expect(subject.first[:aleg_policy_id]).to eq(orig_disconnect_policy.id) # disconnect policy should be applied
            expect(subject.first[:dump_level_id]).to eq(customer_auth_dump_level)
          end
        end
      end

      context 'Authorized, RoutingPlan SRC numberlist' do
        let!(:traffic_sampling_rule_dump_rate) { 0 }
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

        let(:routing_plan_src_numberlist_id) { nl.id }

        let(:from_name) { '12345678' }

        context 'not matched in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:from_name) { '122' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:routing_plan_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:disconnect_code_id]).not_to eq(8017)
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
            expect(subject.first[:disconnect_code_id]).to eq(8017)
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
            expect(subject.first[:disconnect_code_id]).to eq(8017)
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
            expect(subject.first[:disconnect_code_id]).to eq(8017)
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
          expect(subject.second[:disconnect_code_id]).to eq(DisconnectCode::DC_NO_ROUTES) # last profile with route not found error
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
        let(:customer_auth_diversion_policy_id) { CustomersAuth::DIVERSION_POLICY_ACCEPT }
        let(:customer_auth_diversion_rewrite_rule) { '^\+380(.*)$' } # removing +380
        let(:customer_auth_diversion_rewrite_result) { '\1' }
        let(:diversion) {
          '[
          {"s": "sip", "n": "name1", "u": "+38067689798989", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
          {"s": "sip", "n": "name2", "u": "+3800000000", "h": "domain2", "p": 5062, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}
        ]'
        }

        let(:vendor_gw_term_append_headers_req) { '' }
        let(:vendor_gw_diversion_send_mode_id) { 2 } # send Diversion as SIP URI
        let(:vendor_gw_diversion_domain) { 'diversion.com' }
        let(:vendor_gw_diversion_rewrite_rule) { '^(.*)' } # adding 10
        let(:vendor_gw_diversion_rewrite_result) { '10\1' }

        let!(:expected_headers) {
          [
            "Diversion: \"name1\" <sip:1067689798989@#{vendor_gw_diversion_domain}:5060;uparam1=uval11;uparam2=uval12>;nparam1=nval1",
            "Diversion: \"name2\" <sip:100000000@#{vendor_gw_diversion_domain}:5062;uparam1=uval11;uparam2=uval12>;nparam1=nval1"
          ]
        }

        context 'without append headers, SIP ' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:diversion) {
            '[
            {"s": "sip", "n": "name1", "u": "+38067689798989", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "sip", "n": "name2", "u": "+3800000000", "h": "domain2", "p": 5062, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}
          ]'
          }

          let!(:expected_headers) {
            [
              "Diversion: \"name1\" <sip:1067689798989@#{vendor_gw_diversion_domain}:5060;uparam1=uval11;uparam2=uval12>;nparam1=nval1",
              "Diversion: \"name2\" <sip:100000000@#{vendor_gw_diversion_domain}:5062;uparam1=uval11;uparam2=uval12>;nparam1=nval1"
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
          let(:diversion) {
            '[
            {"s": "sip", "n": "name1", "u": "+38067689798989", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "sip", "n": "name2", "u": "+3800000001", "h": "domain2", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}
          ]'
          }

          let(:vendor_gw_diversion_send_mode_id) { 3 } # send Diversion as TEL

          let!(:expected_headers) {
            [
              'Diversion: <tel:1067689798989;uparam1=uval11;uparam2=uval12>;nparam1=nval1',
              'Diversion: <tel:100000001;uparam1=uval11;uparam2=uval12>;nparam1=nval1'
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

        context 'without append headers, TEL, No Diversion headers' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:diversion) { '[]' }
          let(:vendor_gw_diversion_send_mode_id) { 3 } # send Diversion as TEL

          let!(:expected_headers) { [] }

          it 'response ' do
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

        context 'with append headers' do
          let(:vendor_gw_term_append_headers_req) { 'Header5: value5\r\nHeader6: value7' }
          let(:diversion) {
            '[
            {"s": "sip", "n": "name1", "u": "+38067689798989", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "sip", "n": "name2", "u": "+3800000000", "h": "domain2", "p": 5062, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}
          ]'
          }

          let!(:expected_headers) {
            [
              "Diversion: \"name1\" <sip:1067689798989@#{vendor_gw_diversion_domain}:5060;uparam1=uval11;uparam2=uval12>;nparam1=nval1",
              "Diversion: \"name2\" <sip:100000000@#{vendor_gw_diversion_domain}:5062;uparam1=uval11;uparam2=uval12>;nparam1=nval1",
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

      context 'Authorized, PAI processing' do
        let(:from_name) { '123456789' }

        context 'Customer Auth PAI Policy, PAI present' do
          # we testing there only PAI processing in customer auth.
          # we will use trm gw pai_send_mode_relay  SIP for tests
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) {
            '[
            {"s": "sip", "n": "name1", "u": null, "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "sip", "n": "name2", "u": "", "h": "domain2", "p": 5062, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "sip", "n": "name3", "u": "+3800000000", "h": "domain2", "p": 5062, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}
          ]'
          }

          let(:ppi) {
            '{"s": "sip", "n": "name1", "u": "+38067689798989", "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}'
          }

          context 'Not accepted' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_NOT_ACCEPT }

            let!(:expected_headers) { [] }

            it 'response with PAI headers ' do
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

          context 'Accepted' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }

            let!(:expected_headers) {
              [
                'P-Asserted-Identity: "name3" <sip:+3800000000@domain2:5062;uparam1=uval11;uparam2=uval12>;nparam1=nval1',
                'P-Preferred-Identity: "name1" <sip:+38067689798989@domain1:5060;uparam1=uval11;uparam2=uval12>;nparam1=nval1'
              ]
            }

            it 'response with PAI headers ' do
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

          context 'Accepted with rewrite' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
            let(:customer_auth_pai_rewrite_rule) { '^\+380(.*)$' }
            let(:customer_auth_pai_rewrite_result) { '123\1' }

            let!(:expected_headers) {
              [
                'P-Asserted-Identity: "name3" <sip:1230000000@domain2:5062;uparam1=uval11;uparam2=uval12>;nparam1=nval1',
                'P-Preferred-Identity: "name1" <sip:12367689798989@domain1:5060;uparam1=uval11;uparam2=uval12>;nparam1=nval1'
              ]
            }

            it 'response with PAI headers ' do
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

          context 'Required' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_REQUIRE }

            let!(:expected_headers) {
              [
                'P-Asserted-Identity: "name3" <sip:+3800000000@domain2:5062;uparam1=uval11;uparam2=uval12>;nparam1=nval1',
                'P-Preferred-Identity: "name1" <sip:+38067689798989@domain1:5060;uparam1=uval11;uparam2=uval12>;nparam1=nval1'
              ]
            }

            it 'response with PAI headers ' do
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

        context 'Customer Auth PAI Policy, PAI useless' do
          # Useless pai has no user part  or tel number

          # we testing there only PAI processing in customer auth.
          # we will use trm gw pai_send_mode_relay  SIP for tests

          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) {
            '[
            {"s": "sip", "n": "name1", "u": null, "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "sip", "n": "name2", "u": "", "h": "domain2", "p": 5062, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]},
            {"s": "tel", "n": null, "u": "", "h": null, "p": null, "np_arr": [], "uh_arr": [], "up_arr": []}
          ]'
          }

          let(:ppi) {
            '{"s": "sip", "n": "name1", "u": null, "h": "domain1", "p": 5060, "np_arr": ["nparam1=nval1"], "uh_arr": ["uhdr1=uhval1"], "up_arr": ["uparam1=uval11","uparam2=uval12"]}'
          }

          context 'Not accepted' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_NOT_ACCEPT }

            let!(:expected_headers) { [] }

            it 'response with PAI headers ' do
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

          context 'Accepted' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }

            let!(:expected_headers) { [] }

            it 'response with PAI headers ' do
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

          context 'Required' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_REQUIRE }

            it 'reject call' do
              expect(subject.size).to eq(1)
              expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_PAI_REQUIRED)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:customer_acc_id]).to be
              expect(subject.first[:dump_level_id]).to be
              expect(subject.first[:dst_prefix_in]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(nil)
            end
          end
        end

        context 'Customer Auth PAI Policy, PAI missing' do
          # we testing there only PAI processing in customer auth.
          # we will use trm gw pai_send_mode_relay  SIP for tests
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) { '[]' }
          let(:ppi) { nil }

          context 'Not accepted' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_NOT_ACCEPT }

            let!(:expected_headers) { [] }

            it 'response with PAI headers ' do
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

          context 'Accepted' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }

            let!(:expected_headers) { [] }

            it 'response with PAI headers ' do
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

          context 'Required' do
            let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_REQUIRE }

            let!(:expected_headers) { [] }

            it 'reject call' do
              expect(subject.size).to eq(1)
              expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_PAI_REQUIRED)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:customer_acc_id]).to be
              expect(subject.first[:dump_level_id]).to be
              expect(subject.first[:dst_prefix_in]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(nil)
            end
          end
        end

        context 'Term gw, SIP ' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_BUILD_SIP } # sip URI
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let!(:expected_headers) {
            [
              "P-Asserted-Identity: <sip:123456789@#{vendor_gw_pai_domain}>"
            ]
          }

          it 'response with PAI headers ' do
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

        context 'Term gw append headers, TEL' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_BUILD_TEL } # tel: URI

          let!(:expected_headers) {
            [
              'P-Asserted-Identity: <tel:123456789>'
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

        context 'Term gw append headers, SIP with user=phone ' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_BUILD_SIP_WITH_USER_PHONE } # sip URI
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let!(:expected_headers) {
            [
              "P-Asserted-Identity: <sip:123456789@#{vendor_gw_pai_domain};user=phone>"
            ]
          }

          it 'response with PAI headers ' do
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

        context 'Term gw, RELAY when PAI missing' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }
          let(:pai) { '[]' }
          let(:ppi) { nil }

          let!(:expected_headers) { '' }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                "Privacy: #{privacy}"
              ].join('\r\n')
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy NULL and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { nil }

            let!(:expected_headers) { '' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY when PAI present' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) {
            '[
            {"s": "sip", "n": "p name1", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
          ]'
          }

          let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

          let!(:expected_headers) {
            [
              'P-Asserted-Identity: "p name1" <sip:pai-user@pai.domain.example.com>',
              'P-Asserted-Identity: "p name2" <sip:pai-user2@pai.domain.example.com>',
              'P-Preferred-Identity: "pp name1" <sip:ppi-user@ppi.domain.example.com>'
            ]
          }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let(:pai) {
              '[
              {"s": "sip", "n": "p name", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
              {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
            ]'
            }

            let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

            let!(:expected_headers) {
              [
                'P-Asserted-Identity: "p name" <sip:pai-user@pai.domain.example.com>',
                'P-Asserted-Identity: "p name2" <sip:pai-user2@pai.domain.example.com>',
                'P-Preferred-Identity: "pp name1" <sip:ppi-user@ppi.domain.example.com>'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let(:pai) {
              '[
              {"s": "sip", "n": "p name", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
              {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
            ]'
            }

            let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let(:pai) {
              '[
              {"s": "sip", "n": "p name1", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
              {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
            ]'
            }

            let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            let(:pai) {
              '[
              {"s": "sip", "n": "p name", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
              {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
            ]'
            }

            let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let(:pai) {
              '[
              {"s": "sip", "n": "p name", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
              {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
            ]'
            }

            let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let(:pai) {
              '[
              {"s": "sip", "n": "p name", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
              {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null }
            ]'
            }

            let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

            let!(:expected_headers) {
              [
                "Privacy: #{privacy}",
                'P-Asserted-Identity: "p name" <sip:pai-user@pai.domain.example.com>',
                'P-Asserted-Identity: "p name2" <sip:pai-user2@pai.domain.example.com>',
                'P-Preferred-Identity: "pp name1" <sip:ppi-user@ppi.domain.example.com>'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY, RELAY as TEL when PAI present' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_TEL }

          let(:pai) {
            '[
            {"s": "sip", "n": "p name1", "u": "", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name1", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null },
            {"s": "tel", "u": "tel-user2" }
          ]'
          }

          let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

          let!(:expected_headers) {
            [
              'P-Asserted-Identity: <tel:pai-user>',
              'P-Asserted-Identity: <tel:pai-user2>',
              'P-Asserted-Identity: <tel:tel-user2>',
              'P-Preferred-Identity: <tel:ppi-user>'
            ]
          }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                'Privacy: id',
                'P-Asserted-Identity: <tel:pai-user>',
                'P-Asserted-Identity: <tel:pai-user2>',
                'P-Asserted-Identity: <tel:tel-user2>',
                'P-Preferred-Identity: <tel:ppi-user>'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY, RELAY as TEL when PAI missing' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_TEL }

          let(:pai) { '[]' }
          let(:ppi) { nil }

          let!(:expected_headers) { [] }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                'Privacy: id'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY, RELAY as SIP when PAI present' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) {
            '[
            {"s": "sip", "n": "p name1", "u": "", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name1", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null },
            {"s": "tel", "u": "tel-user2" }
          ]'
          }

          let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

          let!(:expected_headers) {
            [
              'P-Asserted-Identity: "p name1" <sip:pai-user@pai.domain.example.com>',
              'P-Asserted-Identity: "p name2" <sip:pai-user2@pai.domain.example.com>',
              'P-Asserted-Identity: <sip:tel-user2@sip.pai.com>',
              'P-Preferred-Identity: "pp name1" <sip:ppi-user@ppi.domain.example.com>'
            ]
          }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                'Privacy: id',
                'P-Asserted-Identity: "p name1" <sip:pai-user@pai.domain.example.com>',
                'P-Asserted-Identity: "p name2" <sip:pai-user2@pai.domain.example.com>',
                'P-Asserted-Identity: <sip:tel-user2@sip.pai.com>',
                'P-Preferred-Identity: "pp name1" <sip:ppi-user@ppi.domain.example.com>'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY, RELAY as SIP when PAI missing' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) { '[]' }
          let(:ppi) { nil }

          let!(:expected_headers) { [] }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                'Privacy: id'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY, RELAY as SIP replace domain when PAI present' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP_FORCE_DOMAIN }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) {
            '[
            {"s": "sip", "n": "p name1", "u": "", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name1", "u": "pai-user", "h": "pai.domain.example.com", "p": null },
            {"s": "sip", "n": "p name2", "u": "pai-user2", "h": "pai.domain.example.com", "p": null },
            {"s": "tel", "u": "tel-user2" }
          ]'
          }

          let(:ppi) { '{"s": "sip", "n": "pp name1", "u": "ppi-user", "h": "ppi.domain.example.com", "p": null }' }

          let!(:expected_headers) {
            [
              'P-Asserted-Identity: "p name1" <sip:pai-user@sip.pai.com>',
              'P-Asserted-Identity: "p name2" <sip:pai-user2@sip.pai.com>',
              'P-Asserted-Identity: <sip:tel-user2@sip.pai.com>',
              'P-Preferred-Identity: "pp name1" <sip:ppi-user@sip.pai.com>'
            ]
          }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                'Privacy: id',
                'P-Asserted-Identity: "p name1" <sip:pai-user@sip.pai.com>',
                'P-Asserted-Identity: "p name2" <sip:pai-user2@sip.pai.com>',
                'P-Asserted-Identity: <sip:tel-user2@sip.pai.com>',
                'P-Preferred-Identity: "pp name1" <sip:ppi-user@sip.pai.com>'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Term gw, RELAY, RELAY as SIP replace domain when PAI missing' do
          let(:vendor_gw_term_append_headers_req) { '' }
          let(:customer_auth_pai_policy_id) { CustomersAuth::PAI_POLICY_ACCEPT }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_RELAY_AS_SIP_FORCE_DOMAIN }
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let(:pai) { '[]' }
          let(:ppi) { nil }

          let!(:expected_headers) { [] }

          it 'response with PAI headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
            expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with privacy id and disabled privacy policy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_DISABLE }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:ruri]).to be
              expect(subject.first[:from]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:dst_prefix_out]).to eq('uri-name') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id; critical and SKIP GW critical' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_SKIP_CRITICAL }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id;critical' }

            it 'response with skipped route' do
              expect(subject.size).to eq(2)
              expect(subject.first[:ruri]).to eq(nil)
              expect(subject.first[:from]).to eq(nil)
              expect(subject.first[:dst_prefix_routing]).to eq(nil)
              expect(subject.first[:append_headers_req]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and apply privacy' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_APPLY }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            it 'response without PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('Anonymous') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('anonymous') # Original destination
              expect(subject.first[:from]).to eq('"Anonymous" <sip:anonymous@anonymous.invalid>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq("Privacy: #{privacy}")
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context 'with privacy id and trusted gw' do
            let(:vendor_gw_term_append_headers_req) { '' }
            let(:vendor_gw_privacy_mode_id) { Gateway::PRIVACY_MODE_TRUSTED }
            let(:vendor_gw_pai_domain) { 'sip.pai.com' }
            let(:privacy) { 'id' }

            let!(:expected_headers) {
              [
                'Privacy: id'
              ]
            }

            it 'response with PAI headers ' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:src_name_out]).to eq('from display name') # Original destination
              expect(subject.first[:src_prefix_out]).to eq('123456789') # Original destination
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>') # Original destination
              expect(subject.first[:dst_prefix_routing]).to eq('uri-name') # Original destination
              expect(subject.first[:append_headers_req]).to eq(expected_headers.join('\r\n'))
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'with append headers' do
          let(:vendor_gw_term_append_headers_req) { 'Header5: value5\r\nHeader6: value7' }
          let(:vendor_gw_pai_send_mode_id) { Gateway::PAI_SEND_MODE_BUILD_SIP } # sip: URI
          let(:vendor_gw_pai_domain) { 'sip.pai.com' }

          let!(:expected_headers) {
            [
              "P-Asserted-Identity: <sip:123456789@#{vendor_gw_pai_domain}>",
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

      context 'Authorized, SIP schemas' do
        let(:from_name) { '123456789' }

        context 'SIP ' do
          let(:vendor_gw_sip_schema_id) { Gateway::SIP_SCHEMA_SIP }

          it 'response with SIP URI' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>')
            expect(subject.first[:to]).to eq('<sip:uri-name@1.1.2.3>')
            expect(subject.first[:ruri]).to eq('sip:uri-name@1.1.2.3')
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with defined port' do
            let(:vendor_gw_port) { 50_060 }

            it 'with port in ruri' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi>')
              expect(subject.first[:to]).to eq('<sip:uri-name@1.1.2.3:50060>')
              expect(subject.first[:ruri]).to eq('sip:uri-name@1.1.2.3:50060')
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'SIPS' do
          let(:vendor_gw_sip_schema_id) { Gateway::SIP_SCHEMA_SIPS }

          it 'response with SIPS URI' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:from]).to eq('"from display name" <sips:123456789@$Oi>')
            expect(subject.first[:to]).to eq('<sips:uri-name@1.1.2.3>')
            expect(subject.first[:ruri]).to eq('sips:uri-name@1.1.2.3')
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with defined port' do
            let(:vendor_gw_port) { 50_070 }

            it 'with port in ruri' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:from]).to eq('"from display name" <sips:123456789@$Oi>')
              expect(subject.first[:to]).to eq('<sips:uri-name@1.1.2.3:50070>')
              expect(subject.first[:ruri]).to eq('sips:uri-name@1.1.2.3:50070')
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'SIP with user=phone' do
          let(:vendor_gw_sip_schema_id) { Gateway::SIP_SCHEMA_SIP_WITH_USER_PHONE }

          it 'response with SIP user=phone' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi;user=phone>')
            expect(subject.first[:to]).to eq('<sip:uri-name@1.1.2.3;user=phone>')
            expect(subject.first[:ruri]).to eq('sip:uri-name@1.1.2.3;user=phone')
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end

          context 'with defined port' do
            let(:vendor_gw_port) { 50_061 }

            it 'with port in ruri' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
              expect(subject.first[:from]).to eq('"from display name" <sip:123456789@$Oi;user=phone>')
              expect(subject.first[:to]).to eq('<sip:uri-name@1.1.2.3:50061;user=phone>')
              expect(subject.first[:ruri]).to eq('sip:uri-name@1.1.2.3:50061;user=phone')
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end
      end

      context 'Authorized, registered Aor modes' do
        let(:uri_name) { '+1234567890' }

        context 'registered aor mode - disable' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_NO_USE }
          let(:vendor_gw_host) { 'pai.test.domain.com' }

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
          let(:vendor_gw_host) { 'pai.test.domain.com' }
          let(:expected_ruri_host) { 'unknown.invalid' }

          it 'response' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{expected_ruri_host}")
            expect(subject.first[:registered_aor_id]).to eq(vendor_gateway.id)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_AS_IS)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'registered aor mode - As is, null host' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_AS_IS }
          let(:vendor_gw_host) { nil }
          let(:expected_ruri_host) { 'unknown.invalid' }

          it 'response' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{expected_ruri_host}")
            expect(subject.first[:registered_aor_id]).to eq(vendor_gateway.id)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_AS_IS)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'registered aor mode - replace userpart' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_REPLACE_USERPART }
          let(:expected_ruri_host) { 'unknown.invalid' }

          it 'response' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{expected_ruri_host}")
            expect(subject.first[:registered_aor_id]).to eq(vendor_gateway.id)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_REPLACE_USERPART)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'registered aor mode - replace userpart, null host' do
          let(:vendor_gw_registered_aor_mode_id) { Gateway::REGISTERED_AOR_MODE_REPLACE_USERPART }
          let(:vendor_gw_host) { nil }
          let(:expected_ruri_host) { 'unknown.invalid' }

          it 'response' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq('+1234567890') # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq('+1234567890') # Original destination
            expect(subject.first[:ruri]).to eq("sip:+1234567890@#{expected_ruri_host}")
            expect(subject.first[:registered_aor_id]).to eq(vendor_gateway.id)
            expect(subject.first[:registered_aor_mode_id]).to eq(Gateway::REGISTERED_AOR_MODE_REPLACE_USERPART)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
      end

      context 'Authorized, DST Number (RURI/To) rewrite rule' do
        let(:uri_name) { '+1234567890' }
        let(:vendor_gw_host) { 'dst.domain.com' }

        context 'Rewrite disabled' do
          let(:vendor_gw_dst_rewrite_rule) { nil }
          let(:vendor_gw_dst_rewrite_result) { '1211\1' }
          let(:vendor_gw_to_rewrite_rule) { nil }
          let(:vendor_gw_to_rewrite_result) { '2322\1' }

          it 'response with original number ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq(uri_name) # Original destination
            expect(subject.first[:ruri]).to eq("sip:#{uri_name}@#{vendor_gateway.host}")
            expect(subject.first[:to]).to eq("<sip:#{uri_name}@#{vendor_gateway.host}>")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'TO Rewrite enabled' do
          let(:vendor_gw_to_rewrite_rule) { '^(.*)$' }
          let(:vendor_gw_to_rewrite_result) { '1111#\1' }

          it 'response with Diversion headers ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_out]).to eq(uri_name) # Original destination
            expect(subject.first[:dst_prefix_routing]).to eq(uri_name) # Original destination
            expect(subject.first[:ruri]).to eq("sip:#{uri_name}@#{vendor_gateway.host}") # original dst in RURI
            expect(subject.first[:to]).to eq("<sip:1111##{uri_name}@#{vendor_gateway.host}>") # rewtited dst in TO
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'DST Rewrite enabled' do
          let(:vendor_gw_dst_rewrite_rule) { '^(.*)$' }
          let(:vendor_gw_dst_rewrite_result) { '8888#\1' }

          it 'response with original number ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_routing]).to eq(uri_name) # Original destination
            expect(subject.first[:dst_prefix_out]).to eq("8888##{uri_name}") # Original destination
            expect(subject.first[:ruri]).to eq("sip:8888##{uri_name}@#{vendor_gateway.host}")
            expect(subject.first[:to]).to eq("<sip:8888##{uri_name}@#{vendor_gateway.host}>")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'DST and TO Rewrite enabled' do
          let(:vendor_gw_dst_rewrite_rule) { '^(.*)$' }
          let(:vendor_gw_dst_rewrite_result) { '8888#\1' }
          let(:vendor_gw_to_rewrite_rule) { '^(.*)$' }
          let(:vendor_gw_to_rewrite_result) { '9999#\1' }

          it 'response with original number ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:customer_auth_id]).to be
            expect(subject.first[:customer_id]).to be
            expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
            expect(subject.first[:dst_prefix_routing]).to eq(uri_name) # Original destination
            expect(subject.first[:dst_prefix_out]).to eq("8888##{uri_name}") # Original destination
            expect(subject.first[:ruri]).to eq("sip:8888##{uri_name}@#{vendor_gateway.host}")
            expect(subject.first[:to]).to eq("<sip:9999#8888##{uri_name}@#{vendor_gateway.host}>")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
      end

      context 'Authorized, STIR/SHAKEN processing.' do
        context 'Disable mode' do
          let(:customer_auth_ss_mode_id) { CustomersAuth::SS_MODE_DISABLE }
          context ',try to insert with routing numbers' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
            let(:crt) { create(:stir_shaken_signing_certificate) }
            let(:vendor_gw_stir_shaken_crt_id) { crt.id }

            it 'not works' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(nil)
              expect(subject.first[:ss_otn]).to eq(nil)
              expect(subject.first[:ss_dtn]).to eq(nil)
              expect(subject.first[:ss_attest_id]).to eq(nil)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
          context ',try to insert with out numbers' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT_OUT }
            let(:crt) { create(:stir_shaken_signing_certificate) }
            let(:vendor_gw_stir_shaken_crt_id) { crt.id }

            it 'not works' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(nil)
              expect(subject.first[:ss_otn]).to eq(nil)
              expect(subject.first[:ss_dtn]).to eq(nil)
              expect(subject.first[:ss_attest_id]).to eq(nil)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end

        context 'Validation mode' do
          let(:customer_auth_ss_mode_id) { CustomersAuth::SS_MODE_VALIDATE }

          [
            nil,
            '[]',
            '[{"k1":"v1"},{"k2":"v2"}]',
            '[{"parsed":false,"verified":false}]'
          ].each do |val|
            context "none value #{val}, no action" do
              let(:identity) { val }
              let(:customer_auth_ss_no_identity_action_id) { CustomersAuth::SS_NO_IDENTITY_ACTION_NOTHING }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_NONE)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
            context "none value #{val}, reject" do
              let(:identity) { val }
              let(:customer_auth_ss_no_identity_action_id) { CustomersAuth::SS_NO_IDENTITY_ACTION_REJECT }
              it 'OK' do
                expect(subject.size).to eq(1)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_IDENTITY_REQUIRED)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_NONE)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
              end
            end
            context "none value #{val}, rewrite" do
              let(:identity) { val }
              let(:customer_auth_ss_no_identity_action_id) { CustomersAuth::SS_NO_IDENTITY_ACTION_REWRITE }
              let(:customer_auth_rewrite_ss_status_id) { Equipment::StirShaken::Attestation::ATTESTATION_B }

              let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
              let(:crt) { create(:stir_shaken_signing_certificate) }
              let(:vendor_gw_stir_shaken_crt_id) { crt.id }

              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq(subject.first[:src_prefix_routing])
                expect(subject.first[:ss_dtn]).to eq(subject.first[:dst_prefix_routing])
                expect(subject.first[:ss_attest_id]).to eq(Cdr::Cdr::SS_STATUS_B)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_NONE)
                expect(subject.first[:legb_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_B)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
          end

          [
            '[{"parsed":true,"verified":false}]',
            '[{"parsed":true,"verified":true}]',
            '[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["12022216000"] },
                  "iat": 1622830203, "orig": { "tn": "213213" }, "origid": "6666"
                }
              }]',
            '[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "AAAA", "dest": { "tn": ["uri-name"] },
                  "iat": 1622830203, "orig": { "tn": "from_username" }, "origid": "6666"
                }
              }]'
          ].each do |val|
            context "invalid value #{val}, no action" do
              let(:identity) { val }
              let(:customer_auth_ss_no_identity_action_id) { CustomersAuth::SS_NO_IDENTITY_ACTION_NOTHING }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_INVALID)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
            context "invalid value #{val}, reject" do
              let(:identity) { val }
              let(:customer_auth_ss_invalid_identity_action_id) { CustomersAuth::SS_INVALID_IDENTITY_ACTION_REJECT }
              it 'OK' do
                expect(subject.size).to eq(1)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(DisconnectCode::DC_IDENTITY_INVALID)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_INVALID)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
              end
            end
            context "invalid value #{val}, rewrite + insert" do
              let(:identity) { val }
              let(:customer_auth_ss_invalid_identity_action_id) { CustomersAuth::SS_INVALID_IDENTITY_ACTION_REWRITE }
              let(:customer_auth_rewrite_ss_status_id) { Equipment::StirShaken::Attestation::ATTESTATION_C }

              let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
              let(:crt) { create(:stir_shaken_signing_certificate) }
              let(:vendor_gw_stir_shaken_crt_id) { crt.id }

              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq(subject.first[:src_prefix_routing])
                expect(subject.first[:ss_dtn]).to eq(subject.first[:dst_prefix_routing])
                expect(subject.first[:ss_attest_id]).to eq(Cdr::Cdr::SS_STATUS_C)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_INVALID)
                expect(subject.first[:legb_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_C)
                expect(subject.first[:transit_headers_a2b]).to eq(';')
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
            context "invalid value #{val}, rewrite + can't insert without certificate" do
              let(:identity) { val }
              let(:customer_auth_ss_invalid_identity_action_id) { CustomersAuth::SS_INVALID_IDENTITY_ACTION_REWRITE }
              let(:customer_auth_rewrite_ss_status_id) { Equipment::StirShaken::Attestation::ATTESTATION_C }

              let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }

              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:ss_attest_id]).to eq(Cdr::Cdr::SS_STATUS_C)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_INVALID)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
                expect(subject.first[:transit_headers_a2b]).to eq(';')
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
          end

          ['[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["uri-name"] },
                  "iat": 1622830203, "orig": { "tn": "from_username" }, "origid": "6666"
                }
              }]',
           '[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["invalid", "uri-name"] },
                  "iat": 1622830203, "orig": { "tn": "from_username" }, "origid": "6666"
                }
              }]',
           '[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["uri-name","invalid"] },
                  "iat": 1622830203, "orig": { "tn": "from_username" }, "origid": "6666"
                }
              }]'].each do |val|
            context "valid value #{val}, no action" do
              let(:identity) { val }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_A)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
                expect(subject.first[:transit_headers_a2b]).to eq(';')
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
            context "valid value #{val}, relay" do
              let(:identity) { val }
              let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
              let(:crt) { create(:stir_shaken_signing_certificate) }
              let(:vendor_gw_stir_shaken_crt_id) { crt.id }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_A)
                expect(subject.first[:legb_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_A)
                expect(subject.first[:transit_headers_a2b]).to eq('Identity;Identity')
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
          end

          ['[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["+uri-name"] },
                  "iat": 1622830203, "orig": { "tn": "00from_username" }, "origid": "6666"
                }
              }]',
           '[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["invalid", "+uri-name"] },
                  "iat": 1622830203, "orig": { "tn": "00from_username" }, "origid": "6666"
                }
              }]',
           '[{
                "parsed":true, "verified":true,
                "header": { "alg": "ES256", "ppt": "shaken", "typ": "passport", "x5u": "http://127.0.0.1/share/test.pem"},
                "payload": {
                  "attest": "A", "dest": { "tn": ["+uri-name","invalid"] },
                  "iat": 1622830203, "orig": { "tn": "00from_username" }, "origid": "6666"
                }
              }]'].each do |val|
            context "valid value #{val}, with rewrite no action" do
              let(:customer_auth_ss_src_rewrite_rule) { '(.*)' }
              let(:customer_auth_ss_src_rewrite_result) { '00\1' }
              let(:customer_auth_ss_dst_rewrite_rule) { '(.*)' }
              let(:customer_auth_ss_dst_rewrite_result) { '+\1' }

              let(:identity) { val }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_A)
                expect(subject.first[:legb_ss_status_id]).to eq(nil)
                expect(subject.first[:transit_headers_a2b]).to eq(';')
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
            context "valid value #{val}, with rewrite relay" do
              let(:customer_auth_ss_src_rewrite_rule) { '(.*)' }
              let(:customer_auth_ss_src_rewrite_result) { '00\1' }
              let(:customer_auth_ss_dst_rewrite_rule) { '(.*)' }
              let(:customer_auth_ss_dst_rewrite_result) { '+\1' }

              let(:identity) { val }
              let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
              let(:crt) { create(:stir_shaken_signing_certificate) }
              let(:vendor_gw_stir_shaken_crt_id) { crt.id }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil) # no routing Error
                expect(subject.first[:ss_crt_id]).to eq(nil)
                expect(subject.first[:ss_otn]).to eq(nil)
                expect(subject.first[:ss_dtn]).to eq(nil)
                expect(subject.first[:lega_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_A)
                expect(subject.first[:legb_ss_status_id]).to eq(Cdr::Cdr::SS_STATUS_A)
                expect(subject.first[:transit_headers_a2b]).to eq('Identity;Identity')
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
          end
        end

        context 'Force rewrite mode' do
          let(:customer_auth_ss_mode_id) { CustomersAuth::SS_MODE_REWRITE }
          let(:customer_auth_rewrite_ss_status_id) { Equipment::StirShaken::Attestation::ATTESTATION_B }

          context ',try to insert without certificates' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }

            it 'not works' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(nil)
              expect(subject.first[:ss_otn]).to eq(nil)
              expect(subject.first[:ss_dtn]).to eq(nil)
              expect(subject.first[:ss_attest_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(nil)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
          context ',try to insert with customer auth certificate only' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
            let(:crt) { create(:stir_shaken_signing_certificate) }
            let(:customer_auth_stir_shaken_crt_id) { crt.id }

            it 'OK' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(crt.id)
              expect(subject.first[:ss_otn]).to eq('from_username')
              expect(subject.first[:ss_dtn]).to eq('uri-name')
              expect(subject.first[:ss_attest_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end

          context ',try to insert with customer auth certificate only and override ss_status in ca dst numberlist' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
            let(:crt) { create(:stir_shaken_signing_certificate) }
            let(:customer_auth_stir_shaken_crt_id) { crt.id }
            let!(:customer_auth_dst_numberlist_id) {
              create(:numberlist,
                      mode_id: Routing::Numberlist::MODE_STRICT,
                      default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                      rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_A).id
            }

            it 'OK' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(crt.id)
              expect(subject.first[:ss_otn]).to eq('from_username')
              expect(subject.first[:ss_dtn]).to eq('uri-name')
              expect(subject.first[:ss_attest_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_A)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_A)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end

            context 'and ca src numberlist' do
              let!(:customer_auth_src_numberlist_id) {
                create(:numberlist,
                        mode_id: Routing::Numberlist::MODE_STRICT,
                        default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                        rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_C).id
              }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq('from_username')
                expect(subject.first[:ss_dtn]).to eq('uri-name')
                expect(subject.first[:ss_attest_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_C)
                expect(subject.first[:lega_ss_status_id]).to eq(nil)
                expect(subject.first[:legb_ss_status_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_C)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end

            context 'and routing plan dst numberlist' do
              let!(:routing_plan_dst_numberlist_id) {
                create(:numberlist,
                        mode_id: Routing::Numberlist::MODE_STRICT,
                        default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                        rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_A).id
              }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq('from_username')
                expect(subject.first[:ss_dtn]).to eq('uri-name')
                expect(subject.first[:ss_attest_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_A)
                expect(subject.first[:lega_ss_status_id]).to eq(nil)
                expect(subject.first[:legb_ss_status_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_A)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end

            context 'and routing plan src numberlist' do
              let!(:routing_plan_src_numberlist_id) {
                create(:numberlist,
                        mode_id: Routing::Numberlist::MODE_STRICT,
                        default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                        rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_B).id
              }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq('from_username')
                expect(subject.first[:ss_dtn]).to eq('uri-name')
                expect(subject.first[:ss_attest_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_B)
                expect(subject.first[:lega_ss_status_id]).to eq(nil)
                expect(subject.first[:legb_ss_status_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_B)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end

            context 'and vendor gw dst numberlist' do
              let!(:vendor_gw_dst_numberlist_id) {
                create(:numberlist,
                        mode_id: Routing::Numberlist::MODE_STRICT,
                        default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                        rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_C).id
              }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq('from_username')
                expect(subject.first[:ss_dtn]).to eq('uri-name')
                expect(subject.first[:ss_attest_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_C)
                expect(subject.first[:lega_ss_status_id]).to eq(nil)
                expect(subject.first[:legb_ss_status_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_C)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end

            context 'and vendor gw src numberlist' do
              let!(:vendor_gw_src_numberlist_id) {
                create(:numberlist,
                        mode_id: Routing::Numberlist::MODE_STRICT,
                        default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                        rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_B).id
              }
              it 'OK' do
                expect(subject.size).to eq(2)
                expect(subject.first[:customer_auth_id]).to be
                expect(subject.first[:customer_id]).to be
                expect(subject.first[:disconnect_code_id]).to eq(nil)

                expect(subject.first[:ss_crt_id]).to eq(crt.id)
                expect(subject.first[:ss_otn]).to eq('from_username')
                expect(subject.first[:ss_dtn]).to eq('uri-name')
                expect(subject.first[:ss_attest_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_B)
                expect(subject.first[:lega_ss_status_id]).to eq(nil)
                expect(subject.first[:legb_ss_status_id]).to eq(Equipment::StirShaken::Attestation::ATTESTATION_B)
                expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
              end
            end
          end

          context ',try to insert with customer auth and vendor gw certificates' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }

            let(:ccrt) { create(:stir_shaken_signing_certificate) }
            let(:vcrt) { create(:stir_shaken_signing_certificate) }

            let(:customer_auth_stir_shaken_crt_id) { ccrt.id }
            let(:vendor_gw_stir_shaken_crt_id) { vcrt.id }

            it 'Prefer customer auth certificate' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(ccrt.id)
              expect(subject.first[:ss_otn]).to eq('from_username')
              expect(subject.first[:ss_dtn]).to eq('uri-name')
              expect(subject.first[:ss_attest_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
          context ',try to insert with routing numbers' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT }
            let(:crt) { create(:stir_shaken_signing_certificate) }
            let(:vendor_gw_stir_shaken_crt_id) { crt.id }

            it 'OK' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(crt.id)
              expect(subject.first[:ss_otn]).to eq('from_username')
              expect(subject.first[:ss_dtn]).to eq('uri-name')
              expect(subject.first[:ss_attest_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
          context ',try to insert with out numbers' do
            let(:vendor_gw_stir_shaken_mode_id) { Gateway::STIR_SHAKEN_MODE_RELAY_INSERT_OUT }
            let(:crt) { create(:stir_shaken_signing_certificate) }
            let(:vendor_gw_stir_shaken_crt_id) { crt.id }

            it 'OK' do
              expect(subject.size).to eq(2)
              expect(subject.first[:customer_auth_id]).to be
              expect(subject.first[:customer_id]).to be
              expect(subject.first[:disconnect_code_id]).to eq(nil)

              expect(subject.first[:ss_crt_id]).to eq(crt.id)
              expect(subject.first[:ss_otn]).to eq('from_username')
              expect(subject.first[:ss_dtn]).to eq('uri-name')
              expect(subject.first[:ss_attest_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.first[:lega_ss_status_id]).to eq(nil)
              expect(subject.first[:legb_ss_status_id]).to eq(customer_auth_rewrite_ss_status_id)
              expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
            end
          end
        end
      end

      context 'SRC Number format validation enabled' do
        let(:validate_src_number_format) { true }
        let(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_ALLOW }

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
        let(:customer_auth_privacy_mode_id) { CustomersAuth::PRIVACY_MODE_ALLOW }

        context 'Number is valid' do
          let(:from_name) { '380961111111' }

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
        context 'Number has existed network prefix, but wrong length' do
          let(:from_name) { '3809711' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8010) # last profile with invalid SRC number network error
          end
        end

        context 'Number has existed network prefix, but network is not defined' do
          # 380 prefix exists, but without network(it is aggregated prefix), calls should be rejected
          let(:from_name) { '380123456789' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8010) # last profile with invalid SRC number network error
          end
        end
      end

      context 'DST Number format validation enabled' do
        let(:validate_dst_number_format) { true }

        context 'Number is valid' do
          let(:uri_name) { '380961111111111111111111' }

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
          let(:uri_name) { '380961234567' }

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

        context 'Number has known prefix, but wrong length' do
          let(:uri_name) { '3809612' }

          it 'response with ok ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8007) # last profile with route not found error
          end
        end

        context 'Number has known network prefix, but network is not defined' do
          # 380 prefix exists, but without network(it is aggregated prefix), calls should be rejected
          let(:uri_name) { '380123456789' }

          it 'response with reject ' do
            expect(subject.size).to eq(1)
            expect(subject.first[:disconnect_code_id]).to eq(8007) # last profile with invalid DST number network error
          end
        end
      end

      context 'Termination gw capacity/cps limit' do
        context 'no termination gw capacity/cps limit' do
          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:legb_res]).to eq('')
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'termination gw capacity limit' do
          let(:vendor_gw_termination_capacity) { 10 }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:legb_res]).to eq("5:#{vendor_gateway.id}:#{vendor_gw_termination_capacity}:1;")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'termination gw subscriber capacity limit' do
          let(:vendor_gw_termination_subscriber_capacity) { 20 }
          let(:uri_name) { '#38;0|_961 234:567@' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:legb_res]).to eq("8:#{vendor_gateway.id}__38_0__961_234_567_:#{vendor_gw_termination_subscriber_capacity}:1;")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'termination gw cps limit' do
          let(:vendor_gw_termination_cps_limit) { 11 }
          let(:vendor_gw_termination_cps_wsize) { 30 }
          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:legb_res]).to eq("9:#{vendor_gateway.id}:#{vendor_gw_termination_cps_limit}:#{vendor_gw_termination_cps_wsize};")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'termination gw subscriber cps limit' do
          let(:vendor_gw_termination_subscriber_cps_limit) { 99 }
          let(:vendor_gw_termination_subscriber_cps_wsize) { 15 }
          let(:uri_name) { '#38;0|_961 234:567@' }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:legb_res]).to eq("10:#{vendor_gateway.id}__38_0__961_234_567_:#{vendor_gw_termination_subscriber_cps_limit}:#{vendor_gw_termination_subscriber_cps_wsize};")
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end

        context 'termination gw all limits enabled' do
          let(:vendor_gw_termination_capacity) { 10 }
          let(:vendor_gw_termination_subscriber_capacity) { 20 }

          let(:vendor_gw_termination_cps_limit) { 11 }
          let(:vendor_gw_termination_cps_wsize) { 30 }

          let(:vendor_gw_termination_subscriber_cps_limit) { 99 }
          let(:vendor_gw_termination_subscriber_cps_wsize) { 15 }
          let(:uri_name) { '#38;0|_961 234:567@' }

          let(:expected_resources) {
            [
              "5:#{vendor_gateway.id}:#{vendor_gw_termination_capacity}:1",
              "8:#{vendor_gateway.id}__38_0__961_234_567_:#{vendor_gw_termination_subscriber_capacity}:1",
              "9:#{vendor_gateway.id}:#{vendor_gw_termination_cps_limit}:#{vendor_gw_termination_cps_wsize}",
              "10:#{vendor_gateway.id}__38_0__961_234_567_:#{vendor_gw_termination_subscriber_cps_limit}:#{vendor_gw_termination_subscriber_cps_wsize}"
            ]
          }

          it 'response with ok ' do
            expect(subject.size).to eq(2)
            expect(subject.first[:legb_res].split(';')).to eq(expected_resources)
            expect(subject.second[:disconnect_code_id]).to eq(113) # last profile with route not found error
          end
        end
      end

      context 'Authorized, Variables processing' do
        let!(:nl) {
          create(:numberlist,
                 mode_id: nl_mode,
                 default_action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
                 variables: { 'dst_numberlist' => '1' })
        }
        let!(:nl_item) {
          create(:numberlist_item,
                 numberlist_id: nl.id,
                 key: '12345678',
                 action_id: Routing::NumberlistItem::ACTION_ACCEPT,
                 variables: { 'dst_numberlist_item' => '1' })
        }

        let(:customer_auth_dst_numberlist_id) { nl.id }
        let(:customer_auth_variables) { { 'host' => 'test', 'customer_auth_var1' => '1' } }

        let(:uri_name) { '12345678' }
        let(:vendor_gw_host) { 'var-{{vars.host}}-domain.com' }
        let(:vendor_gw_contact_user) { 'bleg-contact-{{vars.host}}' }
        let(:customer_gw_contact_user) { 'aleg-contact-{{vars.host}}' }
        let(:vendor_gw_term_append_headers_req) { ['X-Host: {{vars.host}}', 'X-Item: {{vars.customer_auth_var1}}', 'X-No: 1'] }
        let!(:expected_term_append_headers_req) {
          [
            'X-Host: test',
            'X-Item: 1',
            'X-No: 1'
          ].join('\r\n')
        }

        let!(:orig_append_headers_reply) { ['X-Orig-Reply: {{vars.host}}', 'X-Item: {{vars.customer_auth_var1}}', 'X-No: 1'] }
        let!(:expected_orig_append_headers_reply) {
          [
            'X-Orig-Reply: test',
            'X-Item: 1',
            'X-No: 1'
          ].join('\r\n')
        }

        let!(:orig_append_headers_req) { ['X-Orig-Req: {{vars.host}}', 'X-Item: {{vars.customer_auth_var1}}', 'X-No: 1'] }
        let!(:expected_orig_append_headers_req) {
          [
            'X-Orig-Req: test',
            'X-Item: 1',
            'X-No: 1'
          ].join('\r\n')
        }

        context 'not matched ITEM in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:uri_name) { '122' }
          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:ruri]).to eq('sip:122@var-test-domain.com')
            expect(subject.first[:aleg_contact_user]).to eq('aleg-contact-test')
            expect(subject.first[:bleg_contact_user]).to eq('bleg-contact-test')
            expect(subject.first[:append_headers_req]).to eq(expected_term_append_headers_req)
            expect(subject.first[:aleg_append_headers_req]).to eq(expected_orig_append_headers_req)
            expect(subject.first[:aleg_append_headers_reply]).to eq(expected_orig_append_headers_reply)
            expect(subject.first[:metadata]).to eq('{"vars": {"host": "test", "dst_numberlist": "1", "customer_auth_var1": "1"}}')
            expect(subject.first[:disconnect_code_id]).not_to eq(8001)
          end
        end

        context 'matched ITEM in strict mode' do
          let(:nl_mode) { Routing::Numberlist::MODE_STRICT }
          let(:ni_action_id) { Routing::NumberlistItem::ACTION_ACCEPT }

          it 'reject by dst numberlist' do
            expect(subject.size).to eq(2)
            expect(subject.first[:ruri]).to eq('sip:12345678@var-test-domain.com')
            expect(subject.first[:append_headers_req]).to eq(expected_term_append_headers_req)
            expect(subject.first[:aleg_append_headers_req]).to eq(expected_orig_append_headers_req)
            expect(subject.first[:aleg_append_headers_reply]).to eq(expected_orig_append_headers_reply)
            expect(subject.first[:metadata]).to eq('{"vars": {"host": "test", "customer_auth_var1": "1", "dst_numberlist_item": "1"}}')
            expect(subject.first[:disconnect_code_id]).not_to eq(8001)
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
