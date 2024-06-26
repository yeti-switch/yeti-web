# frozen_string_literal: true

RSpec.shared_examples :jsonapi_filters_by_inet_field do |attr_name|
  describe "by #{attr_name}" do
    include_context :ransack_filter_setup

    let!(:suitable_record) { create_record attr_name => '0.0.0.0' }
    let!(:other_record) { create_record attr_name => '1.1.1.1' }

    context 'equal operator' do
      let(:filter_key) { "#{attr_name}_eq" }
      let(:filter_value) { '0.0.0.0' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'not equal operator' do
      let(:filter_key) { "#{attr_name}_not_eq" }
      let(:filter_value) { '1.1.1.1' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'in operator' do
      let(:filter_key) { "#{attr_name}_in" }
      let(:filter_value) { '0.0.0.0,2.2.2.2' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end

    context 'not_in operator' do
      let(:filter_key) { "#{attr_name}_not_in" }
      let(:filter_value) { '1.1.1.1,2.2.2.2' }

      before { subject }

      it { expect(response_ids).to include primary_key_for(suitable_record) }
      it { expect(response_ids).not_to include primary_key_for(other_record) }
    end
  end
end
