require 'spec_helper'

RSpec.describe '#routing logic' do
  subject do
    CallSql::Yeti.select_all_serialized(
        '

SELECT * from switch16.route(
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
        )',
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

  before {FactoryGirl.create(:customers_auth)}

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
  let(:pai) {'pAI'}
  let(:ppi) {'ppi'}
  let(:privacy) {'privacy'}
  let(:rpid) {'rpid'}
  let(:rpid_privacy) {'rpid-privacy'}

  it ' return 404 ' do
    response=subject
  end

end
