# frozen_string_literal: true

require 'spec_helper'

describe Routing::Destination, type: :model do
  context 'validate routing_tag_ids' do
    include_examples :test_model_with_routing_tag_ids
  end
end
