# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::NumberlistItemsController, type: :controller do
  include_context :jsonapi_admin_headers

  let(:resource_type) { 'numberlist-items' }

  let(:numberlist) { create :numberlist }

  describe 'GET index' do
    let!(:records) { create_list :numberlist_item, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(records.size) }
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :numberlist_item }

    it_behaves_like :jsonapi_filters_by_string_field, :key
    it_behaves_like :jsonapi_filters_by_number_field, :action_id
    it_behaves_like :jsonapi_filters_by_datetime_field, :created_at
    it_behaves_like :jsonapi_filters_by_datetime_field, :updated_at
    it_behaves_like :jsonapi_filters_by_string_field, :src_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :src_rewrite_result
    it_behaves_like :jsonapi_filters_by_boolean_field, :defer_src_rewrite
    it_behaves_like :jsonapi_filters_by_string_field, :dst_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :dst_rewrite_result
    it_behaves_like :jsonapi_filters_by_boolean_field, :defer_dst_rewrite
    it_behaves_like :jsonapi_filters_by_number_field, :number_min_length
    it_behaves_like :jsonapi_filters_by_number_field, :number_max_length
  end

  describe 'GET show' do
    let!(:record) { create :numberlist_item }

    before { get :show, params: { id: record.to_param } }

    it { expect(response.status).to eq(200) }
    it { expect(response_data['id']).to eq(record.id.to_s) }
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: resource_type,
                attributes: attributes,
                relationships: relationships }
      }
    end

    let(:attributes) do
      {
        key: 'rspec-key-1',
        'src-rewrite-rule': 'value-1',
        'src-rewrite-result': 'value-2',
        'defer-src-rewrite': true,
        'dst-rewrite-rule': 'value-3',
        'dst-rewrite-result': 'value-4',
        'defer-dst-rewrite': true
      }
    end

    let(:relationships) do
      {
        'numberlist': wrap_relationship(:numberlists, numberlist.to_param)
      }
    end

    it { expect(response.status).to eq(201) }
    it { expect(Routing::NumberlistItem.count).to eq(1) }
  end

  describe 'PUT update' do
    let!(:record) { create :numberlist_item }

    before do
      put :update, params: {
        id: record.to_param, data: { type: resource_type,
                                     id: record.to_param,
                                     attributes: attributes }
      }
    end

    let(:attributes) do
      { key: 'rspec-key-updated-1' }
    end

    it { expect(response.status).to eq(200) }
    it { expect(record.reload.key).to eq('rspec-key-updated-1') }
  end

  describe 'DELETE destroy' do
    let!(:record) { create :numberlist_item }

    before { delete :destroy, params: { id: record.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::NumberlistItem.count).to eq(0) }
  end

  describe 'editable tag_action and tag_action_value' do
    include_examples :jsonapi_resource_with_multiple_tags do
      let(:factory_name) { :numberlist_item }
    end
  end
end
