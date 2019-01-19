# frozen_string_literal: true

shared_context :init_importing_destination do |args|
  args ||= {}

  before do
    fields = {
      prefix: '998713',
      rateplan_name: @rateplan.name,
      rateplan_id: @rateplan.id,
      rate_policy_name: 'Fixed',
      rate_policy_id: 1,
      initial_interval: 1,
      next_interval: 1,
      initial_rate: 0.033,
      next_rate: 0.033,
      routing_tag_mode_name: Routing::RoutingTagMode.last.name,
      routing_tag_mode_id: Routing::RoutingTagMode.last.id
    }.merge(args)

    @importing_destination = FactoryGirl.create(:importing_destination, fields)
  end
end
