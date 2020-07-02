# frozen_string_literal: true

RSpec::Matchers.define :eq_time_string do |expected|
  expected_time = (expected.is_a?(String) ? Time.parse(expected) : expected).change(usec: 0)

  match do |actual|
    actual_time = Time.parse(actual).change(usec: 0)
    actual_time == expected_time
  end
  description do
    "eq time string to #{expected_time}"
  end
end
