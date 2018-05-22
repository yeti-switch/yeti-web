# https://github.com/activerecord-hackery/ransack/issues/321
Ransack.configure do |config|
  { array_contains: :contains }.each do |rp, ap|
    config.add_predicate rp, arel_predicate: ap, wants_array: true
  end
  config.ignore_unknown_conditions = false
  config.sanitize_custom_scope_booleans = false
end
