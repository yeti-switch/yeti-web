# frozen_string_literal: true

RSpec.describe YetiMail do
  describe '.email_message' do
    subject do
      YetiMail.email_message(log)
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
    let!(:log) do
      ContactEmailSender.new(contact).send_email(
        subject: 'test',
        message: '<h1>Hello</h1>',
        attachments: [attachment]
      )
    end
    let(:attachment) do
      FactoryBot.create(:notification_attachment, filename: 'test.txt', data: 'some data')
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
