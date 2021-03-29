# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_data_item('123', 'foos')
#   expect(response_json[:data]).to have_jsonapi_data_item(123, :foos)
#   expect(response_json[:included]).to have_jsonapi_data_item(456, 'bars')
RSpec::Matchers.define :have_jsonapi_data_item do |expected_id, expected_type|
  expected_id = expected_id.to_s
  expected_type = expected_type.to_s

  match do |actual|
    return false if actual.nil?

    actual_data = actual.detect do |r|
      values_match?(expected_id, r[:id]) && values_match?(expected_type, r[:type])
    end

    !actual_data.nil?
  end

  description do
    "have jsonapi data item with type #{expected_type} and id #{expected_id}"
  end

  failure_message do |actual|
    expected_id_formatted = RSpec::Support::ObjectFormatter.format(expected_id)
    expected_type_formatted = RSpec::Support::ObjectFormatter.format(expected_type)
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
    [
      "expected jsonapi data to include item with type #{expected_type_formatted} and id #{expected_id_formatted},",
      '     but not found',
      "     jsonapi data #{actual_formatted}"
    ].join("\n")
  end
end
