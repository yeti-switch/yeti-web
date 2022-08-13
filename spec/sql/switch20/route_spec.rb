# frozen_string_literal: true

RSpec.describe '#routing logic' do
  subject do
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

  shared_context 'routing' do
    context 'Use X-SRC-IP if originator is trusted load balancer' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')

        FactoryBot.create(:customers_auth,
                          ip: '3.3.3.3')
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'return 404 ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:customer_auth_id]).to be
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
        @ca = FactoryBot.create(:customers_auth, :with_incoming_auth,
                                ip: '3.3.3.3')
      end

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
        let(:auth_id) { @ca.gateway_id }

        it 'Pass auth ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:customer_auth_id]).to eq(@ca.id)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8000) # No enough customer balance
        end
      end
    end

    context 'Authentification+Reject' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')
        @ca = FactoryBot.create(:customers_auth, :with_incoming_auth, :with_reject,
                                ip: '3.3.3.3')
      end

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

        it 'Pass auth ' do
          expect(subject.size).to eq(1)
          expect(subject.first[:aleg_auth_required]).to be_nil
          expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

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
    end

    context 'Reject calls without Authentification' do
      before do
        FactoryBot.create(:system_load_balancer,
                          signalling_ip: '1.1.1.1')
        @ca = FactoryBot.create(:customers_auth, :with_reject,
                                ip: '3.3.3.3')
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'Reject ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:aleg_auth_required]).to be_nil
        expect(subject.first[:disconnect_code_id]).to eq(8004) # Reject by customer auth

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
                          check_account_balance: false)
      end

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }

      it 'reject ' do
        expect(subject.size).to eq(1)
        expect(subject.first[:customer_auth_id]).to be
        expect(subject.first[:customer_id]).to be
        expect(subject.first[:disconnect_code_id]).to eq(111) # Can't find destination prefix
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
                          customer_id: customer.id,
                          account_id: customer_account.id,
                          gateway_id: customer_gateway.id,
                          rateplan_id: rateplan.id,
                          routing_plan_id: routing_plan.id,
                          send_billing_information: send_billing_information,
                          diversion_policy_id: customer_auth_diversion_policy_id,
                          diversion_rewrite_rule: customer_auth_diversion_rewrite_rule,
                          diversion_rewrite_result: customer_auth_diversion_rewrite_result)
      end

      let!(:send_billing_information) { false }
      let(:customer_auth_diversion_policy_id) { 1 } # do not accept diversion header
      let(:customer_auth_diversion_rewrite_rule) { nil } # removing +380
      let(:customer_auth_diversion_rewrite_result) { nil }

      let(:remote_ip) { '1.1.1.1' }
      let(:x_orig_ip) { '3.3.3.3' }
      let!(:vendor) { create(:contractor, vendor: true, enabled: true) }
      let!(:vendor_account) { create(:account, contractor_id: vendor.id, max_balance: 100_500) }
      let!(:vendor_gateway) {
        create(:gateway,
               contractor_id: vendor.id,
               enabled: true,
               host: '1.1.2.3',
               allow_termination: true,
               term_append_headers_req: vendor_gw_term_append_headers_req,
               diversion_send_mode_id: vendor_gw_diversion_send_mode_id,
               diversion_domain: vendor_gw_diversion_domain,
               diversion_rewrite_rule: vendor_gw_diversion_rewrite_rule,
               diversion_rewrite_result: vendor_gw_diversion_rewrite_result)
      }
      let(:vendor_gw_term_append_headers_req) { '' }
      let(:vendor_gw_diversion_send_mode_id) { 1 } # do not send
      let(:vendor_gw_diversion_domain) { nil }
      let(:vendor_gw_diversion_rewrite_rule) { nil }
      let(:vendor_gw_diversion_rewrite_result) { nil }

      let!(:customer) { create(:contractor, customer: true, enabled: true) }
      let!(:customer_account) { create(:account, contractor_id: customer.id, min_balance: -100_500) }
      let!(:customer_gateway) {
        create(:gateway,
               contractor_id: customer.id,
               enabled: true,
               allow_origination: true,
               orig_append_headers_reply: orig_append_headers_reply)
      }
      let!(:orig_append_headers_reply) { [] }

      let!(:rate_group) { create(:rate_group) }
      let!(:rateplan) { create(:rateplan, rate_groups: [rate_group]) }
      let!(:destination) { create(:destination, prefix: '', enabled: true, rate_group_id: rate_group.id) }

      let!(:routing_group) { create(:routing_group) }
      let!(:routing_plan) { create(:routing_plan, use_lnp: false, routing_groups: [routing_group]) }
      let!(:dialpeer) {
        create(:dialpeer,
               prefix: '',
               enabled: true,
               routing_group_id: routing_group.id,
               vendor_id: vendor.id,
               account_id: vendor_account.id,
               gateway_id: vendor_gateway.id)
      }

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

      context 'Authorized, send_billing_information enabled, Diversion processing, no append headers' do
        let(:customer_auth_diversion_policy_id) { 2 } # Accept
        let(:customer_auth_diversion_rewrite_rule) { '^\+380(.*)$' } # removing +380
        let(:customer_auth_diversion_rewrite_result) { '\1' }
        let(:diversion) { '+38067689798989,+3800000000' }

        let(:vendor_gw_term_append_headers_req) { '' }
        let(:vendor_gw_diversion_send_mode_id) { 2 } # send Diversion as SIP URI
        let(:vendor_gw_diversion_domain) { 'diversion.com' }
        let(:vendor_gw_diversion_rewrite_rule) { '^(.*)' } # adding 10
        let(:vendor_gw_diversion_rewrite_result) { '10\1' }

        let!(:term) { ['header5:value5', 'header6: value7'] }
        let!(:expected_headers) {
          [
            "Diversion: <sip:067689798989@#{vendor_gw_diversion_domain}>",
            "Diversion: <sip:000000@#{vendor_gw_diversion_domain}>"
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
  end

  it_behaves_like 'routing' do
    let(:mode) { 'debug' }
  end

  it_behaves_like 'routing' do
    let(:mode) { 'release' }
  end
end
