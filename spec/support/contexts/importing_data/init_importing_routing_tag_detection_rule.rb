# frozen_string_literal: true

shared_context :init_importing_routing_tag_detection_rule do |args|
  args ||= {}

  let(:fields) { { is_changed: true }.merge(args) }
  let!(:importing_routing_tag_detection_rule) { FactoryBot.create(:importing_routing_tag_detection_rule, fields) }
end
