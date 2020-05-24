# frozen_string_literal: true

shared_context :init_importing_disconnect_policy do |args|
  args ||= {}

  before do
    fields = {
      name: 'example',
      is_changed: true
    }.merge(args)

    @importing_disconnect_policy = FactoryGirl.create(:importing_disconnect_policy, fields)
  end
end
