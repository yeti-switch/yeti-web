# frozen_string_literal: true

shared_context :init_rate_group do |args|
  args ||= {}

  before do
    fields = {
        name: 'TEST-RateGroup'
    }.merge(args)

    @rate_group = FactoryBot.create(:rate_group, fields)
  end
end
