# frozen_string_literal: true

shared_context :init_gateway_group do |args|
  args ||= {}

  before do
    fields = {
      name: 'GwGroup',
      vendor_id: @contractor.id
    }.merge(args)

    @gateway_group = FactoryBot.create(:gateway_group, fields)
  end
end
