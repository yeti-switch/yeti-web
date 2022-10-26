# frozen_string_literal: true

RSpec.shared_examples :does_not_send_email do
  # let(:expected_contacts) { ... }
  # let(:expected_subject) { ... }
  # let(:expected_message) { ... }

  it 'does not send email' do
    expect(ContactEmailSender).not_to receive(:new)
    subject
  end
end
