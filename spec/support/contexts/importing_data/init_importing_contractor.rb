# frozen_string_literal: true

shared_context :init_importing_contractor do |args|
  args ||= {}

  before do
    fields = {
      name: 'TF-EU-RG',
      vendor: true
    }.merge(args)

    @importing_contractor = FactoryGirl.create(:importing_contractor, fields)
  end
end
