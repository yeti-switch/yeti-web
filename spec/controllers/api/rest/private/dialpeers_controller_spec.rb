require 'spec_helper'

describe Api::Rest::Private::DialpeersController, type: :controller do
  before { request.accept = 'application/json' }

  describe 'GET index' do
    let!(:dialpeers) { create_list :dialpeer, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(assigns(:dialpeers)).to match_array(dialpeers) }
  end

  describe 'GET show' do
    let!(:dialpeer) { create :dialpeer }

    context 'when dialpeer exists' do
      before { get :show, id: dialpeer.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(assigns(:dialpeer)).to eq(dialpeer) }
    end

    context 'when dialpeer does not exist' do
      before { get :show, id: dialpeer.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(assigns(:dialpeer)).to eq(nil) }
    end
  end

  describe 'POST create' do
    let(:vendor) { create :contractor, vendor: true }
    let(:account) { create :account, contractor: vendor }
    let(:gateway_group) { create :gateway_group, vendor: vendor }
    let(:routing_group) { create :routing_group }
    before { post :create, dialpeer: attributes }

    context 'when attributes are valid' do
      let(:attributes) do
        {
          enabled: true,
          vendor_id: vendor.id,
          account_id: account.id,
          gateway_group_id: gateway_group.id,
          routing_group_id: routing_group.id,
          valid_from: DateTime.now,
          valid_till: 1.year.from_now,
          initial_interval: 60,
          next_interval: 60,
          initial_rate: 0.0,
          next_rate: 0.0,
          connection_fee: 0.0
        }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Dialpeer.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { enabled: true, vendor_id: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(Dialpeer.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:dialpeer) { create :dialpeer }
    before { put :update, id: dialpeer.to_param, dialpeer: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { next_interval: 90 } }

      it { expect(response.status).to eq(204) }
      it { expect(dialpeer.reload.next_interval).to eq(90) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { next_interval: 90, vendor_id: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(dialpeer.reload.next_interval).to_not eq(90) }
    end
  end

  describe 'DELETE destroy' do
    let!(:dialpeer) { create :dialpeer }

    before { delete :destroy, id: dialpeer.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(Dialpeer.count).to eq(0) }
  end
end

