# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_string_field do |attr_name|
  let(:subject_request) do
    get :index, params: { filter: { filter_key => filter_value } }
  end

  subject do
    response_data.map { |r| r['id'] }
  end

  context 'match operator' do
    let(:filter_key) { "#{attr_name}_matches" }
    let(:filter_value) { 'str%' }
    let!(:suitable_record) { create factory, attr_name => 'string' }
    let!(:other_record) { create factory, attr_name => 'other' }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'equal operator' do
    let(:filter_key) { "#{attr_name}_eq" }
    let(:filter_value) { 'str' }
    let!(:suitable_record) { create factory, attr_name => 'str' }
    let!(:other_record) { create factory, attr_name => 'string' }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'not equal operator' do
    let(:filter_key) { "#{attr_name}_not_eq" }
    let(:filter_value) { 'str' }
    let!(:suitable_record) { create factory, attr_name => 'string' }
    let!(:other_record) { create factory, attr_name => 'str' }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end
end
