# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::RateplansController, type: :controller do
  let(:rpcm) { Routing::RateProfitControlMode.last }

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

  describe 'GET index with filters' do
    subject do
      get :index, params: json_api_request_query
    end
    before { create_list :rateplan, 2 }

    it_behaves_like :jsonapi_filter_by_name do
      let(:subject_record) { create :rateplan }
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :rateplan }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end

  describe 'GET show' do
    let!(:rateplan) { create :rateplan }

    context 'when rateplan exists' do
      before { get :show, params: { id: rateplan.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(rateplan.id.to_s) }
    end

    context 'when rateplan does not exist' do
      before { get :show, params: { id: rateplan.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'rateplans',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) do
        { 'profit-control-mode': wrap_relationship(:rate_profit_control_modes, rpcm.id) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Routing::Rateplan.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Routing::Rateplan.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:rateplan) { create :rateplan }
    before do
      put :update, params: {
        id: rateplan.to_param, data: { type: 'rateplans',
                                       id: rateplan.to_param,
                                       attributes: attributes,
                                       relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) do
        { 'profit-control-mode': wrap_relationship(:rate_profit_control_modes, rpcm.id) }
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

    before { delete :destroy, params: { id: rateplan.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::Rateplan.count).to eq(0) }
  end
end
