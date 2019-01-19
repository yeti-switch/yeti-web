# frozen_string_literal: true

RSpec.shared_examples :destroys_record do
  it 'destroys record' do
    expect(subject).to be_destroyed, "expected to be destroyed, but it's not\n#{record.errors.messages}"
    expect(record.errors).to be_empty
    expect(
      record.class.where(record.class.primary_key => record[record.class.primary_key]).count
    ).to eq(0)
  end
end
