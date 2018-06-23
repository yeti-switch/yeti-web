RSpec.shared_context :init_rateplan do |args|

  args ||= {}

  before do
    fields = {
        name: 'PBXww-Canada-RP'
    }.merge(args)

    @rateplan = FactoryGirl.create(:rateplan, fields)
  end

end
