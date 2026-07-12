# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_datetime_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    let(:greater_value) { Date.today }
    let(:smaller_value) { Date.yesterday }
    # Two records cover every datetime operator; shared across all operators
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
        assert_filter "#{attr_name}_in", "#{greater_value},#{DateTime.now}", includes: greater_record, excludes: smaller_record
        assert_filter "#{attr_name}_not_in", "#{smaller_value},#{DateTime.now}", includes: greater_record, excludes: smaller_record
      end
    end
  end
end
