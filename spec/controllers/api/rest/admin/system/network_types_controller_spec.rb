# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::System::NetworkTypesController, type: :controller do
  let(:admin_user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: admin_user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:network_types) do
      create_list(:network_type, 2)
    end

    subject { get :index, params: { filter: filters } }
    let(:filters) do
      {}
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response should contain valid count of items' do
      subject
      expect(response_data.size).to eq(network_types.size)
    end

    context 'filtering' do
      context 'by name' do
        let(:filters) do
          { 'name' => network_type.name }
        end
        let!(:network_type) do
          create :network_type, name: 'AMC'
        end
        it 'only desired network types should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => network_type.id.to_s
            )
          )
        end
      end
    end
  end

  describe 'GET show' do
    let!(:network_type) do
      create :network_type
    end

    subject do
      get :show, params: { id: network_type.id }
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response body should be valid' do
      subject
      expect(response_data).to match(
        hash_including(
          'id' => network_type.id.to_s,
          'type' => 'network-types',
          'attributes' => {
            'name' => network_type.name
          }
        )
      )
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: payload
    end
    let(:payload) do
      {
        data: {
          type: 'network-types',
          attributes: {
            name: 'US'
          }
        }
      }
    end

    it 'network should be created' do
      expect { subject }.to change { System::NetworkType.count }.by(1)
    end
  end

  describe 'PATCH update' do
    subject do
      patch :update, params: { id: network_type.id, **payload }
    end
    let(:payload) do
      {
        data: {
          type: 'network-types',
          id: network_type.id.to_s,
          attributes: {
            name: 'CA'
          }
        }
      }
    end
    let(:network_type) do
      create :network_type, name: 'US'
    end
    it 'network name should be changed' do
      expect { subject }.to change { network_type.reload.name }.from('US').to('CA')
    end
  end

  describe 'DELETE delete' do
    subject do
      delete :destroy, params: { id: network_type.id }
    end
    let!(:network_type) do
      create :network_type
    end

    it 'network type should be deleted' do
      expect { subject }.to change { System::NetworkType.count }.by(-1)
    end

    context 'when have network' do
      before { create(:network, type_id: network_type.id) }

      include_examples :responds_with_status, 422

      it 'network type should not be deleted' do
        expect { subject }.to change { System::NetworkType.count }.by(0)
      end
    end
  end
end
