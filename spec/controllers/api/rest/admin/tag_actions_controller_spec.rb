# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::TagActionsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(Routing::TagAction.count) }
  end

  describe 'GET show' do
    let(:tag_action) { Routing::TagAction.take }

    before { get :show, params: { id: tag_action.id } }

    it 'receive expected fields' do
      expect(response_data.deep_symbolize_keys).to a_hash_including(
        id: tag_action.id.to_s,
        type: 'tag-actions',
        attributes: {
          name: tag_action.name
        }
      )
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: {
        data: { type: 'tag-actions',
                attributes: { name: 'Name_1' } }
      }
    end

    it { expect { subject }.to raise_error(ActionController::UrlGenerationError) }
  end

  describe 'PUT update' do
    let(:tag_action) { Routing::TagAction.take }

    subject do
      put :update, params: {
        id: tag_action.to_param, data: { type: 'routing-tags',
                                         id: tag_action.id.to_i,
                                         attributes: { name: 'Update name_1' } }
      }
    end

    it { expect { subject }.to raise_error(ActionController::UrlGenerationError) }
  end

  describe 'DELETE destroy' do
    let!(:tag_action) { Routing::TagAction.take }

    subject { delete :destroy, params: { id: tag_action.to_param } }

    it { expect { subject }.to raise_error(ActionController::UrlGenerationError) }
  end
end
