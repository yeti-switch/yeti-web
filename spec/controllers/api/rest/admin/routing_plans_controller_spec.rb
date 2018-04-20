require 'spec_helper'

describe Api::Rest::Admin::RoutingPlansController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:routing_plans) { create_list :routing_plan, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(routing_plans.size) }
  end

  describe 'GET index with filters' do
    before { create_list :routing_plan, 2 }

    it_behaves_like :jsonapi_filter_by_name do
      let(:subject_record) { create :routing_plan }
    end
  end

  describe 'GET show' do
    let!(:routing_plan) { create :routing_plan }

    context 'when routing_plan exists' do
      before { get :show, params: { id: routing_plan.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(routing_plan.id.to_s) }
    end

    context 'when routing_plan does not exist' do
      before { get :show, params: { id: routing_plan.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, params: { data: { type: 'routing-plans', attributes: attributes } } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', 'use-lnp': true } }

      it { expect(response.status).to eq(201) }
      it { expect(Routing::RoutingPlan.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil, 'use-lnp': true } }

      it { expect(response.status).to eq(422) }
      it { expect(Routing::RoutingPlan.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:routing_plan) { create :routing_plan }
    before { put :update, params: {
      id: routing_plan.to_param, data: { type: 'routing-plans',
                                         id: routing_plan.to_param,
                                         attributes: attributes }
    } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', 'use-lnp': true } }

      it { expect(response.status).to eq(200) }
      it { expect(routing_plan.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil, 'use-lnp': true } }

      it { expect(response.status).to eq(422) }
      it { expect(routing_plan.reload.name).to_not eq(nil) }
    end
  end

  describe 'DELETE destroy' do
    let!(:routing_plan) { create :routing_plan }

    before { delete :destroy, params: { id: routing_plan.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::RoutingPlan.count).to eq(0) }
  end
end
