Capybara.register_driver :poltergeist do |app|
  driver_options = {
    js_errors: false,
    timeout: 40,
    phantomjs: Phantomjs.path,
    phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any']
  }
  Capybara::Poltergeist::Driver.new(app, driver_options)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
