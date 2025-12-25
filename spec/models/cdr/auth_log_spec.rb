# frozen_string_literal: true

# == Schema Information
#
# Table name: auth_log.auth_log
#
#  id                    :bigint(8)        not null, primary key
#  code                  :integer(2)
#  diversion             :string
#  from_uri              :string
#  internal_reason       :string
#  nonce                 :string
#  origination_ip        :inet
#  origination_port      :integer(4)
#  pai                   :string
#  ppi                   :string
#  privacy               :string
#  realm                 :string
#  reason                :string
#  request_method        :string
#  request_time          :timestamptz      not null
#  response              :string
#  rpid                  :string
#  rpid_privacy          :string
#  ruri                  :string
#  success               :boolean
#  to_uri                :string
#  transport_local_ip    :inet
#  transport_local_port  :integer(4)
#  transport_remote_ip   :inet
#  transport_remote_port :integer(4)
#  username              :string
#  x_yeti_auth           :string
#  auth_error_id         :integer(2)
#  call_id               :string
#  gateway_id            :integer(4)
#  node_id               :integer(2)
#  origination_proto_id  :integer(2)
#  pop_id                :integer(2)
#  transport_proto_id    :integer(2)
#
# Indexes
#
#  auth_log_id_idx            (id)
#  auth_log_request_time_idx  (request_time)
#

RSpec.describe Cdr::AuthLog, type: :model do
  before { described_class.destroy_all }
  after { described_class.destroy_all }

  let(:db_connection) { described_class.connection }

  it { expect(described_class.count).to eq(0) }

  describe 'Function "switch.write_auth_log()"' do
    subject do
      db_connection.execute("SELECT switch.write_auth_log(#{auth_log_parameters});")
    end

    let(:request_time) { 10.minutes.ago }

    let(:auth_log_parameters) do
      %(

    true::boolean, -- master
    10::integer, -- node_id
    1::integer, -- pop_id
    '#{request_time.to_f}'::double precision,
    2::smallint, -- transport protocol
    '1.1.1.1'::varchar,
    5060::integer,
    '2.2.2.2'::varchar,
    6050::integer,
    'vasya pupkin',
    'realm value',
    'INVITE', --method
    'sip:ruri@localhost.com'::varchar,
    'sip:from@localhost.com'::varchar,
    'sip:to@localhost.com'::varchar,
    'wqewqewq'::varchar,
    true::boolean,
    200::smallint,
    'OK'::varchar,
    'OK'::varchar,
    '11231es221'::varchar,
    '11231es221'::varchar,
    11::integer,
    'X-YETI-AUTH value',
    'Diversion value',
    '8.8.8.8',
    '6767',
    1::smallint,
    'PAI value',
    'PPI value',
    'privacy value',
    'rpid value',
    'rpid privacy value'
      )
    end

    it 'creates new Auth Log record' do
      expect { subject }.to change { described_class.count }.by(1)
    end

    it 'creates Auth Log with expected attributes' do
      subject
      expect(described_class.last.attributes.symbolize_keys).to match(
        id: kind_of(Integer),
        request_time: be_within(2.seconds).of(request_time),

        transport_proto_id: 2,
        transport_remote_ip: '1.1.1.1',
        transport_remote_port: 5060,
        transport_local_ip: '2.2.2.2',
        transport_local_port: 6050,
        origination_ip: '8.8.8.8',
        origination_port: 6767,
        origination_proto_id: 1,

        username: 'vasya pupkin',
        realm: 'realm value',
        request_method: 'INVITE',
        ruri: 'sip:ruri@localhost.com',
        from_uri: 'sip:from@localhost.com',
        to_uri: 'sip:to@localhost.com',
        code: 200,

        gateway_id: 11,
        internal_reason: 'OK',
        node_id: 10,
        nonce: '11231es221',
        call_id: 'wqewqewq',
        pop_id: 1,
        reason: 'OK',

        response: '11231es221',
        success: true,
        x_yeti_auth: 'X-YETI-AUTH value',
        diversion: 'Diversion value',
        pai: 'PAI value',
        ppi: 'PPI value',
        privacy: 'privacy value',
        rpid: 'rpid value',
        rpid_privacy: 'rpid privacy value'
      )
    end
  end
end
