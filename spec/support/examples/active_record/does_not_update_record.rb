RSpec.shared_examples :does_not_update_record do |errors: {}|
  let(:expected_record_errors) { errors }

  it 'does not update record' do
    expect(subject).to eq(false)
    expected_errors = expected_record_errors.map { |k, v| [k, Array.wrap(v)] }.to_h
    expect(subject.errors.messages).to match(expected_errors)
  end
end
