require 'spec_helper'

describe Api::Rest::Private::DestinationsController, type: :controller do
  let(:rateplan) { create :rateplan }

  before { request.accept = 'application/json' }

  describe 'GET index' do
    let!(:destinations) { create_list :destination, 2, rateplan: rateplan }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(assigns(:destinations)).to match_array(destinations) }
  end

  describe 'GET show' do
    let!(:destination) { create :destination }

    context 'when destination exists' do
      before { get :show, id: destination.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(assigns(:destination)).to eq(destination) }
    end

    context 'when destination does not exist' do
      before { get :show, id: destination.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(assigns(:destination)).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, destination: attributes }

    context 'when attributes are valid' do
      let(:attributes) do
        { prefix: 'test',
          rateplan_id: rateplan.id,
          enabled: true,
          initial_interval: 60,
          next_interval: 60,
          initial_rate: 0,
          next_rate: 0,
          connect_fee: 0,
          dp_margin_fixed: 0,
          dp_margin_percent: 0,
          rate_policy_id: 1
        }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Destination.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test' } }

      it { expect(response.status).to eq(422) }
      it { expect(Destination.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:destination) { create :destination, rateplan: rateplan }
    before { put :update, id: destination.to_param, destination: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { prefix: 'test' } }

      it { expect(response.status).to eq(204) }
      it { expect(destination.reload.prefix).to eq('test') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test', rateplan_id: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(destination.reload.prefix).to_not eq('test') }
    end
  end

  describe 'DELETE destroy' do
    let!(:destination) { create :destination, rateplan: rateplan }

    before { delete :destroy, id: destination.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(Destination.count).to eq(0) }
  end
end

