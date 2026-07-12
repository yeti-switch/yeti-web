# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_number_field do |attr_name, options|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    let(:greater_value) { options.try(:[], :max_value) || 2 }
    let(:smaller_value) { greater_value - 1 }
    # Two records cover every numeric operator; shared across all operators
    # instead of re-created per operator context.
    let!(:smaller_record) { create_record attr_name => smaller_value }
    let!(:greater_record) { create_record attr_name => greater_value }

    it "filters by #{attr_name}" do
      aggregate_failures do
        assert_filter "#{attr_name}_eq", smaller_value, includes: smaller_record, excludes: greater_record
        assert_filter "#{attr_name}_not_eq", smaller_value, includes: greater_record, excludes: smaller_record
        assert_filter "#{attr_name}_lt", greater_value, includes: smaller_record, excludes: greater_record
        assert_filter "#{attr_name}_lteq", smaller_value, includes: smaller_record, excludes: greater_record
        assert_filter "#{attr_name}_gt", smaller_value, includes: greater_record, excludes: smaller_record
        assert_filter "#{attr_name}_gteq", greater_value, includes: greater_record, excludes: smaller_record
        assert_filter "#{attr_name}_in", "#{greater_value},999", includes: greater_record, excludes: smaller_record
        assert_filter "#{attr_name}_not_in", "#{smaller_value},999", includes: greater_record, excludes: smaller_record
      end
    end
  end
end
