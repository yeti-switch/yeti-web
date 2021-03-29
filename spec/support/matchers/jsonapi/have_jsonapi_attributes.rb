# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_attributes(foo: 'bar', bar: 'baz')
#   expect(response_json[:data]).to have_jsonapi_attributes hash_including(foo: 'bar')
RSpec::Matchers.define :have_jsonapi_attributes do |expected|
  match do |actual|
    actual_attributes = actual[:attributes] rescue nil # rubocop:disable Style/RescueModifier
    values_match? expected, actual_attributes
  end

  description do
    "have jsonapi attributes #{RSpec::Support::ObjectFormatter.format(expected)}"
  end

  failure_message do |actual|
    expected_formatted = RSpec::Support::ObjectFormatter.format(expected)
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
    actual_attributes = actual[:attributes] rescue nil # rubocop:disable Style/RescueModifier
    actual_attributes_formatted = RSpec::Support::ObjectFormatter.format(actual_attributes)
    [
      "expected jsonapi data.attributes to be #{expected_formatted},",
      "     but got #{actual_attributes_formatted}",
      "     jsonapi data #{actual_formatted}"
    ].join("\n")
  end
end
