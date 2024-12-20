# frozen_string_literal: true

RSpec.describe 'switch.write_auth_log()' do
  subject do
    SqlCaller::Cdr.execute(%(SELECT * FROM switch.write_auth_log(
        #{is_master}::boolean,
        #{node_id}::integer,
        #{pop_id}::integer,
        '#{request_time.to_f}'::double precision,
        #{transport_proto_id}::smallint,
        '#{transport_remote_ip}'::inet,
        #{transport_remote_port}::integer,
        '#{transport_local_ip}'::inet,
        #{transport_local_port}::integer,
        '#{username}'::varchar,
        '#{realm}'::varchar,
        '#{i_method}'::varchar,
        '#{ruri}'::varchar,
        '#{from_uri}'::varchar,
        '#{to_uri}'::varchar,
        '#{call_id}'::varchar,
        #{success}::boolean,
        #{code}::smallint,
        '#{reason}'::varchar,
        '#{internal_reason}'::varchar,
        '#{nonce}'::varchar,
        '#{response}'::varchar,
        #{gateway_id}::integer,
        '#{lega_request_headers}'::json
      );))
  end

  let(:is_master) { true }
  let(:node_id) { 1 }
  let(:pop_id) { 1 }

  let(:request_time) { 10.seconds.ago }
  let(:transport_proto_id) { 1 }
  let(:transport_remote_ip) { '1.1.1.1' }
  let(:transport_remote_port) { 5060 }
  let(:transport_local_ip) { '2.2.2.2' }
  let(:transport_local_port) { 6050 }
  let(:username) { 'user' }
  let(:realm) { 'auth-realm' }
  let(:i_method) { 'REGISTER' }
  let(:ruri) { 'sip:ruri@domain' }
  let(:from_uri) { '"from" <sip:from@domain>' }
  let(:to_uri) { '"to" <sip:to@domain>' }
  let(:call_id) { 'fAtogKNE7RNF5ba7rm9A8Do1hFo1xOX7ppWo72vDV4gErsyBacSOhtI6ORKKedCJJ' }
  let(:success) { true }
  let(:code) { 200 }
  let(:reason) { 'OK' }
  let(:internal_reason) { 'OK' }
  let(:nonce) { 'VoYxUGHsXYtUTsc5fxFbYbt6adrwaZt45RJGzqLrPJNigemF7JuedrUJ6QwwieP1h' }
  let(:response) { 'yYmjZN2SKy92dAshXSeZWbfHPw9wKqMm5FitX5BmeGEtF7k8hiKfmgjgBohxv44bs' }
  let(:gateway_id) { 100 }

  let(:lega_request_headers) {
    {
      x_yeti_auth: x_yeti_auth,
      diversion: diversion,
      x_orig_ip: origination_ip,
      x_orig_port: origination_port,
      x_orig_proto: origination_proto_id,
      p_asserted_identity: pai,
      p_preferred_identity: ppi,
      privacy: privacy,
      remote_party_id: rpid,
      rpid_privacy: rpid_privacy
    }.to_json
  }

  let(:x_yeti_auth) { '4v96qlIguGsxVQGg' }
  let(:diversion) { ['"Diversion1" <sip:diversion1@domain>', '"Diversion2" <sip:diversion2@domain>'] }
  let(:origination_ip) { '8.8.8.8' }
  let(:origination_port) { 5070 }
  let(:origination_proto_id) { 2 }
  let(:pai) { ['"Pai1" <sip:pai1@domain>', '"Pai2" <sip:pai2@domain>'] }
  let(:ppi) { '"ppi" <sip:ppi@domain>' }
  let(:privacy) { %w[id critical] }
  let(:rpid) { ['"rpid1" <sip:rpid1@domain>', '"rpid2" <sip:rpid2@domain>'] }
  let(:rpid_privacy) { %w[full not-full] }

  context 'Create' do
    it 'creates Auth log' do
      expect { subject }.to change { Cdr::AuthLog.count }.by(1)
    end

    it 'creates Auth log with expected attributes' do
      subject
      log = Cdr::AuthLog.last
      expect(log).to have_attributes(
                       id: kind_of(Integer),
                       node_id: node_id,
                       pop_id: pop_id,
                       request_time: be_within(1.second).of(request_time),
                       transport_proto_id: transport_proto_id,
                       transport_remote_ip: transport_remote_ip,
                       transport_remote_port: transport_remote_port,
                       transport_local_ip: transport_local_ip,
                       transport_local_port: transport_local_port,
                       username: username,
                       realm: realm,
                       ruri: ruri,
                       from_uri: from_uri,
                       to_uri: to_uri,
                       call_id: call_id,
                       success: success,
                       code: code,
                       reason: reason,
                       internal_reason: internal_reason,
                       nonce: nonce,
                       response: response,
                       gateway_id: gateway_id,
                       x_yeti_auth: x_yeti_auth,
                       diversion: diversion.join(','),
                       origination_ip: origination_ip,
                       origination_port: origination_port,
                       origination_proto_id: origination_proto_id,
                       pai: pai.join(','),
                       ppi: ppi,
                       privacy: privacy.join(','),
                       rpid: rpid.join(','),
                       rpid_privacy: rpid_privacy.join(',')
                     )
    end
  end
end
