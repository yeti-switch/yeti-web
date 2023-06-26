# frozen_string_literal: true

begin
  @cfg = Rails.application.config_for('click_house')
rescue StandardError
end

unless @cfg.nil?
  ClickHouse.config do |config|
    config.logger = Rails.logger
    config.assign(@cfg)
  end
end
