# frozen_string_literal: true

RSpec.describe '#routing logic switch19' do
  subject do
    CallSql::Yeti.select_all_serialized(
      "SELECT * from switch19.route_debug(
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
  let(:diversion) { 'test' }
  let(:x_orig_ip) { '3.3.3.3' }
  let(:x_orig_port) { 6050 }
  let(:x_orig_protocol_id) { 2 }
  let(:pai) { 'pai' }
  let(:ppi) { 'ppi' }
  let(:privacy) { 'privacy' }
  let(:rpid) { 'rpid' }
  let(:rpid_privacy) { 'rpid-privacy' }

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

  context 'Auhtorized but customer has no enough balance' do
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
end
