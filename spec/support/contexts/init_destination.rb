# frozen_string_literal: true

shared_context :init_destination do |args|
  args ||= {}

  before do
    fields = {
      prefix: '998713',
      rateplan_id: @rateplan.id,
      rate_policy_id: 1,
      initial_interval: 1,
      next_interval: 1,
      initial_rate: 0.033,
      next_rate: 0.033
    }.merge(args)

    @destination = FactoryBot.create(:destination, fields)
  end
end
