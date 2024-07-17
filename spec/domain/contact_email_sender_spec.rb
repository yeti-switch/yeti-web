# frozen_string_literal: true

RSpec.describe ContactEmailSender do
  describe '#send_email' do
    subject do
      described_class.new(contact).send_email(**service_params)
    end

    let(:expected_email_log_attrs) do
      {
        contact: contact,
        smtp_connection: global_smtp_connection,
        mail_to: contact.email,
        mail_from: global_smtp_connection.from_address,
        subject: service_params[:subject],
        msg: service_params[:message],
        attachment_id: nil
      }
    end

    shared_examples :creates_email_log do
      it 'creates email_log' do
        expect { subject }.to change { Log::EmailLog.count }.by(1)
        email_log = Log::EmailLog.last!
        expect(email_log).to have_attributes(expected_email_log_attrs)
      end

      it 'enqueues Worker::SendEmailLogJob' do
        subject
        email_log = Log::EmailLog.last!
        expect(Worker::SendEmailLogJob).to have_been_enqueued.with(email_log.id)
      end
    end

    let(:service_params) do
      { subject: 'Hello test', message: 'some <b>text</b>' }
    end
    let!(:global_smtp_connection) do
      FactoryBot.create(:smtp_connection, global: true, from_address: 'global@example.com')
    end
    let!(:contractor) do
      FactoryBot.create(:customer, smtp_connection: nil)
    end
    let!(:contact) do
      FactoryBot.create(:contact, contractor: contractor)
    end

    include_examples :creates_email_log

    context 'when contact.contractor has smtp_connection' do
      let!(:smtp_connection) do
        FactoryBot.create(:smtp_connection, from_address: 'some@example.com')
      end
      let(:contractor) do
        FactoryBot.create(:customer, smtp_connection: smtp_connection)
      end
      let(:expected_email_log_attrs) do
        super().merge smtp_connection: smtp_connection, mail_from: smtp_connection.from_address
      end

      include_examples :creates_email_log
    end

    context 'when contact does not have contractor' do
      let!(:contact) do
        FactoryBot.create(:contact, contractor: nil)
      end

      include_examples :creates_email_log
    end

    context 'with attachments' do
      let(:service_params) do
        super().merge attachments: FactoryBot.create_list(:notification_attachment, 2)
      end
      let(:expected_email_log_attrs) do
        super().merge attachment_id: service_params[:attachments].map(&:id)
      end

      include_examples :creates_email_log
    end

    context 'with attachments empty array' do
      let(:service_params) do
        super().merge attachments: []
      end

      include_examples :creates_email_log
    end

    context 'without message' do
      let(:service_params) do
        super().except(:message)
      end
      let(:expected_email_log_attrs) do
        super().merge msg: nil
      end

      include_examples :creates_email_log
    end

    context 'when there is NO any SMTP connection' do
      let(:global_smtp_connection) { nil }

      it 'should NOT create Email Log' do
        expect { subject }.not_to change(Log::EmailLog, :count)
      end

      it 'should NOT enqueue Job' do
        subject
        expect(Worker::SendEmailLogJob).not_to have_been_enqueued
      end
    end
  end

  describe '.batch_send_emails' do
    subject do
      described_class.batch_send_emails(contacts, **service_params)
    end

    let!(:global_smtp_conn) { FactoryBot.create(:smtp_connection, global: true) }
    let!(:contacts) do
      [
        FactoryBot.create(:contact, contractor: FactoryBot.create(:customer)),
        FactoryBot.create(:contact, contractor: nil),
        FactoryBot.create(:contact, contractor: FactoryBot.create(:vendor))
      ]
    end
    let(:service_params) do
      {
        subject: 'Hello test',
        message: 'some <b>text</b>',
        attachments: FactoryBot.create_list(:notification_attachment, 2)
      }
    end

    it 'send emails to all contacts' do
      contacts.each do |contact|
        sender_stub = instance_double(described_class)
        expect(described_class).to receive(:new).with(contact).once.and_return(sender_stub)
        expect(sender_stub).to receive(:send_email).with(service_params).once
      end
      subject
    end

    context 'when contacts has duplicate' do
      let(:contacts) do
        result = super()
        result + [result[0]]
      end

      it 'send emails to unique contacts' do
        contacts.uniq.each do |contact|
          sender_stub = instance_double(described_class)
          expect(described_class).to receive(:new).with(contact).once.and_return(sender_stub)
          expect(sender_stub).to receive(:send_email).with(service_params).once
        end
        subject
      end
    end
  end
end
