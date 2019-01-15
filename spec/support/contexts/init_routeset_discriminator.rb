# frozen_string_literal: true

shared_context :init_routeset_discriminator do |args|
  args ||= {}

  before do
    fields = {
      name: 'Premium'
    }.merge(args)

    @routeset_discriminator = FactoryGirl.create(:routeset_discriminator, fields)
  end
end
