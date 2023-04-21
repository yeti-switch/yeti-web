# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CustomersAuthsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    subject do
      get :index, params: json_api_request_query
    end

    let(:json_api_request_query) { nil }
    let!(:customers_auths) { create_list :customers_auth, 2 }

    it 'responds with correct collection' do
      subject
      expect(response.status).to eq(200)
      expect(response_data.size).to eq(customers_auths.size)
    end

    context 'with ransack filters' do
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
      it_behaves_like :jsonapi_filters_by_string_field, :external_type do
        let(:trait) { :with_external_id }
      end
    end
  end

  describe 'GET show' do
    subject do
      get :show, params: { id: customers_auth_id }
    end

    let!(:customers_auth) { create(:customers_auth, customers_auth_attrs) }
    let(:customers_auth_attrs) { {} }
    let(:customers_auth_id) { customers_auth.id }

    it 'responds with correct resource' do
      subject
      expect(response.status).to eq(200)
      expect(response_data['id']).to eq(customers_auth.id.to_s)
      expect(response_data['attributes']).to match(
                                               hash_including(
                                                 'name' => customers_auth.name,
                                                 'external-id' => nil,
                                                 'external-type' => nil
                                               )
                                             )
    end

    context 'when customers auth does not exist' do
      let(:customers_auth_id) { customers_auth.id + 10 }

      it 'responds with 404 error' do
        subject
        expect(response.status).to eq(404)
        expect(response_data).to eq(nil)
      end
    end

    context 'when customers auth have filled external_id' do
      let(:customers_auth_attrs) { super().merge external_id: 123 }

      it 'responds with correct resource' do
        subject
        expect(response.status).to eq(200)
        expect(response_data['id']).to eq(customers_auth.id.to_s)
        expect(response_data['attributes']).to match(
                                                 hash_including(
                                                   'name' => customers_auth.name,
                                                   'external-id' => 123,
                                                   'external-type' => nil
                                                 )
                                               )
      end
    end

    context 'when customers auth have filled external_id and external_type' do
      let(:customers_auth_attrs) { super().merge external_id: 123, external_type: 'foo' }

      it 'responds with correct resource' do
        subject
        expect(response.status).to eq(200)
        expect(response_data['id']).to eq(customers_auth.id.to_s)
        expect(response_data['attributes']).to match(
                                                 hash_including(
                                                   'name' => customers_auth.name,
                                                   'external-id' => 123,
                                                   'external-type' => 'foo'
                                                 )
                                               )
      end
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: request_body
    end

    let(:request_body) do
      {
        data: {
          type: 'customers-auths',
          attributes: attributes,
          relationships: relationships
        }
      }
    end

    let(:attributes) do
      {
        name: 'name',
        enabled: true,
        'reject-calls': true,
        ip: '0.0.0.0',
        'dump-level-id': CustomersAuth::DUMP_LEVEL_CAPTURE_SIP
      }
    end

    let!(:customer) { create(:contractor, customer: true) }
    let!(:rateplan) { create(:rateplan).reload }
    let!(:routing_plan) { create(:routing_plan) }
    let!(:gateway) { create(:gateway, contractor: customer) }
    let!(:account) { create(:account, contractor: customer).reload }
    let(:relationships) do
      {
        'diversion-policy': wrap_relationship(:'diversion-policies', 1),
        customer: wrap_relationship(:contractors, customer.id),
        rateplan: wrap_relationship(:rateplans, rateplan.id),
        'routing-plan': wrap_relationship(:'routing-plans', routing_plan.id),
        gateway: wrap_relationship(:gateways, gateway.id),
        account: wrap_relationship(:accounts, account.id)
      }
    end

    it 'creates customers auth' do
      expect { subject }.to change { CustomersAuth.count }.by(1)
      customers_auth = CustomersAuth.last!
      expect(response.status).to eq(201)
      expect(response_data['id']).to eq customers_auth.id.to_s
      expect(customers_auth).to have_attributes(
                                  name: attributes[:name],
                                  enabled: attributes[:enabled],
                                  reject_calls: attributes[:'reject-calls'],
                                  ip: [attributes[:ip]],
                                  dump_level_id: attributes[:'dump-level-id'],
                                  external_id: nil,
                                  external_type: nil,
                                  diversion_policy_id: 1,
                                  customer: customer,
                                  rateplan: rateplan,
                                  routing_plan: routing_plan,
                                  gateway: gateway,
                                  account: account
                                )
    end

    include_examples :increments_customers_auth_state

    context 'with external-id attribute' do
      let(:attributes) { super().merge 'external-id': 123 }

      it 'creates customers auth' do
        expect { subject }.to change { CustomersAuth.count }.by(1)
        customers_auth = CustomersAuth.last!
        expect(response.status).to eq(201)
        expect(response_data['id']).to eq customers_auth.id.to_s
        expect(customers_auth).to have_attributes(
                                    name: attributes[:name],
                                    enabled: attributes[:enabled],
                                    reject_calls: attributes[:'reject-calls'],
                                    ip: [attributes[:ip]],
                                    dump_level_id: attributes[:'dump-level-id'],
                                    external_id: attributes[:'external-id'],
                                    external_type: nil,
                                    diversion_policy_id: 1,
                                    customer: customer,
                                    rateplan: rateplan,
                                    routing_plan: routing_plan,
                                    gateway: gateway,
                                    account: account
                                  )
      end

      include_examples :increments_customers_auth_state
    end

    context 'with external-id and external-type attributes' do
      let(:attributes) { super().merge 'external-id': 123, 'external-type': 'foo' }

      it 'creates customers auth' do
        expect { subject }.to change { CustomersAuth.count }.by(1)
        customers_auth = CustomersAuth.last!
        expect(response.status).to eq(201)
        expect(response_data['id']).to eq customers_auth.id.to_s
        expect(customers_auth).to have_attributes(
                                    name: attributes[:name],
                                    enabled: attributes[:enabled],
                                    reject_calls: attributes[:'reject-calls'],
                                    ip: [attributes[:ip]],
                                    dump_level_id: attributes[:'dump-level-id'],
                                    external_id: attributes[:'external-id'],
                                    external_type: attributes[:'external-type'],
                                    diversion_policy_id: 1,
                                    customer: customer,
                                    rateplan: rateplan,
                                    routing_plan: routing_plan,
                                    gateway: gateway,
                                    account: account
                                  )
      end

      include_examples :increments_customers_auth_state
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) { {} }

      it 'does not create customers auth' do
        expect { subject }.to change { CustomersAuth.count }.by(0)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT update' do
    subject do
      put :update, params: request_body
    end

    let(:request_body) do
      {
        id: customers_auth.id.to_s,
        data: {
          type: 'customers-auths',
          id: customers_auth.id.to_s,
          attributes: attributes
        }
      }
    end
    let!(:customers_auth) { create(:customers_auth) }

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', enabled: false } }

      it 'updates customers auth' do
        subject
        expect(response.status).to eq(200)
        expect(customers_auth.reload).to have_attributes(
                                           name: 'name',
                                           enabled: false
                                         )
      end

      include_examples :increments_customers_auth_state
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name', capacity: 0 } }

      it 'does not update customers auth' do
        expect { subject }.not_to change { customers_auth.reload.attributes }
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE destroy' do
    subject do
      delete :destroy, params: { id: customers_auth_id }
    end

    let!(:customers_auth) { create :customers_auth }
    let!(:customers_auth_id) { customers_auth.id }

    it 'destroys customers auth' do
      expect { subject }.to change { CustomersAuth.count }.by(-1)
      expect(response.status).to eq(204)
      expect(CustomersAuth.where(id: customers_auth.id)).not_to be_exists
    end

    include_examples :increments_customers_auth_state
  end

  describe 'editable tag_action and tag_action_value' do
    include_examples :jsonapi_resource_with_multiple_tags do
      let(:resource_type) { 'customers-auths' }
      let(:factory_name) { :customers_auth }
    end
  end
end
