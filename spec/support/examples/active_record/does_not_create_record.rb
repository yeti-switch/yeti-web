# frozen_string_literal: true

RSpec.shared_examples :does_not_create_record do |errors: {}|
  let(:expected_record_errors) { errors }

  it 'does not create record' do
    expect(subject).to be_new_record
    expected_errors = expected_record_errors.map { |k, v| [k, Array.wrap(v)] }.to_h
    expect(subject.errors.messages).to match(expected_errors)
  end
end
