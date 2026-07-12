# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_uuid_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    let!(:suitable_record) { create_record }
    let!(:other_record) { create_record }

    it "filters by #{attr_name}" do
      suitable_uuid = suitable_record.reload.try(attr_name)
      other_uuid = other_record.reload.try(attr_name)
      aggregate_failures do
        assert_filter "#{attr_name}_eq", suitable_uuid, includes: suitable_record, excludes: other_record
        assert_filter "#{attr_name}_not_eq", other_uuid, includes: suitable_record, excludes: other_record
        assert_filter "#{attr_name}_in", "#{suitable_uuid},#{SecureRandom.uuid}", includes: suitable_record, excludes: other_record
        assert_filter "#{attr_name}_not_in", "#{other_uuid},#{SecureRandom.uuid}", includes: suitable_record, excludes: other_record
      end
    end
  end
end
