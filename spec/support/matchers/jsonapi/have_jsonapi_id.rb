# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_id '123'
#   expect(response_json[:data]).to have_jsonapi_id 123
RSpec::Matchers.define :have_jsonapi_id do |expected|
  expected_id = expected.to_s

  match do |actual|
    actual_id = actual[:id] rescue nil # rubocop:disable Style/RescueModifier
    values_match? expected_id, actual_id
  end

  description do
    "have jsonapi id #{expected_id}"
  end

  failure_message do |actual|
    expected_id_formatted = RSpec::Support::ObjectFormatter.format(expected_id)
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
    actual_id = actual[:id] rescue nil # rubocop:disable Style/RescueModifier
    actual_id_formatted = RSpec::Support::ObjectFormatter.format(actual_id)
    [
      "expected jsonapi data.id to be #{expected_id_formatted},",
      "     but got #{actual_id_formatted}",
      "     jsonapi data #{actual_formatted}"
    ].join("\n")
  end
end
