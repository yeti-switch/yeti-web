# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filter_by_name do
  include_context :ransack_filter_setup
  let(:filter_key) { :name }
  let(:filter_value) { subject_record.name }

  include_examples :jsonapi_filter_by, :name do
    let(:attr_value) { subject_record.name }
  end
end
