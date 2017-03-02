shared_context :init_account do |args|

  args ||= {}

  before do
    fields = {
        name: 'Telefonica-vendor',
        contractor_id: @contractor.id
    }.merge(args)

    @account = FactoryGirl.create(:account, fields)
  end

end