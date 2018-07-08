require 'spec_helper'

RSpec.describe '#routing logic' do
  subject do
    CallSql::Yeti.select_all_serialized(
        "SELECT * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.route_debug(
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
          ?::integer,
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

  let(:node_id) {1}
  let(:pop_id) {12}
  let(:protocol_id) {1}
  let(:remote_ip) {'1.1.1.1'}
  let(:remote_port) {5060}
  let(:local_ip) {'2.2.2.2'}
  let(:local_port) {5060}
  let(:from_dsp) {'from display name'}
  let(:from_name) {'from_username'}
  let(:from_domain) {'from-domain'}
  let(:from_port) {5060}
  let(:to_name) {'to_username'}
  let(:to_domain) {'to-domain'}
  let(:to_port) {5060}
  let(:contact_name) {'contact-username'}
  let(:contact_domain) {'contact-domain'}
  let(:contact_port) {5060}
  let(:uri_name) {'uri-name'}
  let(:uri_domain) {'uri-domain'}
  let(:auth_id) {nil}
  let(:x_yeti_auth) {nil}
  let(:diversion) {'test'}
  let(:x_orig_ip) {'3.3.3.3'}
  let(:x_orig_port) {6050}
  let(:x_orig_protocol_id) {2}
  let(:pai) {'pai'}
  let(:ppi) {'ppi'}
  let(:privacy) {'privacy'}
  let(:rpid) {'rpid'}
  let(:rpid_privacy) {'rpid-privacy'}


  context 'Use X-SRC-IP if originator is trusted load balancer' do
    before do
      FactoryGirl.create(:system_load_balancer, {
          signalling_ip: '1.1.1.1'
      }
      )

      FactoryGirl.create(:customers_auth, {
          ip: '3.3.3.3'
      }
      )
    end

    let(:remote_ip) {'1.1.1.1'}
    let(:x_orig_ip) {'3.3.3.3'}

    it 'return 404 ' do
      p subject
      expect(subject.size).to eq(1)
      expect(subject.first[:customer_auth_id]).to be
    end

  end

  context 'Use remote IP if originator is not trusted load balancer' do
    before do
      FactoryGirl.create(:system_load_balancer, {
          signalling_ip: '5.5.5.5'
      }
      )

      FactoryGirl.create(:customers_auth, {
          ip: '3.3.3.3'
      }
      )
    end

    let(:remote_ip) {'1.1.1.1'}
    let(:x_orig_ip) {'3.3.3.3'}

    it 'return 404 ' do
      p subject
      expect(subject.size).to eq(1)
      expect(subject.first[:customer_auth_id]).to be_nil
      expect(subject.first[:disconnect_code_id]).to eq(110) ##Cant find customer or customer locked
    end
  end

  context 'Auhtorized but customer has no enouht balance' do
    before do
      FactoryGirl.create(:system_load_balancer, {
          signalling_ip: '1.1.1.1'
      }
      )

      FactoryGirl.create(:customers_auth, {
          ip: '3.3.3.3'
      }
      )
    end

    let(:remote_ip) {'1.1.1.1'}
    let(:x_orig_ip) {'3.3.3.3'}

    it 'reject ' do
      p subject
      expect(subject.size).to eq(1)
      expect(subject.first[:customer_auth_id]).to be
      expect(subject.first[:customer_id]).to be
      expect(subject.first[:disconnect_code_id]).to eq(8000) #No enough customer balance
    end
  end

  context 'Auhtorized, Balance checking disabled' do
    before do
      FactoryGirl.create(:system_load_balancer, {
          signalling_ip: '1.1.1.1'
      }
      )

      FactoryGirl.create(:customers_auth, {
          ip: '3.3.3.3',
          check_account_balance: false
      }
      )
    end

    let(:remote_ip) {'1.1.1.1'}
    let(:x_orig_ip) {'3.3.3.3'}

    it 'reject ' do
      p subject
      expect(subject.size).to eq(1)
      expect(subject.first[:customer_auth_id]).to be
      expect(subject.first[:customer_id]).to be
      expect(subject.first[:disconnect_code_id]).to eq(111) #Can't find destination prefix
    end
  end


end
