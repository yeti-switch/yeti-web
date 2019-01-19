# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Routing::NumberlistActionsController, type: :controller do
  include_context :jsonapi_admin_headers

  let(:record) { Routing::NumberlistAction.take }

  describe 'GET index' do
    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(Routing::NumberlistAction.count) }
  end

  describe 'GET show' do
    before { get :show, params: { id: record.id } }

    it 'receive expected fields' do
      expect(response_data.deep_symbolize_keys).to a_hash_including(
        id: record.id.to_s,
        type: 'numberlist-actions',
        attributes: {
          name: record.name
        }
      )
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: {
        data: { type: 'numberlist-actions',
                attributes: { name: 'Name_1' } }
      }
    end

    it { expect { subject }.to raise_error(ActionController::UrlGenerationError) }
  end

  describe 'PUT update' do
    subject do
      put :update, params: {
        id: record.to_param, data: { type: 'numberlist-actions',
                                     id: record.id.to_i,
                                     attributes: { name: 'Update name_1' } }
      }
    end

    it { expect { subject }.to raise_error(ActionController::UrlGenerationError) }
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: record.to_param } }

    it { expect { subject }.to raise_error(ActionController::UrlGenerationError) }
  end
end
