# frozen_string_literal: true

shared_context :init_importing_contractor do |args|
  args ||= {}

  before do
    fields = {
      name: 'TF-EU-RG',
      vendor: true,
      is_changed: true
    }.merge(args)

    @importing_contractor = FactoryBot.create(:importing_contractor, fields)
  end
end
