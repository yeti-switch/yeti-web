# frozen_string_literal: true

RSpec.shared_examples :validation_error_on_field do |error_field, message|
  it 'has expected error' do
    expect(subject).to a_hash_including(error_field => message)
  end
end
