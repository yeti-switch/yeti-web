# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::GatewayGroupsController, type: :controller do
  let(:vendor) { create :contractor, vendor: true }

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:gateway_groups) { create_list :gateway_group, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(gateway_groups.size) }
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :gateway_group }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end

  describe 'GET show' do
    let!(:gateway_group) { create :gateway_group }

    context 'when gateway_group exists' do
      before { get :show, params: { id: gateway_group.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(gateway_group.id.to_s) }
    end

    context 'when gateway_group does not exist' do
      before { get :show, params: { id: gateway_group.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'GET index with filters' do
    before { create_list :gateway_group, 2 }

    it_behaves_like :jsonapi_filter_by_name do
      let(:subject_record) { create :gateway_group }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'gateway-groups',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) do
        { vendor: wrap_relationship(:contractors, vendor.id) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(GatewayGroup.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(GatewayGroup.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:gateway_group) { create :gateway_group }
    before do
      put :update, params: {
        id: gateway_group.to_param, data: { type: 'gateway-groups',
                                            id: gateway_group.to_param,
                                            attributes: attributes,
                                            relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }
      let(:relationships) { { vendor: wrap_relationship(:contractors, vendor.id) } }

      it { expect(response.status).to eq(200) }
      it { expect(gateway_group.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: nil } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(gateway_group.reload.name).to_not eq(nil) }
    end
  end

  describe 'DELETE destroy' do
    let!(:gateway_group) { create :gateway_group }

    before { delete :destroy, params: { id: gateway_group.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(GatewayGroup.count).to eq(0) }
  end
end
