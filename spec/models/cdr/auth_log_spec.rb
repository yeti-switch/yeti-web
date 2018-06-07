require 'spec_helper'

RSpec.describe Cdr::AuthLog, type: :model do

  before {described_class.destroy_all}
  after {described_class.destroy_all}

  let(:db_connection) {described_class.connection}

  it {expect(described_class.count).to eq(0)}

  describe 'Function "switch.write_auth_log()"' do

    subject do
      db_connection.execute("SELECT switch.write_auth_log(#{auth_log_parameters});")
    end

    let(:request_time) {10.minutes.ago}

    let(:auth_log_parameters) do
      %Q{

    true::boolean,
    10::integer,
    1::integer,
    '#{request_time.to_f}'::double precision,
    '1.1.1.1'::varchar,
    5060::integer,
    '2.2.2.2'::varchar,
    6050::integer,
    'sip:test@localhost.com'::varchar,
    'sip:test@localhost.com'::varchar,
    'sip:test@localhost.com'::varchar,
    'wqewqewq'::varchar,
    true::boolean,
    200::smallint,
    'OK'::varchar,
    'OK'::varchar,
    '11231es221'::varchar,
    '11231es221'::varchar,
    11::integer

      }
    end

    it 'creates new Auth Log record' do
      expect {subject}.to change {described_class.count}.by(1)
    end

    it 'creates Auth Log with expected attributes' do
      subject
      expect(described_class.last.attributes.symbolize_keys).to match(
                                                                    {
                                                                        id: kind_of(Integer),
                                                                        auth_orig_ip: nil,
                                                                        auth_orig_port: nil,
                                                                        code: 200,
                                                                        from_uri: "sip:test@localhost.com",
                                                                        gateway_id: 11,
                                                                        internal_reason: "OK",
                                                                        node_id: 10,
                                                                        nonce: "11231es221",
                                                                        orig_call_id: "wqewqewq",
                                                                        pop_id: 1,
                                                                        reason: "OK",
                                                                        request_time: be_within(2.second).of(request_time),
                                                                        response: "11231es221",
                                                                        ruri: "sip:test@localhost.com",
                                                                        sign_orig_ip: "1.1.1.1",
                                                                        sign_orig_local_ip: "2.2.2.2",
                                                                        sign_orig_local_port: 6050,
                                                                        sign_orig_port: 5060,
                                                                        success: true,
                                                                        to_uri: "sip:test@localhost.com"
                                                                    }
                                                                )
    end


  end

end
