# frozen_string_literal: true

RSpec.shared_context :init_routing_tag_collection do
  let!(:tag_ua) { FactoryBot.create(:routing_tag, :ua) }
  let!(:tag_emergency) { FactoryBot.create(:routing_tag, :emergency) }
  let!(:tag_us) { FactoryBot.create(:routing_tag, :us) }
end
