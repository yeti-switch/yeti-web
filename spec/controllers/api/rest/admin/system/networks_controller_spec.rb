# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::System::NetworksController, type: :controller do
  let(:admin_user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: admin_user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:networks) do
      [
        create(:network),
        create(:network, name: 'US AMC Mobile')
      ]
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
      expect(response_data.size).to eq(networks.size)
    end

    context 'filtering' do
      context 'by name' do
        let(:filters) do
          { 'name' => network.name }
        end
        let!(:network) do
          create :network, name: 'Ukraine AMC Mobile'
        end
        it 'only desired networks should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => network.id.to_s
            )
          )
        end
      end
    end
  end

  describe 'GET show' do
    let!(:network) do
      create :network
    end

    subject do
      get :show, params: json_api_query_params
    end

    let(:json_api_query_params) { { id: network.id } }

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response body should be valid' do
      subject
      expect(response_data).to match(
        hash_including(
          'id' => network.id.to_s,
          'type' => 'networks',
          'attributes' => {
            'name' => network.name
          },
          'relationships' => {
            'network-type' => hash_including
          }
        )
      )
    end

    context 'when include network-type' do
      let(:json_api_query_params) { super().merge include: 'network-type' }

      it 'http status should eq 200' do
        subject
        expect(response.status).to eq(200)
      end

      it 'response body should be valid' do
        subject
        expect(response_data).to match(
          hash_including(
            'id' => network.id.to_s,
            'type' => 'networks',
            'attributes' => {
              'name' => network.name
            },
            'relationships' => {
              'network-type' => hash_including(
                'data' => {
                  'id' => network.type_id.to_s,
                  'type' => 'network-types'
                }
              )
            }
          )
        )
      end
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: payload
    end
    let(:payload) do
      {
        data: {
          type: 'networks',
          attributes: {
            name: 'US Eagle Mobile'
          },
          relationships: {
            'network-type': {
              data: { id: network_type.id, type: 'network_types' }
            }
          }
        }
      }
    end

    let!(:network_type) { FactoryGirl.create(:network_type) }

    it 'network should be created' do
      expect { subject }.to change { System::Network.count }.by(1)
    end
  end

  describe 'PATCH update' do
    subject do
      patch :update, params: { id: network.id, **payload }
    end
    let(:payload) do
      {
        data: {
          type: 'networks',
          id: network.id.to_s,
          attributes: {
            name: 'US AMC Mobile'
          },
          relationships: {
            'network-type': {
              data: { id: network_type.id, type: 'network_types' }
            }
          }
        }
      }
    end

    let!(:network) { create(:network) }
    let!(:network_type) { create(:network_type) }

    it 'network name should be changed' do
      expect { subject }.to change { network.reload.name }.from('US Eagle Mobile').to('US AMC Mobile')
    end

    it 'network network_type should be changed' do
      expect { subject }.to change { network.reload.type_id }.to(network_type.id)
    end
  end

  describe 'DELETE delete' do
    subject do
      delete :destroy, params: { id: network.id }
    end
    let!(:network) do
      create :network
    end

    it 'network should be deleted' do
      expect { subject }.to change { System::Network.count }.by(-1)
    end
  end
end
