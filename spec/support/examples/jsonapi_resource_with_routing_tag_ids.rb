RSpec.shared_examples :jsonapi_resource_with_routing_tag_ids do

  include_context :init_routing_tag_collection

  let(:tag_ids) { [@tag_ua.id, @tag_us.id] }

  #let(:resource_type) { 'customers-auths' }
  #let(:factory_name) { :destination }

  let(:record) do
    create(factory_name,
           routing_tag_ids: tag_ids)
  end

  context 'GET show' do
    before { get :show, params: { id: record.to_param } }

    it 'has `routing_tag_ids` array' do
      expect(response_data['attributes'])
        .to include('routing-tag-ids' => tag_ids)
    end
  end

  context 'PUT update' do
    before do
      put :update, params: {
        id: record.to_param,
        data: {
          type: resource_type,
          id: record.to_param,
          attributes: {
            'routing-tag-ids': [@tag_emergency.id]
          }
        }
      }
    end

    it 'updates `routing_tag_ids` array' do
      expect(record.reload)
        .to have_attributes(routing_tag_ids: [@tag_emergency.id])
    end

  end
end
