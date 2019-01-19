# frozen_string_literal: true

RSpec.shared_examples :updates_record do
  let(:expected_record_attrs) { update_params }

  it 'updates record' do
    expect(subject).to eq(true), "expected to return true, but got false\n#{record.errors.messages}"
    expect(record.errors).to be_empty
    expect(record).to have_attributes(expected_record_attrs)
  end
end
