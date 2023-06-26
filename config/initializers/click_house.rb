# frozen_string_literal: true

begin
  @cfg = Rails.application.config_for('click_house')
  rescue
end

if not @cfg.nil?
ClickHouse.config do |config|
  config.logger = Rails.logger
  config.assign(@cfg)
end
end