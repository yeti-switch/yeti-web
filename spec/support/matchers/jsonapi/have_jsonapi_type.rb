# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_type 'users'
RSpec::Matchers.define :have_jsonapi_type do |expected|
  expected_type = expected.to_s

  match do |actual|
    actual_type = actual[:type] rescue nil # rubocop:disable Style/RescueModifier
    values_match? expected_type, actual_type
  end

  description do
    "have jsonapi type #{expected_type}"
  end

  failure_message do |actual|
    expected_type_formatted = RSpec::Support::ObjectFormatter.format(expected_type)
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
    actual_type = actual[:id] rescue nil # rubocop:disable Style/RescueModifier
    actual_type_formatted = RSpec::Support::ObjectFormatter.format(actual_type)
    [
      "expected jsonapi data.type to be #{expected_type_formatted},",
      "     but got #{actual_type_formatted}",
      "     jsonapi data #{actual_formatted}"
    ].join("\n")
  end
end
