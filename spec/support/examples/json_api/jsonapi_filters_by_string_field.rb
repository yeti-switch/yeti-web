# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_string_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    context 'start operator' do
      let(:filter_key) { "#{attr_name}_start" }
      let(:filter_value) { 'str' }
      let!(:suitable_record) { create_record attr_name => 'string' }
      let!(:other_record) { create_record attr_name => 'other' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'end operator' do
      let(:filter_key) { "#{attr_name}_end" }
      let(:filter_value) { 'ing' }
      let!(:suitable_record) { create_record attr_name => 'string' }
      let!(:other_record) { create_record attr_name => 'other' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'cont operator' do
      let(:filter_key) { "#{attr_name}_cont" }
      let(:filter_value) { 'string' }
      let!(:suitable_record) { create_record attr_name => 'string' }
      let!(:other_record) { create_record attr_name => 'other' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'equal operator' do
      let(:filter_key) { "#{attr_name}_eq" }
      let(:filter_value) { 'str' }
      let!(:suitable_record) { create_record attr_name => 'str' }
      let!(:other_record) { create_record attr_name => 'string' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'not equal operator' do
      let(:filter_key) { "#{attr_name}_not_eq" }
      let(:filter_value) { 'str' }
      let!(:suitable_record) { create_record attr_name => 'string' }
      let!(:other_record) { create_record attr_name => 'str' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'in operator' do
      let(:filter_key) { "#{attr_name}_in" }
      let(:filter_value) { 'str,str2' }
      let!(:suitable_record) { create_record attr_name => 'str' }
      let!(:other_record) { create_record attr_name => 'string' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'not_in operator' do
      let(:filter_key) { "#{attr_name}_not_in" }
      let(:filter_value) { 'string,str2' }
      let!(:suitable_record) { create_record attr_name => 'str' }
      let!(:other_record) { create_record attr_name => 'string' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'cont operator' do
      let(:filter_key) { "#{attr_name}_cont_any" }
      let(:filter_value) { 'string,val' }
      let!(:suitable_record) { create_record attr_name => 'string' }
      let!(:other_record) { create_record attr_name => 'other' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end
  end
end
