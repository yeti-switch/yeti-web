# frozen_string_literal: true

config_path = Rails.root.join('config/click_house.yml')
if config_path.exist?
  cfg = Rails.application.config_for(config_path)
  ClickHouse.config do |config|
    config.logger = Rails.logger
    config.assign(cfg)
  end
end
