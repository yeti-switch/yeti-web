require 'spec_helper'

describe Api::Rest::Private::RoutingGroupsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:routing_groups) { create_list :routing_group, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(assigns(:routing_groups)).to match_array(routing_groups) }
  end

  describe 'GET show' do
    let!(:routing_group) { create :routing_group }

    context 'when routing_group exists' do
      before { get :show, id: routing_group.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(assigns(:routing_group)).to eq(routing_group) }
    end

    context 'when routing_group does not exist' do
      before { get :show, id: routing_group.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(assigns(:routing_group)).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, routing_group: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }

      it { expect(response.status).to eq(201) }
      it { expect(RoutingGroup.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(RoutingGroup.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:routing_group) { create :routing_group }
    before { put :update, id: routing_group.to_param, routing_group: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }

      it { expect(response.status).to eq(204) }
      it { expect(routing_group.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(routing_group.reload.name).to_not eq(nil) }
    end
  end

  describe 'DELETE destroy' do
    let!(:routing_group) { create :routing_group }

    before { delete :destroy, id: routing_group.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(RoutingGroup.count).to eq(0) }
  end
end

