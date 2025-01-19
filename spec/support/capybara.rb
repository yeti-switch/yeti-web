# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/cuprite'
require 'capybara/active_admin/rspec'

chrome_log = ENV['CHROME_LOG_FILE'] ? File.open(ENV['CHROME_LOG_FILE'], 'w') : nil
build_cuprite_driver = lambda do |app, headless:|
  Capybara::Cuprite::Driver.new(
    app,
    headless: headless,
    logger: chrome_log,
    js_errors: true,
    # https://github.com/rubycdp/cuprite#debugging
    # page.driver.debug(binding)
    inspector: ENV['CHROME_INSPECTOR'],
    window_size: [1920, 1080],
    process_timeout: 10, # fix for macOS chrome
    timeout: 20, # to fix some rare cases on local machine and CI when browser hangs
    url_whitelist: %w[http://127.0.0.1:* http://localhost:* http://lvh.me:*],
    # https://peter.sh/experiments/chromium-command-line-switches/
    browser_options: {
      'disable-gpu' => nil,
      'no-sandbox' => nil,
      'disable-setuid-sandbox' => nil,
      'start-maximized' => nil
    }
  )
end

Capybara.register_driver :cuprite_headless do |app|
  build_cuprite_driver.call(app, headless: true)
end

Capybara.register_driver :cuprite do |app|
  build_cuprite_driver.call(app, headless: false)
end

Capybara::Screenshot.register_driver(:cuprite_headless) do |driver, path|
  driver.render(path, full: true)
end

Capybara::Screenshot.register_driver(:cuprite) do |driver, path|
  driver.render(path, full: true)
end

Capybara.raise_server_errors = true

# Capybara::Screenshot.screenshot_and_save_page
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara.server = :webrick
Capybara.server_host = '127.0.0.1'
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i if ENV['TEST_ENV_NUMBER']
Capybara.default_driver = :rack_test
Capybara.javascript_driver = ENV['JS_DRIVER'].presence&.to_sym || :cuprite_headless
