# frozen_string_literal: true

RSpec.describe 'switch22.load_ip_auth2' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_ip_auth2(NULL::integer, NULL::integer)'
  end

  context 'when no customers_auth exist' do
    it 'returns empty result' do
      expect(subject).to be_empty
    end
  end

  context 'when enabled customers_auth exist' do
    let!(:ca1) { create(:customers_auth, ip: '1.2.3.4') }
    let!(:ca2) { create(:customers_auth, :with_incoming_auth, ip: '2.3.4.5') }

    it 'returns one row per normalized record ordered by ip' do
      expect(subject.size).to eq(2)
      expect(subject.first[:ip]).to eq('1.2.3.4')
      expect(subject.second[:ip]).to eq('2.3.4.5')
    end

    it 'returns correct require_incoming_auth per row' do
      expect(subject.first[:require_incoming_auth]).to eq(false)
      expect(subject.second[:require_incoming_auth]).to eq(true)
    end

    it 'always returns require_identity_parsing as true' do
      expect(subject).to all(include(require_identity_parsing: true))
    end
  end

  context 'when disabled customers_auth exist' do
    let!(:ca_enabled)  { create(:customers_auth, ip: '1.2.3.4', enabled: true) }
    let!(:ca_disabled) { create(:customers_auth, ip: '9.9.9.9', enabled: false) }

    it 'excludes disabled records' do
      ips = subject.map { |r| r[:ip] }
      expect(ips).to include('1.2.3.4')
      expect(ips).not_to include('9.9.9.9')
    end
  end

  context 'when multiple records share the same ip' do
    let!(:ca1) { create(:customers_auth, ip: '1.2.3.4') }
    let!(:ca2) { create(:customers_auth, :with_incoming_auth, ip: '1.2.3.4') }

    it 'returns a separate row for each record without grouping' do
      rows_for_ip = subject.select { |r| r[:ip] == '1.2.3.4' }
      expect(rows_for_ip.size).to eq(2)
      expect(rows_for_ip.map { |r| r[:require_incoming_auth] }).to contain_exactly(true, false)
    end
  end
end
