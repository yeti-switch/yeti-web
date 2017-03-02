shared_context :init_contractor do |args|

  args ||= {}

  before do
    fields = {
        name: 'FreeTelecom',
        vendor: true
    }.merge(args)

    @contractor = FactoryGirl.create(:contractor, fields)
  end
end