# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Routing::RoutingTagDetectionRule, type: :model do
  context '#validations' do
    context 'validate routing_tag_ids' do
      include_examples :test_model_with_routing_tag_ids
    end

    include_examples :test_model_with_tag_action
  end
end
