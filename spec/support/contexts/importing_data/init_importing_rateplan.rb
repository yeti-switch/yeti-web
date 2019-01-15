# frozen_string_literal: true

shared_context :init_importing_rateplan do |args|
  args ||= {}

  before do
    fields = {
      name: 'a-RP'
    }.merge(args)

    @importing_rateplan = FactoryGirl.create(:importing_rateplan, fields)
  end
end
