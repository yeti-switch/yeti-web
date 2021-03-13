# frozen_string_literal: true

#   expect(response_json[:data]).to have_jsonapi_data_items([1, 2])
#   expect(response_json[:data]).to have_jsonapi_data_items([1, 2], :registrations)
#   expect(response_json[:data]).to have_jsonapi_data_items([1, 2], 'registrations')
RSpec::Matchers.define :have_jsonapi_data_items do |expected_ids, type: nil, strict_order: false|
  expected_ids = expected_ids.map(&:to_s)
  expected_type = type ? type.to_s : nil

  match do |actual|
    unless expected_type.nil?
      actual_types = actual.map { |r| r[:type] } rescue [] # rubocop:disable Style/RescueModifier
      return false unless actual_types.all? { |type| values_match?(expected_type, type) }
    end

    @id_check = true
    expected_ids = match_array(expected_ids) unless strict_order
    actual_ids = actual.map { |r| r[:id] } rescue nil # rubocop:disable Style/RescueModifier
    values_match? expected_ids, actual_ids
  end

  description do
    "have jsonapi data items with ids #{RSpec::Support::ObjectFormatter.format(expected_ids)} type #{expected_type}"
  end

  failure_message do |actual|
    if @id_check
      expected_ids = match_array(expected_ids) unless strict_order
      expected_ids_formatted = RSpec::Support::ObjectFormatter.format(expected_ids)
      actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
      actual_ids = actual.map { |r| r[:id] } rescue nil # rubocop:disable Style/RescueModifier
      actual_ids_formatted = RSpec::Support::ObjectFormatter.format(actual_ids)
      [
        "expected jsonapi data items ids to match #{expected_ids_formatted},",
        "     but got #{actual_ids_formatted}",
        "     jsonapi data #{actual_formatted}"
      ].join("\n")
    else
      expected_type_formatted = RSpec::Support::ObjectFormatter.format(expected_type)
      actual_formatted = RSpec::Support::ObjectFormatter.format(actual)
      actual_types = actual.map { |r| r[:type] } rescue nil # rubocop:disable Style/RescueModifier
      actual_types_formatted = RSpec::Support::ObjectFormatter.format(actual_types)
      [
        "expected jsonapi data items type to be #{expected_type_formatted},",
        "     but got #{actual_types_formatted}",
        "     jsonapi data #{actual_formatted}"
      ].join("\n")
    end
  end
end
