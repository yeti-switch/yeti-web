# frozen_string_literal: true

shared_context :init_importing_routing_group do |args|
  args ||= {}

  before do
    fields = {
      name: 'Default routing',
      is_changed: true
    }.merge(args)

    @importing_routing_group = FactoryGirl.create(:importing_routing_group, fields)
  end
end
