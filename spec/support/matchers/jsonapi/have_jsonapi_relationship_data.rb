# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_relationship_data(:foo, id: '123', type: 'foos')
#   expect(response_json[:data]).to_not have_jsonapi_relationship_data(:foo)
RSpec::Matchers.define :have_jsonapi_relationship_data do |expected_name, expected_data = nil|
  expected_name = expected_name.to_sym
  expected_data = expected_data.dup
  expected_data[:id] = expected_data[:id].to_s if expected_data.is_a?(Hash) && expected_data.key?(:id)

  match do |actual|
    actual_relationships = actual[:relationships] rescue nil # rubocop:disable Style/RescueModifier
    return false if actual_relationships.nil? || actual_relationships[expected_name].nil?

    actual_data = actual_relationships[expected_name][:data] rescue nil # rubocop:disable Style/RescueModifier
    return false if actual_data.nil?

    values_match? expected_data, actual_data
  end

  match_when_negated do |actual|
    actual_relationships = actual[:relationships] rescue nil # rubocop:disable Style/RescueModifier
    if actual_relationships.nil? || actual_relationships[expected_name].nil?
      @no_rel_key = true
      return false
    end

    !actual_relationships[expected_name].key?(:data)
  end

  description do
    "have jsonapi relationship data for #{expected_name}"
  end

  failure_message do |actual|
    expected_data_formatted = RSpec::Support::ObjectFormatter.format(expected_data)
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
    actual_relationships = actual[:relationships] rescue nil # rubocop:disable Style/RescueModifier
    actual_data = actual_relationships[expected_name][:data] rescue nil # rubocop:disable Style/RescueModifier
    actual_data_formatted = RSpec::Support::ObjectFormatter.format(actual_data)
    [
      "expected jsonapi data.relationships.#{expected_name}.data to be #{expected_data_formatted},",
      "     but got #{actual_data_formatted}",
      "     jsonapi data #{actual_formatted}"
    ].join("\n")
  end

  failure_message_when_negated do |actual|
    actual_formatted = RSpec::Support::ObjectFormatter.format(actual)

    if @no_rel_key
      [
        "expected jsonapi data.relationships.#{expected_name} to be present without data key",
        '     but no such relationship found',
        "     jsonapi data #{actual_formatted}"
      ].join("\n")
    else
      actual_relationships = actual[:relationships] rescue nil # rubocop:disable Style/RescueModifier
      actual_data = actual_relationships[expected_name][:data] rescue nil # rubocop:disable Style/RescueModifier
      actual_data_formatted = RSpec::Support::ObjectFormatter.format(actual_data)
      [
        "expected jsonapi data.relationships.#{expected_name} to not have data",
        "     but got #{actual_data_formatted}",
        "     jsonapi data #{actual_formatted}"
      ].join("\n")
    end
  end
end
