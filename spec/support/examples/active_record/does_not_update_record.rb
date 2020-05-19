# frozen_string_literal: true

RSpec.shared_examples :does_not_update_record do |errors: {}|
  # requires let(:record) to specified
  let(:expected_record_errors) { errors }

  it 'does not update record' do
    expect(subject).to eq(false)
    expected_errors = expected_record_errors.transform_values { |v| Array.wrap(v) }
    expect(record.errors.messages).to match(expected_errors)
  end
end
