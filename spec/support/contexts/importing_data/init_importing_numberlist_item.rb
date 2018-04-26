shared_context :init_importing_numberlist_item do |args|

  args ||= {}

  before do
    fields = {}.merge(args)

    @importing_numberlist_item = FactoryGirl.create(:importing_numberlist_item, fields)
  end
end
