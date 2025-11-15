# frozen_string_literal: true

shared_context :init_importing_destination do |args|
  args ||= {}

  before do
    rtm_id = Routing::RoutingTagMode::MODES.keys.sample

    fields = {
      prefix: '998713',
      rate_group_name: @rate_group.name,
      rate_group_id: @rate_group.id,
      rate_policy_name: 'Fixed',
      rate_policy_id: 1,
      initial_interval: 1,
      next_interval: 1,
      initial_rate: 0.033,
      next_rate: 0.033,
      routing_tag_mode_name: Routing::RoutingTagMode::MODES[rtm_id],
      routing_tag_mode_id: rtm_id,
      is_changed: true
    }.merge(args)

    @importing_destination = FactoryBot.create(:importing_destination, fields)
  end
end
