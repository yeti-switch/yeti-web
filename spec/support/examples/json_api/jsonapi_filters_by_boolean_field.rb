# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_boolean_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    let!(:true_record) { create_record attr_name => true }
    let!(:false_record) { create_record attr_name => false }

    it "filters by #{attr_name}" do
      aggregate_failures do
        assert_filter "#{attr_name}_eq", true, includes: true_record, excludes: false_record
        assert_filter "#{attr_name}_not_eq", true, includes: false_record, excludes: true_record
      end
    end
  end
end
