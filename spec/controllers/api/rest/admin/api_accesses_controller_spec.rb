# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ApiAccessesController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:api_access) { create_list :api_access, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(api_access.size) }
  end

  describe 'GET show' do
    let!(:api_access) { create :api_access }
    before { get :show, params: { id: api_access.id } }

    it 'all fields except password ' do
      expect(response_data).to include(
        'id' => api_access.id.to_s,
        'type' => 'api-accesses',
        'links' => anything,
        'attributes' => {
          'customer-id' => api_access.customer_id,
          'login' => api_access.login,
          'account-ids' => api_access.account_ids,
          'allowed-ips' => api_access.allowed_ips.map(&:to_s),
          'allow-listen-recording' => api_access.allow_listen_recording
        }
      )
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'api-accesses',
                attributes: attributes }
      }
    end

    let(:customer) { create(:customer) }

    let(:attributes) do
      {
        'customer-id': customer.id.to_s,
        login: 'create-login',
        password: '111111',
        'allowed-ips': ['127.0.0.7', '127.0.0.8']
      }
    end

    it { expect(response.status).to eq(201) }
    it { expect(System::ApiAccess.count).to eq(1) }
  end

  describe 'PUT update' do
    let!(:api_access) { create :api_access }

    before do
      put :update, params: {
        id: api_access.id,
        data: { type: 'api-accesses',
                id: api_access.id,
                attributes: attributes }
      }
    end

    let(:attributes) do
      {
        login: 'update-login',
        password: 'update-111111',
        'allowed-ips': ['127.0.0.7', '127.0.0.8']
      }
    end

    it { expect(response.status).to eq(200) }

    it 'update succesfully' do
      expect(System::ApiAccess.find(api_access.id)).to have_attributes(
        login: attributes[:login],
        allowed_ips: attributes[:'allowed-ips'].map { |ip| IPAddr.new(ip) }
      )
    end
  end

  describe 'DELETE destroy' do
    let!(:api_access) { create :api_access }

    before { delete :destroy, params: { id: api_access.id } }

    it { expect(response.status).to eq(204) }
    it { expect(System::ApiAccess.count).to eq(0) }
  end
end
