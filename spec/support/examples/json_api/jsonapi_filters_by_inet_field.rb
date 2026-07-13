# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_inet_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    let!(:suitable_record) { create_record attr_name => '0.0.0.0' }
    let!(:other_record) { create_record attr_name => '1.1.1.1' }

    it "filters by #{attr_name}" do
      aggregate_failures do
        assert_filter "#{attr_name}_eq", '0.0.0.0', includes: suitable_record, excludes: other_record
        assert_filter "#{attr_name}_not_eq", '1.1.1.1', includes: suitable_record, excludes: other_record
        assert_filter "#{attr_name}_in", '0.0.0.0,2.2.2.2', includes: suitable_record, excludes: other_record
        assert_filter "#{attr_name}_not_in", '1.1.1.1,2.2.2.2', includes: suitable_record, excludes: other_record
      end
    end
  end
end
