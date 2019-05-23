# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_number_field do |attr_name, options|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup, options

    let(:greater_value) { options.try(:[], :max_value) || 2 }
    let(:smaller_value) { greater_value - 1 }

    context 'equal operator' do
      let(:filter_key) { "#{attr_name}_eq" }
      let(:filter_value) { smaller_value }
      let!(:suitable_record) { create_record attr_name => smaller_value }
      let!(:other_record) { create_record attr_name => greater_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'not equal operator' do
      let(:filter_key) { "#{attr_name}_not_eq" }
      let(:filter_value) { smaller_value }
      let!(:suitable_record) { create_record attr_name => greater_value }
      let!(:other_record) { create_record attr_name => smaller_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'less then operator' do
      let(:filter_key) { "#{attr_name}_lt" }
      let(:filter_value) { greater_value }
      let!(:suitable_record) { create_record attr_name => smaller_value }
      let!(:other_record) { create_record attr_name => greater_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'less then or equal operator' do
      let(:filter_key) { "#{attr_name}_lteq" }
      let(:filter_value) { smaller_value }
      let!(:suitable_record) { create_record attr_name => smaller_value }
      let!(:other_record) { create_record attr_name => greater_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'greater then operator' do
      let(:filter_key) { "#{attr_name}_gt" }
      let(:filter_value) { smaller_value }
      let!(:suitable_record) { create_record attr_name => greater_value }
      let!(:other_record) { create_record attr_name => smaller_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'greater then or equal operator' do
      let(:filter_key) { "#{attr_name}_gteq" }
      let(:filter_value) { greater_value }
      let!(:suitable_record) { create_record attr_name => greater_value }
      let!(:other_record) { create_record attr_name => smaller_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'in operator' do
      let(:filter_key) { "#{attr_name}_in" }
      let(:filter_value) { "#{greater_value},999" }
      let!(:suitable_record) { create_record attr_name => greater_value }
      let!(:other_record) { create_record attr_name => smaller_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end

    context 'not_in operator' do
      let(:filter_key) { "#{attr_name}_not_in" }
      let(:filter_value) { "#{smaller_value},999" }
      let!(:suitable_record) { create_record attr_name => greater_value }
      let!(:other_record) { create_record attr_name => smaller_value }

      before { subject_request }

      it { is_expected.to include primary_key_for(suitable_record) }
      it { is_expected.not_to include primary_key_for(other_record) }
    end
  end
end
