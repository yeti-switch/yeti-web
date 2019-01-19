# frozen_string_literal: true

RSpec.shared_examples :does_not_destroy_record do |errors: {}|
  let(:expected_record_errors) { errors }

  it 'does not destroy record' do
    expect(subject).to eq(false)
    expect(
      record.class.where(record.class.primary_key => record[record.class.primary_key]).count
    ).to eq(1)
    expected_errors = expected_record_errors.map { |k, v| [k, Array.wrap(v)] }.to_h
    expect(subject.errors.messages).to match(expected_errors)
  end
end
