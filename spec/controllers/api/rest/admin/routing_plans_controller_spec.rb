# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RoutingPlansController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:routing_plans) { create_list :routing_plan, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(routing_plans.size) }
  end

  describe 'GET index with filters' do
    subject do
      get :index, params: json_api_request_query
    end
    before { create_list :routing_plan, 2 }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filter_by_name do
      let(:subject_record) { create :routing_plan }
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :routing_plan }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_number_field, :rate_delta_max
    it_behaves_like :jsonapi_filters_by_boolean_field, :use_lnp
    it_behaves_like :jsonapi_filters_by_number_field, :max_rerouting_attempts
    it_behaves_like :jsonapi_filters_by_boolean_field, :validate_dst_number_format
    it_behaves_like :jsonapi_filters_by_boolean_field, :validate_dst_number_network
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
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

    context 'when include=routing_groups' do
      subject { get :show, params: { id: routing_plan.to_param, include: 'routing-groups' } }

      it 'response body should be valid' do
        subject

        expect(response_data['id']).to eq(routing_plan.id.to_s)
        expect(response_data.dig('relationships', 'routing-groups', 'data')).to eq([])
      end
    end
  end

  describe 'POST create' do
    subject { post :create, params: { data: { type: 'routing-plans', attributes: attributes } } }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', 'use-lnp': true, 'max-rerouting-attempts': 9 } }

      it 'creates routing plan' do
        subject
        expect(response.status).to eq(201)
        expect(Routing::RoutingPlan.count).to eq(1)
      end
    end

    context 'with validation and external-id attributes' do
      let(:attributes) do
        {
          name: 'name',
          'validate-dst-number-format': true,
          'validate-dst-number-network': true,
          'external-id': 123
        }
      end

      it 'creates routing plan with given attributes' do
        subject
        expect(response.status).to eq(201)
        expect(Routing::RoutingPlan.last!).to have_attributes(
                                                validate_dst_number_format: true,
                                                validate_dst_number_network: true,
                                                external_id: 123
                                              )
        expect(response_data['attributes']).to include(
                                                 'validate-dst-number-format' => true,
                                                 'validate-dst-number-network' => true,
                                                 'external-id' => 123
                                               )
      end
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil, 'use-lnp': true, 'max-rerouting-attempts': 11 } }

      it 'does not create routing plan' do
        subject
        expect(response.status).to eq(422)
        expect(Routing::RoutingPlan.count).to eq(0)
      end
    end

    context 'when external-id is already taken' do
      let!(:existing_routing_plan) { create :routing_plan, external_id: 123 }
      let(:attributes) { { name: 'other name', 'external-id': 123 } }

      it 'does not create routing plan' do
        expect { subject }.not_to change { Routing::RoutingPlan.count }
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT update' do
    let!(:routing_plan) { create :routing_plan }
    before do
      put :update, params: {
        id: routing_plan.to_param, data: { type: 'routing-plans',
                                           id: routing_plan.to_param,
                                           attributes: attributes }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', 'use-lnp': true, 'max-rerouting-attempts': 7 } }

      it { expect(response.status).to eq(200) }
      it { expect(routing_plan.reload.name).to eq('name') }
    end

    context 'with validation and external-id attributes' do
      let(:attributes) do
        {
          'validate-dst-number-format': true,
          'validate-dst-number-network': true,
          'external-id': 456
        }
      end

      it 'updates routing plan' do
        expect(response.status).to eq(200)
        expect(routing_plan.reload).to have_attributes(
                                         validate_dst_number_format: true,
                                         validate_dst_number_network: true,
                                         external_id: 456
                                       )
      end
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil, 'use-lnp': true, 'max-rerouting-attempts': 12 } }

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
