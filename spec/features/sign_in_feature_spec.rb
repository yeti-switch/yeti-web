RSpec.describe 'the signin process', :type => :feature do
  it 'signs me in' do
    admin_user = FactoryGirl.create(:admin_user)
    login_as(admin_user, :scope => :admin_user)
    visit root_path
    puts page.body
  end
end
