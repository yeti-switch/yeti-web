# frozen_string_literal: true

shared_context :init_pop do |args|
  args ||= {}

  before do
    fields = {
      name: 'Local POP',
      id: 500
    }.merge(args)

    @pop = FactoryBot.create(:pop, fields)
  end
end
