# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_string_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    # Three covering values exercise every string operator; shared across all
    # operators instead of re-created per operator context.
    let!(:record_str) { create_record attr_name => 'str' }
    let!(:record_string) { create_record attr_name => 'string' }
    let!(:record_other) { create_record attr_name => 'other' }

    it "filters by #{attr_name}" do
      aggregate_failures do
        assert_filter "#{attr_name}_start", 'str', includes: record_string, excludes: record_other
        assert_filter "#{attr_name}_end", 'ing', includes: record_string, excludes: record_other
        assert_filter "#{attr_name}_cont", 'string', includes: record_string, excludes: record_other
        assert_filter "#{attr_name}_eq", 'str', includes: record_str, excludes: record_string
        assert_filter "#{attr_name}_not_eq", 'str', includes: record_string, excludes: record_str
        assert_filter "#{attr_name}_in", 'str,str2', includes: record_str, excludes: record_string
        assert_filter "#{attr_name}_not_in", 'string,str2', includes: record_str, excludes: record_string
        assert_filter "#{attr_name}_cont_any", 'string,val', includes: record_string, excludes: record_other
      end
    end
  end
end
