require 'spec_helper'

describe Api::Rest::Private::DestinationsController, type: :controller do
  let(:rateplan) { create :rateplan }

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:destinations) { create_list :destination, 2, rateplan: rateplan }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(destinations.size) }
  end

  describe 'GET show' do
    let!(:destination) { create :destination }

    context 'when destination exists' do
      before { get :show, id: destination.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(destination.id.to_s) }
    end

    context 'when destination does not exist' do
      before { get :show, id: destination.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, data: { type: 'destinations', attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) do
        { prefix: 'test',
          'rateplan-id': rateplan.id,
          enabled: true,
          'initial-interval': 60,
          'next-interval': 60,
          'initial-rate': 0,
          'next-rate': 0,
          'connect-fee': 0,
          'dp-margin-fixed': 0,
          'dp-margin-percent': 0,
          'rate-policy-id': 1
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
    before { put :update, id: destination.to_param, data: { type: 'destinations',
                                                            id: destination.to_param,
                                                            attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { prefix: 'test' } }

      it { expect(response.status).to eq(200) }
      it { expect(destination.reload.prefix).to eq('test') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test', 'rateplan-id': nil } }

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

