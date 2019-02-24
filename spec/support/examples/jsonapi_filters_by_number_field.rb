# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_number_field do |attr_name|
  let(:subject_request) do
    get :index, params: { filter: { filter_key => filter_value } }
  end

  subject { response_data.map { |r| r['id'] } }

  context 'equal operator' do
    let(:filter_key) { "#{attr_name}_eq" }
    let(:filter_value) { 1 }
    let!(:suitable_record) { create factory, attr_name => 1 }
    let!(:other_record) { create factory, attr_name => 2 }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'not equal operator' do
    let(:filter_key) { "#{attr_name}_not_eq" }
    let(:filter_value) { 1 }
    let!(:suitable_record) { create factory, attr_name => 2 }
    let!(:other_record) { create factory, attr_name => 1 }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'less then operator' do
    let(:filter_key) { "#{attr_name}_lt" }
    let(:filter_value) { 2 }
    let!(:suitable_record) { create factory, attr_name => 1 }
    let!(:other_record) { create factory, attr_name => 2 }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'less then or equal operator' do
    let(:filter_key) { "#{attr_name}_lteq" }
    let(:filter_value) { 2 }
    let!(:suitable_record) { create factory, attr_name => 2 }
    let!(:other_record) { create factory, attr_name => 3 }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'greater then operator' do
    let(:filter_key) { "#{attr_name}_gt" }
    let(:filter_value) { 1 }
    let!(:suitable_record) { create factory, attr_name => 2 }
    let!(:other_record) { create factory, attr_name => 1 }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end

  context 'greater then or equal operator' do
    let(:filter_key) { "#{attr_name}_gteq" }
    let(:filter_value) { 2 }
    let!(:suitable_record) { create factory, attr_name => 2 }
    let!(:other_record) { create factory, attr_name => 1 }

    before { subject_request }

    it { is_expected.to include suitable_record.id.to_s }
    it { is_expected.not_to include other_record.id.to_s }
  end
end
