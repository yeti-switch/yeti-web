# frozen_string_literal: true

RSpec.shared_examples :sends_email_to_contacts do
  # let(:expected_contacts) { ... }
  # let(:expected_subject) { ... }
  # let(:expected_message) { ... }

  it 'sends email to contacts' do
    expect(expected_contacts).not_to be_empty
    expect(ContactEmailSender).to receive(:batch_send_emails).with(
      match_array(expected_contacts),
      subject: expected_subject,
      message: expected_message
    ).once

    subject
  end
end
