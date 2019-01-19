# frozen_string_literal: true

require 'spec_helper'

RSpec.describe YetiMail do
  describe '.email_message' do
    subject do
      YetiMail.email_message(log_id)
    end

    before do
      System::SmtpConnection.create!(
        name: 'test',
        host: 'smtp.example.com',
        port: 25,
        from_address: 'sender@example.com',
        global: true
      )
    end
    let(:log_id) { log.id }
    let!(:log) do
      Log::EmailLog.create!(
        contact_id: contact.id,
        smtp_connection_id: contact.smtp_connection.id,
        mail_to: contact.email,
        mail_from: 'rspec@example.com',
        subject: 'test',
        attachment_id: [attachment.id],
        msg: '<h1>Hello</h1>'
      )
    end
    let(:attachment) do
      Notification::Attachment.create!(filename: 'test.txt', data: 'some data')
    end
    let(:contact) do
      Billing::Contact.create!(email: 'test@example.com')
    end

    it 'renders the headers and body' do
      expect(subject.subject).to eq('test')
      expect(subject.to).to eq([log.mail_to])
      expect(subject.from).to eq([log.mail_from])
      expect(subject.body.encoded).to include(log.msg)
    end
  end
end
