require 'spec_helper'

describe Api::Rest::Admin::DialpeersController, type: :controller do
  include_context :jsonapi_admin_headers

  let(:rtm_and) { Routing::RoutingTagMode.last }

  describe 'GET index' do
    let!(:dialpeers) { create_list :dialpeer, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(dialpeers.size) }
  end

  describe 'GET index with filters' do
    before { create_list :dialpeer, 2 }

    it_behaves_like :jsonapi_filter_by_external_id do
      let(:subject_record) { create :dialpeer }
    end

    it_behaves_like :jsonapi_filter_by, :prefix do
      let(:subject_record) { create :dialpeer, prefix: attr_value }
      let(:attr_value) { '987' }
    end

    it_behaves_like :jsonapi_filter_by, :routing_group_id do
      let(:subject_record) { create :dialpeer }
      let(:attr_value) { subject_record.routing_group_id }
    end
  end

  describe 'GET show' do
    let!(:dialpeer) { create :dialpeer }

    context 'when dialpeer exists' do
      before { get :show, id: dialpeer.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(dialpeer.id.to_s) }
    end

    context 'when dialpeer does not exist' do
      before { get :show, id: dialpeer.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    let(:vendor) { create :contractor, vendor: true }
    let(:account) { create :account, contractor: vendor }
    let(:gateway_group) { create :gateway_group, vendor: vendor }
    let(:routing_group) { create :routing_group }

    before do
      post :create, data: { type: 'dialpeers',
                            attributes: attributes,
                            relationships: relationships }
    end
    context 'when attributes are valid' do
      let(:attributes) do
        {
          enabled: true,
          'valid-from': DateTime.now,
          'valid-till': 1.year.from_now,
          'initial-interval': 60,
          'next-interval': 60,
          'initial-rate': 0.0,
          'next-rate': 0.0,
          'connect-fee': 0.0
        }
      end

      let(:relationships) do
        { vendor: wrap_relationship(:contractors, vendor.id),
          account: wrap_relationship(:accounts, account.id),
          'gateway-group': wrap_relationship(:'gateway-groups', gateway_group.id),
          'routing-group': wrap_relationship(:'routing-groups', routing_group.id),
          'routing-tag-mode': wrap_relationship(:'routing-tag-modes', rtm_and.id) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Dialpeer.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { enabled: true} }
      let(:relationships) { { vendor: wrap_relationship(:contractors, nil) } }

      it { expect(response.status).to eq(422) }
      it { expect(Dialpeer.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:dialpeer) { create :dialpeer }
    before { put :update, id: dialpeer.to_param, data: { type: 'dialpeers',
                                                         id: dialpeer.to_param,
                                                         attributes: attributes,
                                                         relationships: relationships} }

    context 'when attributes are valid' do
      let(:attributes) { { 'next-interval': 90 } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(200) }
      it { expect(dialpeer.reload.next_interval).to eq(90) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { 'next-interval': 90 } }
      let(:relationships) { { vendor: wrap_relationship(:contractors, nil) } }

      it { expect(response.status).to eq(422) }
      it { expect(dialpeer.reload.next_interval).to_not eq(90) }
    end
  end

  describe 'DELETE destroy' do
    let!(:dialpeer) { create :dialpeer }

    before { delete :destroy, id: dialpeer.to_param }

    it { expect(response.status).to eq(204) }
    it { expect(Dialpeer.count).to eq(0) }
  end

  describe 'editable routing_tag_ids' do
    include_examples :jsonapi_resource_with_routing_tag_ids do
      let(:resource_type) { 'dialpeers' }
      let(:factory_name) { :dialpeer }
    end
  end

end
