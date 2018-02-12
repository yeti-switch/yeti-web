# https://github.com/activerecord-hackery/ransack/issues/321
Ransack.configure do |config|
  { array_contained_within:           :contained_within,
    array_contained_within_or_equals: :contained_within_or_equals,
    array_contains:                   :contains,
    array_contains_or_equals:         :contains_or_equals,
    array_overlap:                    :overlap
  }.each do |rp, ap|
    config.add_predicate rp, arel_predicate: ap, wants_array: true
  end
end
