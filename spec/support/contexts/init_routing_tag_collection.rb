# frozen_string_literal: true

RSpec.shared_context :init_routing_tag_collection do
  before do
    @tag_ua = create(:routing_tag, :ua)
    @tag_emergency = create(:routing_tag, :emergency)
    @tag_us = create(:routing_tag, :us)
  end
end
