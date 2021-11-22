# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filter_by_external_id do
  include_context :ransack_filter_setup
  let(:filter_key) { :external_id }
  let(:filter_value) { subject_record.external_id }

  include_examples :jsonapi_filter_by, :external_id do
    let(:attr_value) { subject_record.external_id }
  end
end
