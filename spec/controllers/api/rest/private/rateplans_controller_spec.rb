require 'spec_helper'

describe Api::Rest::Private::RateplansController, type: :controller do
  let(:rpcm) { create :rate_profit_control_mode }

  before { request.accept = 'application/json' }

  describe 'GET index' do
    let!(:rateplans) { create_list :rateplan, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(assigns(:rateplans)).to match_array(rateplans) }
  end

  describe 'GET show' do
    let!(:rateplan) { create :rateplan }

    context 'when rateplan exists' do
      before { get :show, id: rateplan.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(assigns(:rateplan)).to eq(rateplan) }
    end

    context 'when rateplan does not exist' do
      before { get :show, id: rateplan.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(assigns(:rateplan)).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, rateplan: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', profit_control_mode_id: rpcm.id } }

      it { expect(response.status).to eq(201) }
      it { expect(Rateplan.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(Rateplan.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:rateplan) { create :rateplan }
    before { put :update, id: rateplan.to_param, rateplan: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', profit_control_mode_id: rpcm.id } }

      it { expect(response.status).to eq(204) }
      it { expect(rateplan.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(rateplan.reload.name).to_not eq(nil) }
    end
  end

  describe 'DELETE destroy' do
    let!(:rateplan) { create :rateplan }

    before { delete :destroy, id: rateplan.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(Rateplan.count).to eq(0) }
  end
end

