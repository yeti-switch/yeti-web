# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::DestinationsController, type: :controller do
  let(:rate_group) { create :rate_group }

  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:destinations) { create_list :destination, 2, rate_group: rate_group }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(destinations.size) }
  end

  describe 'GET index with filters' do
    subject do
      get :index, params: json_api_request_query
    end
    before { create_list :destination, 2 }

    it_behaves_like :jsonapi_filter_by_external_id do
      let(:subject_record) { create(:destination) }
    end

    it_behaves_like :jsonapi_filter_by, :prefix do
      include_context :ransack_filter_setup
      let(:filter_key) { :prefix }
      let(:filter_value) { subject_record.prefix }
      let(:subject_record) { create :destination, prefix: attr_value }
      let(:attr_value) { '987' }
    end

    it_behaves_like :jsonapi_filter_by, :rate_group_id do
      include_context :ransack_filter_setup
      let(:filter_key) { :rate_group_id }
      let(:filter_value) { subject_record.rate_group_id }
      let(:subject_record) { create :destination, rate_group: rate_group }
      let(:attr_value) { subject_record.rate_group_id }
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :destination }

    it_behaves_like :jsonapi_filters_by_boolean_field, :enabled
    it_behaves_like :jsonapi_filters_by_string_field, :prefix
    it_behaves_like :jsonapi_filters_by_number_field, :next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :connect_fee
    it_behaves_like :jsonapi_filters_by_number_field, :initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :dp_margin_fixed
    it_behaves_like :jsonapi_filters_by_number_field, :dp_margin_percent
    it_behaves_like :jsonapi_filters_by_number_field, :initial_rate
    it_behaves_like :jsonapi_filters_by_boolean_field, :reject_calls
    it_behaves_like :jsonapi_filters_by_boolean_field, :use_dp_intervals
    it_behaves_like :jsonapi_filters_by_datetime_field, :valid_from
    it_behaves_like :jsonapi_filters_by_datetime_field, :valid_till
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
    it_behaves_like :jsonapi_filters_by_number_field, :asr_limit
    it_behaves_like :jsonapi_filters_by_number_field, :acd_limit
    it_behaves_like :jsonapi_filters_by_number_field, :short_calls_limit
    it_behaves_like :jsonapi_filters_by_boolean_field, :quality_alarm
    it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_min_length
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_max_length
    it_behaves_like :jsonapi_filters_by_boolean_field, :reverse_billing
  end

  describe 'GET show' do
    let!(:destination) { create :destination }

    context 'when destination exists' do
      before { get :show, params: { id: destination.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(destination.id.to_s) }
    end

    context 'when destination does not exist' do
      before { get :show, params: { id: destination.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'destinations',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) do
        { prefix: 'test',
          enabled: true,
          'reverse-billing': true,
          'initial-interval': 60,
          'next-interval': 60,
          'initial-rate': 0,
          'next-rate': 0,
          'connect-fee': 0,
          'dp-margin-fixed': 0,
          'dp-margin-percent': 0,
          'profit-control-mode-id': Routing::RateProfitControlMode::MODE_PER_CALL,
          'rate-policy-id': Routing::DestinationRatePolicy::POLICY_MIN }
      end

      let(:relationships) do
        { 'rate-group': wrap_relationship(:'rate-groups', create(:rate_group).id),
          'routing-tag-mode': wrap_relationship(:'routing-tag-modes', 1) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Routing::Destination.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test' } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Routing::Destination.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:destination) { create :destination, rate_group: rate_group }
    before do
      put :update, params: {
        id: destination.to_param, data: { type: 'destinations',
                                          id: destination.to_param,
                                          attributes: attributes,
                                          relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { prefix: 'test' } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(200) }
      it { expect(destination.reload.prefix).to eq('test') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { prefix: 'test' } }
      let(:relationships) do
        { 'rate-group': wrap_relationship(:'rate-groups', nil) }
      end

      it { expect(response.status).to eq(422) }
      it { expect(destination.reload.prefix).to_not eq('test') }
    end
  end

  describe 'DELETE destroy' do
    let!(:destination) { create :destination, rate_group: rate_group }

    before { delete :destroy, params: { id: destination.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::Destination.count).to eq(0) }
  end

  describe 'editable routing_tag_ids' do
    include_examples :jsonapi_resource_with_routing_tag_ids do
      let(:resource_type) { 'destinations' }
      let(:factory_name) { :destination }
    end
  end
end
