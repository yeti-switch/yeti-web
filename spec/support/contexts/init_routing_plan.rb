shared_context :init_routing_plan do |args|

  args ||= {}

  before do
    fields = {
        name: 'Default routing',
        more_specific_per_vendor: true
    }.merge(args)

    @routing_plan = FactoryGirl.create(:routing_plan, fields)
  end

end