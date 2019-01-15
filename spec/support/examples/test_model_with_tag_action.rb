# frozen_string_literal: true

RSpec.shared_examples :test_model_with_tag_action do
  include_context :init_routing_tag_collection

  let(:random_tags) do
    Routing::RoutingTag.pluck(:id).take(2)
  end

  let(:model) do
    described_class.new(attributes)
  end

  context 'when tag_action is NULL' do
    let(:attributes) do
      { tag_action_id: nil }
    end

    it 'allows tag_action_value to be empty' do
      expect(model).to allow_value([]).for(:tag_action_value)
    end

    it 'allows tag_action_value to be present' do
      expect(model).to allow_value(random_tags).for(:tag_action_value)
    end
  end

  context 'when tag_action ID="1"(clear)' do
    let(:attributes) do
      { tag_action_id: Routing::TagAction.clear_action.id }
    end

    it 'allows tag_action_value to be empty' do
      expect(model).to allow_value([]).for(:tag_action_value)
    end

    it 'allows tag_action_value to be present' do
      expect(model).to allow_value(random_tags).for(:tag_action_value)
    end
  end

  context 'when tag_action is not NULL and not "1"(Clear)' do
    let(:attributes) do
      {
        tag_action_id: Routing::TagAction.find(2).id
      }
    end

    it 'does not allow tag_action_value to be empty' do
      tag_values = random_tags.dup.push(nil)
      expect(model).not_to allow_value(tag_values).for(:tag_action_value)
    end

    it 'does not allow tag_action_value to contain NULL' do
      expect(model).not_to allow_value([]).for(:tag_action_value)
    end

    it 'does not allow NULL for tag_action_value' do
      expect(model).not_to allow_value(nil).for(:tag_action_value)
    end

    it 'does not allow tag_action_value to contain duplicate values' do
      tag_values = random_tags.dup.push(random_tags.first) # => [1, 2, 1]
      expect(model).not_to allow_value(tag_values).for(:tag_action_value)
    end
  end
end
