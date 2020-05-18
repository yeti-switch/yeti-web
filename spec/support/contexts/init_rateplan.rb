# frozen_string_literal: true

shared_context :init_rateplan do |args|
  args ||= {}

  before do
    fields = {
      name: 'TEST-RP'
    }.merge(args)

    @rateplan = FactoryBot.create(:rateplan, fields)
  end
end
