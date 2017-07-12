require 'spec_helper'

describe Api::Rest::Private::RoutingPlansController, type: :controller do

  before { request.accept = 'application/json' }

  describe 'GET index' do
    let!(:routing_plans) { create_list :routing_plan, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(assigns(:routing_plans)).to match_array(routing_plans) }
  end

  describe 'GET show' do
    let!(:routing_plan) { create :routing_plan }

    context 'when routing_plan exists' do
      before { get :show, id: routing_plan.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(assigns(:routing_plan)).to eq(routing_plan) }
    end

    context 'when routing_plan does not exist' do
      before { get :show, id: routing_plan.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(assigns(:routing_plan)).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, routing_plan: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', use_lnp: true } }

      it { expect(response.status).to eq(201) }
      it { expect(Routing::RoutingPlan.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil, use_lnp: true } }

      it { expect(response.status).to eq(422) }
      it { expect(Routing::RoutingPlan.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:routing_plan) { create :routing_plan }
    before { put :update, id: routing_plan.to_param, routing_plan: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', use_lnp: true } }

      it { expect(response.status).to eq(204) }
      it { expect(routing_plan.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil, use_lnp: true } }

      it { expect(response.status).to eq(422) }
      it { expect(routing_plan.reload.name).to_not eq(nil) }
    end
  end

  describe 'DELETE destroy' do
    let!(:routing_plan) { create :routing_plan }

    before { delete :destroy, id: routing_plan.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::RoutingPlan.count).to eq(0) }
  end
end

