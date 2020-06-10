# frozen_string_literal: true

RSpec.describe 'Index System Api Log Configs', type: :feature do
  include_context :login_as_admin
  it 'n+1 checks' do
    api_log_configs = create_list(:api_log_config, 2)
    visit api_log_configs_path
    api_log_configs.each do |api_log_config|
      expect(page).to have_css('.col-controller', text: api_log_config.controller)
    end
  end
end
