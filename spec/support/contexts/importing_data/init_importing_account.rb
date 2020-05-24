# frozen_string_literal: true

shared_context :init_importing_account do |args|
  args ||= {}

  before do
    fields = {
      name: 'T-vendor',
      contractor_id: @contractor.id,
      contractor_name: @contractor.name,
      is_changed: true
    }.merge(args)

    @importing_account = FactoryGirl.create(:importing_account, fields)
  end
end
