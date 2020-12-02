# frozen_string_literal: true

Rails.configuration.yeti_web = begin
  YAML.load_file(Rails.root.join('config/yeti_web.yml')).freeze
                               rescue StandardError => e
                                 raise StandardError, "Can't load /config/yeti_web.yml, message: #{e.message}"
end

allowed_rules = %i[allow disallow raise]

no_config_rule = Rails.configuration.yeti_web['role_policy']['when_no_config']
if allowed_rules.exclude? no_config_rule&.to_sym
  raise StandardError, "invalid value #{no_config_rule.inspect} for yeti_web.yml role_policy.when_no_config, valid values #{allowed_rules}"
end

no_policy_rule = Rails.configuration.yeti_web['role_policy']['when_no_policy_class']
if allowed_rules.exclude? no_policy_rule&.to_sym
  raise StandardError, "invalid value #{no_policy_rule.inspect} for yeti_web.yml role_policy.when_no_policy_class, valid values #{allowed_rules}"
end

system_info_path = Rails.root.join('config/system_info.yml')
SystemInfoConfigs.load_file(system_info_path) if File.exist?(system_info_path)
