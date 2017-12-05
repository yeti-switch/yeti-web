Given(/^A new admin user with username "(.*?)"$/) do |username|
  FactoryGirl.create :admin_user, username: username,
                     email: 'admin1@example.com',
                     password: 'password'
end

And(/^I signed in as admin user with username "(.*?)"$/) do |username|
  visit "/login"
  sleep 1
  within 'div#login' do
    find(:css, "input[type='text']").set(username)
    find(:css, "input[type='password']").set('password')
    find('[type="submit"]').click
  end
end

And (/^I open the "(.*?)" page$/) do |path|
  visit "/#{path}"
  sleep 2
end
