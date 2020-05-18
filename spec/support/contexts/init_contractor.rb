# frozen_string_literal: true

shared_context :init_contractor do |args|
  args ||= {}

  before do
    fields = {
      name: 'TestTelecom',
      vendor: true
    }.merge(args)

    @contractor = FactoryBot.create(:contractor, fields)
  end
end
