# frozen_string_literal: true

shared_context :init_importing_rateplan do |args|
  args ||= {}

  before do
    fields = {
      name: 'a-RP',
      is_changed: true
    }.merge(args)

    @importing_rateplan = FactoryBot.create(:importing_rateplan, fields)
  end
end
