# frozen_string_literal: true

RSpec.shared_examples :validation_no_error_on_field do |error_field|
  it 'has not expected error' do
    expect(subject).not_to have_key(error_field)
  end
end
