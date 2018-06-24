RSpec.describe Api::Rest::Admin::Routing::RoutingTagDetectionRulesController, type: :controller do

  include_context :jsonapi_admin_headers

  let(:resource_type) { 'routing-tag-detection-rules' }

  include_context :init_routing_tag_collection

  let(:area_1) { create :area }
  let(:area_2) { create :area }
  let(:rtm_and) { Routing::RoutingTagMode.last }

  let(:record) do
    create :routing_tag_detection_rule
  end

  describe 'GET index' do
    let!(:records) do
      create_list :routing_tag_detection_rule, 2
    end

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(records.size) }
  end

  describe 'GET show' do
    before { get :show, params: { id: record.to_param } }

    it { expect(response.status).to eq(200) }
    it { expect(response_data['id']).to eq(record.id.to_s) }
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: resource_type,
                attributes: attributes,
                relationships: relationships }
      }
    end

    let(:attributes) do
      {
        'src-prefix': '111',
        'dst-prefix': '222',
        'tag-action-value': Routing::RoutingTag.all.pluck(:id),
        'routing-tag-ids': Routing::RoutingTag.all.pluck(:id)
      }
    end

    let(:relationships) do
      {
        'routing-tag-mode': wrap_relationship(:'routing-tag-modes', rtm_and.id),
        'src-area': wrap_relationship(:'areas', area_1.id),
        'dst-area': wrap_relationship(:'areas', area_2.id)
      }
    end

    it { expect(response.status).to eq(201) }
    it { expect(Routing::RoutingTagDetectionRule.count).to eq(1) }
  end

  describe 'PUT update' do
    before { put :update, params: {
      id: record.to_param, data: { type: resource_type,
                                   id: record.to_param,
                                   relationships: relationships}
    } }
    let(:relationships) do
      {
        'routing-tag-mode': wrap_relationship(:'routing-tag-modes', rtm_and.id),
        'src-area': wrap_relationship(:'areas', area_1.id),
        'dst-area': wrap_relationship(:'areas', area_2.id)
      }
    end

    it { expect(response.status).to eq(200) }
  end

  describe 'DELETE destroy' do
    before { delete :destroy, params: { id: record.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Routing::RoutingTagDetectionRule.count).to eq(0) }
  end

  describe 'editable tag_action and tag_action_value' do
    include_examples :jsonapi_resource_with_multiple_tags do
      let(:record) do
        create(:routing_tag_detection_rule,
               tag_action: tag_action_3,
               tag_action_value: tag_ids)
      end
    end
  end

  describe 'editable routing_tag_ids' do
    include_examples :jsonapi_resource_with_routing_tag_ids do
      let(:record) do
        create(:routing_tag_detection_rule,
               routing_tag_ids: tag_ids)
      end
    end
  end
end
