Rails.configuration.yeti_web = begin
    YAML.load_file(File.join(Rails.root, '/config/yeti_web.yml')).freeze
rescue StandardError => e
   raise StandardError.new("Can't load /config/yeti_web.yml, message: #{e.message}")
end

allowed_rules = [:allow, :disallow, :raise]

no_config_rule = Rails.configuration.yeti_web['role_policy']['when_no_config']
if allowed_rules.exclude? no_config_rule.try!(:to_sym)
  raise StandardError, "invalid value #{no_config_rule.inspect} for yeti_web.yml role_policy.when_no_config, valid values #{allowed_rules}"
end

no_policy_rule = Rails.configuration.yeti_web['role_policy']['when_no_policy_class']
if allowed_rules.exclude? no_policy_rule.try!(:to_sym)
  raise StandardError, "invalid value #{no_policy_rule.inspect} for yeti_web.yml role_policy.when_no_policy_class, valid values #{allowed_rules}"
end
