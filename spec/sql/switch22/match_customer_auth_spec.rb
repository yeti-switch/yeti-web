# frozen_string_literal: true

RSpec.describe 'switch22.match_customer_auth' do
  subject do
    SqlCaller::Yeti.select_all(sql, *sql_params).map(&:deep_symbolize_keys)
  end

  let(:sql) { 'SELECT * FROM switch22.match_customer_auth(?::integer, ?::integer, ?::inet, ?::smallint, ?::text, ?::text, ?::text, ?::text, ?::text, ?::text, ?::text)' }
  let(:sql_params) do
    [
      pop_id,
      auth_id,
      remote_ip,
      transport_protocol_id,
      x_yeti_auth,
      dst_number,
      src_number,
      uri_domain,
      to_domain,
      from_domain,
      interface
    ]
  end

  let(:pop_id) { 1 }
  let(:auth_id) { nil }
  let(:remote_ip) { '1.2.3.4' }
  let(:transport_protocol_id) { 1 }
  let(:x_yeti_auth) { nil }
  let(:dst_number) { '11' }
  let(:src_number) { '23' }
  let(:uri_domain) { 'uri-domain' }
  let(:to_domain) { 'to-domain' }
  let(:from_domain) { 'from-domain' }
  let(:interface) { 'primary' }

  let!(:ca) do
    create(:customers_auth)
  end

  it 'responds with correct rows' do
    expect(subject.size).to eq(1)
    expect(subject.first[:id]).to be_nil
    expect(subject.first[:customers_auth_id]).to be_nil
    expect(subject.first[:require_incoming_auth]).to be_nil
    expect(subject.first[:reject_calls]).to be_nil
  end

  context 'lookup by IP FOUND, OK' do
    let!(:auth_id) { nil }
    let!(:x_yeti_auth) { nil }

    let!(:cas) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0')
      end
    end

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).not_to be_nil
      expect(subject.first[:customers_auth_id]).not_to be_nil
      expect(subject.first[:require_incoming_auth]).to eq(false)
      expect(subject.first[:reject_calls]).to eq(false)
    end
  end

  context 'lookup by IP NOT FOUND, rejecting' do
    let!(:auth_id) { nil }
    let!(:x_yeti_auth) { nil }

    let!(:cas) do
      10.times do
        create(:customers_auth)
      end
    end

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).to be_nil
      expect(subject.first[:customers_auth_id]).to be_nil
      expect(subject.first[:require_incoming_auth]).to be_nil
      expect(subject.first[:reject_calls]).to be_nil
    end
  end

  context 'lookup by IP NOT FOUND, asking for auth' do
    let!(:auth_id) { nil }
    let!(:x_yeti_auth) { nil }

    let!(:cas) do
      10.times do
        create(:customers_auth)
      end
    end

    let!(:customer) do
      create(:contractor, enabled: true, customer: true)
    end
    let!(:cas_ok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).not_to be_nil
      expect(subject.first[:customers_auth_id]).not_to be_nil
      expect(subject.first[:require_incoming_auth]).to eq(true)
      expect(subject.first[:reject_calls]).to eq(false)
    end
  end

  context 'lookup by auth_id FOUND, OK' do
    let!(:x_yeti_auth) { nil }

    let!(:customer) do
      create(:contractor, enabled: true, customer: true)
    end

    let!(:cas_nok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    let!(:gw_ok) do
      create(:gateway, :with_incoming_auth, contractor: customer)
    end

    let!(:cas_ok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: gw_ok)
      end
    end
    let!(:auth_id) { gw_ok.id }

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).not_to be_nil
      expect(subject.first[:customers_auth_id]).not_to be_nil
      expect(subject.first[:require_incoming_auth]).to eq(true)
      expect(subject.first[:reject_calls]).to eq(false)
    end
  end

  context 'lookup by auth_id NOT FOUND, rejecting' do
    let!(:x_yeti_auth) { nil }

    let!(:customer) do
      create(:contractor, enabled: true, customer: true)
    end

    let!(:cas_nok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    let!(:gw_ok) do
      create(:gateway, :with_incoming_auth, contractor: customer)
    end

    let!(:cas_ok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: gw_ok)
      end
    end
    let!(:auth_id) { -11 }

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).to be_nil
      expect(subject.first[:customers_auth_id]).to be_nil
      expect(subject.first[:require_incoming_auth]).to be_nil
      expect(subject.first[:reject_calls]).to be_nil
    end
  end

  context 'lookup by X-Yeti-Auth FOUND, OK' do
    let!(:auth_id) { nil }
    let!(:x_yeti_auth) { 'XX-Yeti-Auth' }

    let!(:customer) do
      create(:contractor, enabled: true, customer: true)
    end

    let!(:cas_nok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    let!(:gw_ok) do
      create(:gateway, :with_incoming_auth, contractor: customer)
    end

    let!(:cas_ok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', x_yeti_auth: x_yeti_auth)
      end
    end

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).not_to be_nil
      expect(subject.first[:customers_auth_id]).not_to be_nil
      expect(subject.first[:require_incoming_auth]).to eq(false)
      expect(subject.first[:reject_calls]).to eq(false)
    end
  end

  context 'lookup by X-Yeti-Auth NOT FOUND, Reject' do
    let!(:auth_id) { nil }
    let!(:x_yeti_auth) { 'XX-Yeti-Auth' }

    let!(:customer) do
      create(:contractor, enabled: true, customer: true)
    end

    let!(:cas_nok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    let!(:gw_ok) do
      create(:gateway, :with_incoming_auth, contractor: customer)
    end

    let!(:cas_ok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', x_yeti_auth: rand(0..100).to_s)
      end
    end

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).to be_nil
      expect(subject.first[:customers_auth_id]).to be_nil
      expect(subject.first[:require_incoming_auth]).to be_nil
      expect(subject.first[:reject_calls]).to be_nil
    end
  end

  context 'lookup by X-Yeti-Auth FOUND, asking for auth' do
    let!(:auth_id) { nil }
    let!(:x_yeti_auth) { 'XX-Yeti-Auth' }

    let!(:customer) do
      create(:contractor, enabled: true, customer: true)
    end

    let!(:cas_nok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    let!(:gw_ok) do
      create(:gateway, :with_incoming_auth, contractor: customer)
    end

    let!(:cas_ok) do
      10.times do
        create(:customers_auth, ip: '0.0.0.0/0', x_yeti_auth: x_yeti_auth, require_incoming_auth: true, gateway: create(:gateway, :with_incoming_auth, contractor: customer))
      end
    end

    it 'responds with correct rows' do
      expect(subject.size).to eq(1)
      expect(subject.first[:id]).not_to be_nil
      expect(subject.first[:customers_auth_id]).not_to be_nil
      expect(subject.first[:require_incoming_auth]).to eq(true)
      expect(subject.first[:reject_calls]).to eq(false)
    end
  end
end
