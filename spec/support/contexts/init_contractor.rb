shared_context :init_contractor do |args|

  args ||= {}

  before do
    fields = {
        name: 'TestTelecom',
        vendor: true
    }.merge(args)

    @contractor = FactoryGirl.create(:contractor, fields)
  end
end