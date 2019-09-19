# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Routing::NumberlistsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    let(:factory) { :numberlist }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_datetime_field, :created_at
    it_behaves_like :jsonapi_filters_by_datetime_field, :updated_at
    it_behaves_like :jsonapi_filters_by_string_field, :default_src_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :default_src_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :default_dst_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :default_dst_rewrite_result
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
  end

  describe 'editable tag_action and tag_action_value' do
    include_examples :jsonapi_resource_with_multiple_tags do
      let(:resource_type) { 'numberlists' }
      let(:factory_name) { :numberlist }
    end
  end

  describe 'GET show' do
    subject do
      get :show, params: { id: numberlist_id }
    end

    let!(:number_list) { create(:numberlist) }

    context 'when number list exists' do
      let(:numberlist_id) { number_list.to_param }

      it 'responds with numberlist' do
        subject
        expect(response.status).to eq(200)
        expect(response_data['id']).to eq(number_list.id.to_s)
      end
    end

    context 'when number list does not exist' do
      let(:numberlist_id) { number_list.id + 1000 }

      it 'responds with 404' do
        subject
        expect(response.status).to eq(404)
        expect(response_data).to be_nil
      end
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: json_api_body
    end

    let(:json_api_body) do
      { data: { type: 'numberlists', attributes: attributes, relationships: relationships } }
    end
    let(:attributes) do
      {
        name: 'name',
        'external-id': 100
      }
    end
    let(:relationships) do
      { 'tag-action': wrap_relationship(:'tag-actions', 1) }
    end

    it 'responds with created number list' do
      expect { subject }.to change { Routing::Numberlist.count }.by(1)
      expect(response.status).to eq(201)
      record = Routing::Numberlist.last
      expect(record).to have_attributes(
        name: attributes[:name],
        external_id: attributes[:'external-id']
      )
    end
  end
end
