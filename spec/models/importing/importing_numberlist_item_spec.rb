# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_hook'

RSpec.describe Importing::NumberlistItem do
  let(:preview_item) { described_class.last }

  subject do
    described_class.after_import_hook
    described_class.resolve_object_id([:key])
  end

  it_behaves_like 'after_import_hook when real items do not match' do
    include_context :init_importing_numberlist_item,
                    o_id: 8,
                    numberlist_id: nil,
                    action_id: nil,
                    tag_action_id: nil,
                    tag_action_value: []

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
    include_context :init_importing_numberlist_item,
                    tag_action_value_names: nil,
                    tag_action_value: []

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

  describe '.resolve_object_id' do
    subject { described_class.resolve_object_id(described_class.strict_unique_attributes) }

    let(:numberlist) { create(:numberlist) }
    let!(:first_item) { create(:importing_numberlist_item, key: '123', _numberlist: numberlist) }
    let!(:duplicate_item) { create(:importing_numberlist_item, key: '123', _numberlist: numberlist) }
    let!(:other_numberlist_item) { create(:importing_numberlist_item, key: '123', _numberlist: create(:numberlist)) }

    it 'marks all rows of the same key except the first one as duplicates', :aggregate_failures do
      expect(subject).to eq(1)
      expect(first_item.reload).to have_attributes(is_changed: true, error_string: nil)
      expect(other_numberlist_item.reload).to have_attributes(is_changed: true, error_string: nil)
      expect(duplicate_item.reload).to have_attributes(
        is_changed: false,
        error_string: "Duplicate of row ##{first_item.id}"
      )
    end

    context 'when first row was removed and unique columns applied again' do
      before do
        described_class.resolve_object_id(described_class.strict_unique_attributes)
        first_item.delete
      end

      it 'clears duplicate mark', :aggregate_failures do
        expect(subject).to eq(0)
        expect(duplicate_item.reload).to have_attributes(is_changed: true, error_string: nil)
      end
    end
  end
end
