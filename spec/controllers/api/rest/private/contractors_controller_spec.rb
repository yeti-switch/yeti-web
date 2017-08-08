require 'spec_helper'

describe Api::Rest::Private::ContractorsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:contractors) { create_list :contractor, 2, vendor: true }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(contractors.size) }
  end

  describe 'GET show' do
    let!(:contractor) { create :contractor, vendor: true }

    context 'when contractor exists' do
      before { get :show, id: contractor.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(contractor.id.to_s) }
    end

    context 'when contractor does not exist' do
      before { get :show, id: contractor.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(assigns(:contractor)).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, data: { type: 'contractors', attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', vendor: true } }

      it { expect(response.status).to eq(201) }
      it { expect(Contractor.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { vendor: false, customer: false } }

      it { expect(response.status).to eq(422) }
      it { expect(Contractor.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:contractor) { create :contractor, vendor: true }
    before { put :update, id: contractor.to_param, data: { type: 'contractors', id: contractor.to_param, attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }

      it { expect(response.status).to eq(200) }
      it { expect(contractor.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { vendor: false, customer: false } }

      it { expect(response.status).to eq(422) }
      it { expect(contractor.reload.vendor).to_not eq(false) }
    end
  end

  describe 'DELETE destroy' do
    let!(:contractor) { create :contractor, vendor: true }

    before { delete :destroy, id: contractor.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(Contractor.count).to eq(0) }
  end
end

