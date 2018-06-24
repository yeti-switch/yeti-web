RSpec.shared_context :init_importing_rateplan do |args|

  args ||= {}

  before do
    fields = {
        name: 'PBXww-Canada-RP'
    }.merge(args)

    @importing_rateplan = FactoryGirl.create(:importing_rateplan, fields)
  end

end
