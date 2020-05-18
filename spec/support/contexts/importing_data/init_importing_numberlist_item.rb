# frozen_string_literal: true

shared_context :init_importing_numberlist_item do |args|
  args ||= {}

  before do
    fields = { is_changed: true }.merge(args)

    @importing_numberlist_item = FactoryBot.create(:importing_numberlist_item, fields)
  end
end
