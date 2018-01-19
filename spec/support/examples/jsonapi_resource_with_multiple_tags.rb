RSpec.shared_examples :jsonapi_resource_with_multiple_tags do

  #let(:resource_type) { 'customers-auths' }
  #let(:factory_name) { :customers_auth }

  include_context :init_routing_tag_collection

  let(:tag_action_3) do
    Routing::TagAction.find(Routing::TagAction::CONST::APPEND_ID)
  end

  let(:tag_ids) { [@tag_ua.id, @tag_us.id] }

  let(:record) do
    create(factory_name,
           tag_action: tag_action_3,
           tag_action_value: tag_ids)
  end

  context 'GET show' do

    before { get :show, id: record.to_param, include: 'tag-action' }

    it 'has `tag_action_velue` array' do
      expect(response_data['attributes']).to include('tag-action-value' => tag_ids)
    end

    it 'has `tag-action` relation' do
      expect(response_body).to include(
        included: match_array(
          include(
            id: tag_action_3.to_param,
            type: 'tag-actions',
            attributes: include(
              name: tag_action_3.name
            )
          )
        )
      )
    end

  end

  context 'PUT update' do
    let(:new_tag_action) { Routing::TagAction.find(1) }

    before do
      put :update, id: record.to_param, data: {
        type: resource_type,
        id: record.to_param,
        attributes: {
          'tag-action-value': [@tag_emergency.id]
        },
        relationships: {
          'tag-action': wrap_relationship(:'tag-actions', new_tag_action.to_param)
        }
      }
    end

    it 'updates record with new tag_action and tag_action_value' do
      expect(record.reload).to have_attributes(
        tag_action_id: new_tag_action.id,
        tag_action_value: [@tag_emergency.id]
      )
    end
  end

end
