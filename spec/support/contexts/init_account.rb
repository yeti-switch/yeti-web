# frozen_string_literal: true

shared_context :init_account do |args|
  args ||= {}

  before do
    fields = {
      name: 'Test-vendor',
      contractor_id: @contractor.id
    }.merge(args)

    @account = FactoryBot.create(:account, fields)
  end
end
