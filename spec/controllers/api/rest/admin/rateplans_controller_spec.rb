require 'spec_helper'

describe Api::Rest::Admin::RateplansController, type: :controller do
  let(:rpcm) { create :rate_profit_control_mode }

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:rateplans) { create_list :rateplan, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(rateplans.size) }
  end

  describe 'GET show' do
    let!(:rateplan) { create :rateplan }

    context 'when rateplan exists' do
      before { get :show, id: rateplan.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(rateplan.id.to_s) }
    end

    context 'when rateplan does not exist' do
      before { get :show, id: rateplan.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, data: { type: 'rateplans',
                            attributes: attributes,
                            relationships: relationships }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) do
        { 'profit-control-mode': wrap_relationship(:'rate_profit_control_modes', rpcm.id) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Rateplan.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Rateplan.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:rateplan) { create :rateplan }
    before { put :update, id: rateplan.to_param, data: { type: 'rateplans',
                                                         id: rateplan.to_param,
                                                         attributes: attributes,
                                                         relationships: relationships} }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) do
        { 'profit-control-mode': wrap_relationship(:'rate_profit_control_modes', rpcm.id) }
      end

      it { expect(response.status).to eq(200) }
      it { expect(rateplan.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }
      let(:relationships) { {} }

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

