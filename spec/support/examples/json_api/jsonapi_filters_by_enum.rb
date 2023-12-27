# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_enum do |filter_name_base|
  let(:enum_values_to_ids) { raise 'key - filter_value, value - record_ids' }
  let(:json_api_request_query) do
    (super() || {}).deep_merge(filter: { filter_name => filter_value })
  end

  before do
    raise 'enum_values_to_ids must have at least 3 keys' if enum_values_to_ids.size < 3
  end

  context "#{filter_name_base}_eq" do
    let(:filter_name) { "#{filter_name_base}_eq" }
    let(:filter_value) { enum_values_to_ids.keys.sample }
    let(:filtered_ids) { enum_values_to_ids[filter_value].map(&:to_s) }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { filtered_ids }
    end
  end

  context "#{filter_name_base}_not_eq" do
    let(:filter_name) { "#{filter_name_base}_not_eq" }
    let(:filter_value) { enum_values_to_ids.keys.sample }
    let(:filtered_ids) { enum_values_to_ids.except(filter_value).values.flatten.map(&:to_s) }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { filtered_ids }
    end
  end

  context "#{filter_name_base}_in" do
    let(:filter_name) { "#{filter_name_base}_in" }
    let(:filter_value) { filter_value_ids.join(',') }
    let(:filter_value_ids) { enum_values_to_ids.keys.sample(2) }
    let(:filtered_ids) { enum_values_to_ids.slice(*filter_value_ids).values.flatten.map(&:to_s) }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { filtered_ids }
    end
  end

  context "#{filter_name_base}_not_in" do
    let(:filter_name) { "#{filter_name_base}_not_in" }
    let(:filter_value) { filter_value_ids.join(',') }
    let(:filter_value_ids) { enum_values_to_ids.keys.sample(2) }
    let(:filtered_ids) { enum_values_to_ids.except(*filter_value_ids).values.flatten.map(&:to_s) }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { filtered_ids }
    end
  end
end
