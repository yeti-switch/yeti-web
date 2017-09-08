Given(/^A new admin user with username "(.*?)"$/) do |username|
  FactoryGirl.create :admin_user, username: username,
                     email: 'admin1@example.com',
                     password: 'password'
end

And(/^I signed in as admin user with username "(.*?)"$/) do |username|
  visit "login"
  sleep 1
  find(:css, "input#admin_user_username").set(username)
  find(:css, "input#admin_user_password").set('password')
  find('[type="submit"]').click
end

And (/^I open the "(.*?)" page$/) do |path|
  visit "/#{path}"
  sleep 2
end