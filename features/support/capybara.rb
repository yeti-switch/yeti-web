require 'capybara/rspec'
require 'capybara-screenshot/rspec'


Capybara.register_driver(:headless_chrome) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w[headless disable-gpu] }
  )

  Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      desired_capabilities: capabilities
  )
end

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

Capybara.server = :webrick
Capybara.server_port = 9797
Capybara.always_include_port = true
Capybara.run_server = true
Capybara.current_session.driver.reset!
Capybara.default_max_wait_time = 60

