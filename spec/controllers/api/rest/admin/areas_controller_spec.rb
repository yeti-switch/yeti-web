# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::AreasController, type: :controller do
  include_context :jsonapi_admin_headers

  let(:resource_type) { 'areas' }

  let(:record) { create :area }

  describe 'GET index' do
    let!(:records) { create_list :area, 2 }
    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(Routing::Area.count) }
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :area }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end

  describe 'GET show' do
    before { get :show, params: { id: record.id } }

    it 'receive expected fields' do
      expect(response_data.deep_symbolize_keys).to a_hash_including(
        id: record.id.to_s,
        attributes: {
          name: record.name
        }
      )
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: resource_type,
                attributes: attributes }
      }
    end

    let(:attributes) do
      { name: 'RSpec area n-1' }
    end

    it { expect(response.status).to eq(201) }
    it 'creates proper record' do
      expect(Routing::Area.last).to have_attributes(name: attributes[:name])
    end
  end

  describe 'PUT update' do
    before do
      put :update, params: {
        id: record.to_param, data: { type: resource_type,
                                     id: record.to_param,
                                     attributes: attributes }
      }
    end

    let(:attributes) do
      { name: 'new area name' }
    end

    it { expect(response.status).to eq(200) }
    it { expect(record.reload.name).to eq(attributes[:name]) }
  end

  describe 'DELETE destroy' do
    before { delete :destroy, params: { id: record.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::Area.count).to eq(0) }
  end
end
