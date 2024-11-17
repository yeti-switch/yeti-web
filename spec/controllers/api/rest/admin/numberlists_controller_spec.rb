# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::NumberlistsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :numberlist }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_number_field, :default_action_id
    it_behaves_like :jsonapi_filters_by_number_field, :mode_id
    it_behaves_like :jsonapi_filters_by_datetime_field, :created_at
    it_behaves_like :jsonapi_filters_by_datetime_field, :updated_at
    it_behaves_like :jsonapi_filters_by_string_field, :default_src_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :default_src_rewrite_result
    it_behaves_like :jsonapi_filters_by_boolean_field, :defer_src_rewrite
    it_behaves_like :jsonapi_filters_by_string_field, :default_dst_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :default_dst_rewrite_result
    it_behaves_like :jsonapi_filters_by_boolean_field, :defer_dst_rewrite
    it_behaves_like :jsonapi_filters_by_string_field, :external_type do
      let(:trait) { :with_external_id }
    end
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
        external_id: attributes[:'external-id'],
        external_type: nil
      )
    end

    context 'with external-type empty string' do
      let(:attributes) do
        super().merge 'external-type': ''
      end

      it 'responds with created number list' do
        expect { subject }.to change { Routing::Numberlist.count }.by(1)
        expect(response.status).to eq(201)
        record = Routing::Numberlist.last
        expect(record).to have_attributes(
                            name: attributes[:name],
                            external_id: attributes[:'external-id'],
                            external_type: nil
                          )
      end
    end

    context 'with external-type filled' do
      let(:attributes) do
        super().merge 'external-type': 'test'
      end

      it 'responds with created number list' do
        expect { subject }.to change { Routing::Numberlist.count }.by(1)
        expect(response.status).to eq(201)
        record = Routing::Numberlist.last
        expect(record).to have_attributes(
                            name: attributes[:name],
                            external_id: attributes[:'external-id'],
                            external_type: 'test'
                          )
      end
    end
  end
end
