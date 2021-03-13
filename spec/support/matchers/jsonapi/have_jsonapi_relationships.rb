# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_relationships(:foo, :'bar-baz')
RSpec::Matchers.define :have_jsonapi_relationships do |*expected|
  expected_names = expected.map(&:to_sym)

  match do |actual|
    actual_names = actual[:relationships].keys rescue nil # rubocop:disable Style/RescueModifier
    values_match? match_array(expected_names), actual_names
  end

  description do
    "have jsonapi relationships #{expected_names.join(', ')}"
  end

  failure_message do |actual|
    expected_names_formatted = RSpec::Support::ObjectFormatter.format(expected_names)
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
    actual_names = actual[:relationships].keys rescue nil # rubocop:disable Style/RescueModifier
    actual_names_formatted = RSpec::Support::ObjectFormatter.format(actual_names)
    [
      "expected jsonapi data.relationships names to be #{expected_names_formatted},",
      "     but got #{actual_names_formatted}",
      "     jsonapi data #{actual_formatted}"
    ].join("\n")
  end
end
