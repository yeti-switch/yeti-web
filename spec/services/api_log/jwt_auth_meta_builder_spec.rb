# frozen_string_literal: true

RSpec.describe ApiLog::JwtAuthMetaBuilder do
  subject(:service_call) { described_class.new(payload:).call }

  context 'when payload is nil' do
    let(:payload) { nil }

    it 'returns nil' do
      expect(service_call).to be_nil
    end
  end

  context 'when payload has common claims only' do
    let(:payload) { { aud: ['customer-v1'], sub: 101 } }

    it 'returns aud/sub only' do
      expect(service_call).to eq(
        'aud' => ['customer-v1'],
        'sub' => 101
      )
    end
  end

  context 'when payload has dynamic cfg claims' do
    let(:payload) do
      {
        aud: ['customer-v1'],
        sub: 'D',
        cfg: {
          customer_id: 10,
          account_ids: [1, 2],
          allow_listen_recording: true,
          allow_outgoing_numberlists_ids: [5],
          allowed_ips: ['0.0.0.0/0'],
          customer_portal_access_profile_id: 7,
          provision_gateway_id: 12,
          unexpected: 'skip-me'
        }
      }
    end

    it 'filters cfg by allowlist' do
      expect(service_call).to eq(
        'aud' => ['customer-v1'],
        'sub' => 'D',
        'cfg' => {
          'customer_id' => 10,
          'account_ids' => [1, 2],
          'allow_listen_recording' => true,
          'allow_outgoing_numberlists_ids' => [5],
          'allowed_ips' => ['0.0.0.0/0'],
          'customer_portal_access_profile_id' => 7,
          'provision_gateway_id' => 12
        }
      )
    end
  end
end
