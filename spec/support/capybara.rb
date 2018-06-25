require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :poltergeist do |app|
  driver_options = {
    js_errors: true,
    timeout: 40,
    phantomjs: Phantomjs.path,
    phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any']
  }
  Capybara::Poltergeist::Driver.new(app, driver_options)
end

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
