# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CustomersAuthsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:customers_auths) { create_list :customers_auth, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(customers_auths.size) }
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :customers_auth }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_boolean_field, :enabled
    it_behaves_like :jsonapi_filters_by_boolean_field, :reject_calls
    it_behaves_like :jsonapi_filters_by_string_field, :src_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :src_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :dst_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :dst_rewrite_result
    it_behaves_like :jsonapi_filters_by_number_field, :src_number_min_length
    it_behaves_like :jsonapi_filters_by_number_field, :src_number_max_length
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_min_length
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_max_length
    it_behaves_like :jsonapi_filters_by_number_field, :capacity
    it_behaves_like :jsonapi_filters_by_string_field, :src_name_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :src_name_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :diversion_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :diversion_rewrite_result
    it_behaves_like :jsonapi_filters_by_boolean_field, :allow_receive_rate_limit
    it_behaves_like :jsonapi_filters_by_boolean_field, :send_billing_information
    it_behaves_like :jsonapi_filters_by_boolean_field, :enable_audio_recording
    it_behaves_like :jsonapi_filters_by_string_field, :src_number_radius_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :src_number_radius_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :dst_number_radius_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :dst_number_radius_rewrite_result
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
  end

  describe 'GET show' do
    let!(:customers_auth) { create :customers_auth }

    context 'when customers auth exists' do
      before { get :show, params: { id: customers_auth.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(customers_auth.id.to_s) }
    end

    context 'when customers auth does not exist' do
      before { get :show, params: { id: customers_auth.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: {
        data: { type: 'customers-auths',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) do
        {
          name: 'name',
          enabled: true,
          'reject-calls': true,
          ip: '0.0.0.0',
          'external-id': 100
        }
      end

      let(:relationships) do
        { 'dump-level': wrap_relationship(:'dump-levels', 1),
          'diversion-policy': wrap_relationship(:'diversion-policies', 1),
          customer: wrap_relationship(:contractors, create(:contractor, customer: true).id),
          rateplan: wrap_relationship(:rateplans, create(:rateplan).id),
          'routing-plan': wrap_relationship(:'routing-plans', create(:routing_plan).id),
          gateway: wrap_relationship(:gateways, create(:gateway).id),
          account: wrap_relationship(:accounts, create(:account).id) }
      end

      it 'creates customers auth' do
        subject
        expect(response.status).to eq(201)
        expect(CustomersAuth.where(external_id: attributes[:'external-id']).count).to eq(1)
      end

      include_examples :increments_customers_auth_state_seq
    end

    context 'when attributes are invalid' do
      let(:attributes) { {  name: 'name' } }
      let(:relationships) { {} }

      it 'does not create customers auth' do
        subject
        expect(response.status).to eq(422)
        expect(CustomersAuth.count).to eq(0)
      end
    end
  end

  describe 'PUT update' do
    subject do
      put :update, params: {
        id: customers_auth.to_param, data: { type: 'customers-auths',
                                             id: customers_auth.to_param,
                                             attributes: attributes }
      }
    end

    let!(:customers_auth) { create :customers_auth }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', enabled: false } }

      it 'updates customers auth' do
        subject
        expect(response.status).to eq(200)
        expect(customers_auth.reload).to have_attributes(name: 'name')
      end

      include_examples :increments_customers_auth_state_seq
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name', capacity: 0 } }

      it 'does not update customers auth' do
        subject
        expect(response.status).to eq(422)
        expect(customers_auth.reload.name).to_not eq('name')
      end
    end
  end

  describe 'DELETE destroy' do
    subject do
      delete :destroy, params: { id: customers_auth.to_param }
    end

    let!(:customers_auth) { create :customers_auth }

    it 'destroys customers auth' do
      subject
      expect(response.status).to eq(204)
      expect(CustomersAuth.count).to eq(0)
    end

    include_examples :increments_customers_auth_state_seq
  end

  describe 'editable tag_action and tag_action_value' do
    include_examples :jsonapi_resource_with_multiple_tags do
      let(:resource_type) { 'customers-auths' }
      let(:factory_name) { :customers_auth }
    end
  end
end
