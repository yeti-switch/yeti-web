# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Routing::RoutingTagsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    include_context :init_routing_tag_collection
    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(Routing::RoutingTag.count) }
  end

  describe 'GET show' do
    include_context :init_routing_tag_collection
    let(:tag) { Routing::RoutingTag.take }

    before { get :show, params: { id: tag.id } }

    it 'receive expected fields' do
      expect(response_data.deep_symbolize_keys).to a_hash_including(
        id: tag.id.to_s,
        attributes: {
          name: tag.name
        }
      )
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'routing-tags',
                attributes: attributes }
      }
    end

    let(:attributes) do
      { name: 'RSpec tag n-1' }
    end

    it { expect(response.status).to eq(201) }
    it 'creates proper Tag' do
      expect(Routing::RoutingTag.last).to have_attributes(name: attributes[:name])
    end
  end

  describe 'PUT update' do
    let!(:tag) { create(:routing_tag) }

    before do
      put :update, params: {
        id: tag.id.to_s, data: { type: 'routing-tags',
                                 id: tag.id.to_i,
                                 attributes: attributes }
      }
    end

    let(:attributes) do
      { name: 'new tag name' }
    end

    it { expect(response.status).to eq(200) }
    it { expect(tag.reload.name).to eq(attributes[:name]) }
  end

  describe 'DELETE destroy' do
    let!(:tag) { create :routing_tag }

    before { delete :destroy, params: { id: tag.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::RoutingTag.count).to eq(0) }
  end
end
