require 'spec_helper'

describe Api::Rest::Private::GatewayGroupsController, type: :controller do
  let(:vendor) { create :contractor, vendor: true }

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:gateway_groups) { create_list :gateway_group, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(gateway_groups.size) }
  end

  describe 'GET show' do
    let!(:gateway_group) { create :gateway_group }

    context 'when gateway_group exists' do
      before { get :show, id: gateway_group.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(gateway_group.id.to_s) }
    end

    context 'when gateway_group does not exist' do
      before { get :show, id: gateway_group.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, data: { type: 'gateway-groups', attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', 'vendor-id': vendor.id } }

      it { expect(response.status).to eq(201) }
      it { expect(GatewayGroup.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(GatewayGroup.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:gateway_group) { create :gateway_group }
    before { put :update, id: gateway_group.to_param, data: { type: 'gateway-groups',
                                                              id: gateway_group.to_param,
                                                              attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', 'vendor-id': vendor.id } }

      it { expect(response.status).to eq(200) }
      it { expect(gateway_group.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(gateway_group.reload.name).to_not eq(nil) }
    end
  end

  describe 'DELETE destroy' do
    let!(:gateway_group) { create :gateway_group }

    before { delete :destroy, id: gateway_group.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(GatewayGroup.count).to eq(0) }
  end
end

