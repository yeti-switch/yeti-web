# frozen_string_literal: true

require 'config'
require 'yeti_config_loader'

Config.class_eval do
  def self.setting_files(config_root, _env)
    [
      File.join(config_root, 'yeti_web.yml').to_s
    ].freeze
  end
end

begin
  YetiConfigLoader.call
rescue YetiConfigLoader::Error => e
  warn e.message
  exit 1 # rubocop:disable Rails/Exit
end

require 'system_info_configs'
require 'custom_struct'

system_info_path = Rails.root.join('config/system_info.yml')
SystemInfoConfigs.load_file(system_info_path) if File.exist?(system_info_path)
