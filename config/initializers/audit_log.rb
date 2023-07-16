# frozen_string_literal: true

# https://github.com/paper-trail-gem/paper_trail/blob/master/doc/pt_13_yaml_safe_load.md?plain=1#L30
# Below is required to use YAML serializer in papertrail gem.
Rails.application.config.after_initialize do
  ActiveRecord.use_yaml_unsafe_load = false
  ActiveRecord.yaml_column_permitted_classes = [
    ActiveRecord::Type::Time::Value,
    ActiveSupport::TimeWithZone,
    ActiveSupport::TimeZone,
    BigDecimal,
    Date,
    Symbol,
    Time
  ]
end
