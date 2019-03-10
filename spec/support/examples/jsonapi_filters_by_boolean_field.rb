# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_boolean_field do |attr_name|
  include_context :ransack_filter_setup

  context 'equal operator' do
    let(:filter_key) { "#{attr_name}_eq" }
    let(:filter_value) { true }
    let!(:suitable_record) { create_record attr_name => true }
    let!(:other_record) { create_record attr_name => false }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'not equal operator' do
    let(:filter_key) { "#{attr_name}_not_eq" }
    let(:filter_value) { true }
    let!(:suitable_record) { create_record attr_name => false }
    let!(:other_record) { create_record attr_name => true }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end
end
