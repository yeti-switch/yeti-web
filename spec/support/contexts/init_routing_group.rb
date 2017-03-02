shared_context :init_routing_group do |args|

  args ||= {}

  before do
    fields = {
        name: 'DIDWW Default routing'
    }.merge(args)

    @routing_group = FactoryGirl.create(:routing_group, fields)
  end

end