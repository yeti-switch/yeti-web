RSpec.shared_examples :jsonapi_filter_by_name do
  include_examples :jsonapi_filter_by, :name do
    let(:attr_value) { subject_record.name }
  end
end
