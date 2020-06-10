# frozen_string_literal: true

RSpec.describe Api::Rest::System::IpAccessController, type: :controller do
  describe '#index' do
    subject { get :index, params: { format: :json } }

    context 'when CustomersAuth records exist' do
      before do
        create(:customers_auth) # default ip='127.0.0.0/8'
        create(:customers_auth, ip: '192.168.0.0/16')
        create(:customers_auth, ip: '2001:67c:1324:111::1/64')
      end

      let(:expected_response) do
        ['127.0.0.0/8', '192.168.0.0/16', '2001:67c:1324:111::/64']
      end

      it 'returns array of all CustomersAuth IPs' do
        subject
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end

    context 'without any records of CustomersAuth' do
      it 'returns empty array' do
        subject
        expect(JSON.parse(response.body)).to match_array([])
      end
    end
  end
end
