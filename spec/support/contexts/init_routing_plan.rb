# frozen_string_literal: true

shared_context :init_routing_plan do |args|
  args ||= {}

  before do
    fields = {
      name: 'Default routing'
    }.merge(args)

    @routing_plan = FactoryBot.create(:routing_plan, fields)
  end
end
