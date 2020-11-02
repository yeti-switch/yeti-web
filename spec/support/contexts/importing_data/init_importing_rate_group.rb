# frozen_string_literal: true

shared_context :init_importing_rate_group do |args|
  args ||= {}

  before do
    fields = {
      name: 'a-RateGroup',
      is_changed: true
    }.merge(args)

    @importing_rate_group = FactoryBot.create(:importing_rate_group, fields)
  end
end
