require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  driver_options = {
    js_errors: false,
    timeout: 40,
    phantomjs_options: ['--load-images=no' ]
  }
  Capybara::Poltergeist::Driver.new(app, driver_options)
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

Capybara.server_port = 9797
Capybara.always_include_port = true
Capybara.run_server = true
Capybara.current_session.driver.reset!
Capybara.default_max_wait_time = 60

require 'capybara-screenshot/cucumber'
