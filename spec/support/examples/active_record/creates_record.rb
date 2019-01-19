# frozen_string_literal: true

RSpec.shared_examples :creates_record do
  let(:expected_record_attrs) { create_params }

  it 'creates record' do
    expect(subject).to be_persisted, "expected subject to be persisted but it's new_record\n#{subject.errors.messages}"
    expect(subject.errors).to be_empty
    expect(subject).to have_attributes(expected_record_attrs)
  end
end
