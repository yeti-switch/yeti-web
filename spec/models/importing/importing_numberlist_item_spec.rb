require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_hook'

describe Importing::NumberlistItem do

  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook([:key])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_numberlist_item,
                    {
                        o_id: 8,
                        numberlist_id: nil,
                        action_id: nil,
                        tag_action_id: nil,
                        tag_action_value: []
                    }

    it 'convert tag_action_value to array of IDs' do
      tag_action = Routing::TagAction.find_by(name: preview_item.tag_action_name)
      tags = Routing::RoutingTag.where(name: preview_item.tag_action_value_names.split(', '))

      subject

      expect(preview_item.reload).to have_attributes(
        tag_action_id: tag_action.id,
        tag_action_value: tags.map(&:id)
      )
    end
  end

  context 'when tag_action_value_names is NULL' do
    include_context :init_importing_numberlist_item, {
      tag_action_value_names: nil,
      tag_action_value: []
    }

    it 'tag_action_value is empty array' do
      subject
      expect(preview_item.reload).to have_attributes(
        tag_action_value_names: nil,
        tag_action_value: []
      )
    end
  end

  it_behaves_like 'after_import_hook when real items match' do
    include_context :init_importing_numberlist_item, key: 'SameName'
    before { create(:numberlist_item, key: 'SameName') }

    let(:real_item) { described_class.import_class.last }
  end

end
