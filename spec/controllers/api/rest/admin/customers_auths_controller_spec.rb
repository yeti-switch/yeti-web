require 'spec_helper'

describe Api::Rest::Admin::CustomersAuthsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:customers_auths) { create_list :customers_auth, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(customers_auths.size) }
  end

  describe 'GET show' do
    let!(:customers_auth) { create :customers_auth }

    context 'when customers auth exists' do
      before { get :show, id: customers_auth.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(customers_auth.id.to_s) }
    end

    context 'when customers auth does not exist' do
      before { get :show, id: customers_auth.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, data: { type: 'customers-auths',
                            attributes: attributes,
                            relationships: relationships }
    end

    context 'when attributes are valid' do
      let(:attributes) do
        {
          name: 'name',
          enabled: true,
          ip: '0.0.0.0',
        }
      end

      let(:relationships) do
        { 'dump-level': wrap_relationship(:'dump-levels', 1),
          'diversion-policy': wrap_relationship(:'diversion-policies', 1),
          customer: wrap_relationship(:contractors, create(:contractor, customer: true).id),
          rateplan: wrap_relationship(:rateplans, create(:rateplan).id),
          'routing-plan': wrap_relationship(:'routing-plans', create(:routing_plan).id),
          gateway: wrap_relationship(:gateways, create(:gateway).id),
          account: wrap_relationship(:accounts, create(:account).id)
        }
      end

      it { expect(response.status).to eq(201) }
      it { expect(CustomersAuth.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { {  name: 'name' } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(CustomersAuth.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:customers_auth) { create :customers_auth }
    before do
      put :update, id: customers_auth.to_param, data: { type: 'customers-auths',
                                                        id: customers_auth.to_param,
                                                        attributes: attributes }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name', enabled: false } }

      it { expect(response.status).to eq(200) }
      it { expect(customers_auth.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name', capacity: 0 } }

      it { expect(response.status).to eq(422) }
      it { expect(customers_auth.reload.name).to_not eq('name') }
    end
  end

  describe 'DELETE destroy' do
    let!(:customers_auth) { create :customers_auth }

    before { delete :destroy, id: customers_auth.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(CustomersAuth.count).to eq(0) }
  end
end

