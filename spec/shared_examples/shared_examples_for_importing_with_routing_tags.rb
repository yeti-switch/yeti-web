# frozen_string_literal: true

RSpec.shared_examples 'resolve "any tag" as NULL' do |collection_context_name|
  context 'with "any tag"' do
    before { @tag = create(:routing_tag, name: 'tag_1') }

    include_context collection_context_name,
                    routing_tag_names: ['tag_1', Routing::RoutingTag::ANY_TAG].join(', '),
                    routing_tag_ids: []

    it 'resolve "any tag" to NULL' do
      subject
      expect(preview_item.reload).to have_attributes(
        routing_tag_names: ['tag_1', Routing::RoutingTag::ANY_TAG].join(', '),
        routing_tag_ids: [@tag.id, nil]
      )
    end
  end
end

RSpec.shared_examples 'resolve routing_tag_names=NULL as empty array' do |collection_context_name|
  context 'when routing_tag_names is NULL' do
    include_context collection_context_name,
                    routing_tag_names: nil,
                    routing_tag_ids: []

    it 'routing_tag_ids is empty array' do
      subject
      expect(preview_item.reload).to have_attributes(
        routing_tag_names: nil,
        routing_tag_ids: []
      )
    end
  end
end
