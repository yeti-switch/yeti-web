RSpec.shared_context :init_importing_disconnect_policy do |args|

  args ||= {}

  before do
    fields = {
        name: 'example'
    }.merge(args)

    @importing_disconnect_policy = FactoryGirl.create(:importing_disconnect_policy, fields)
  end

end
