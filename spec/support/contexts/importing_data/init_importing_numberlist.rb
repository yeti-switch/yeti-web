# frozen_string_literal: true

shared_context :init_importing_numberlist do |args|
  args ||= {}

  before do
    fields = {}.merge(args)

    @importing_numberlist = FactoryGirl.create(:importing_numberlist, fields)
  end
end
