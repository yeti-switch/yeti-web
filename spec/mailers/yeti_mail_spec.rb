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
      ContactEmailSender.new(contact).send_email(**send_params)
    end
    let(:send_params) do
      { subject: 'test', message: '<h1>Hello</h1>', attachments: [attachment] }
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

    context 'without a plain-text alternative' do
      let(:send_params) { { subject: 'test', message: '<h1>Hello</h1>' } }

      # Balance notifications and report emails supply no text part, so this is
      # the shape they must keep producing.
      it 'stays a single-part HTML message' do
        expect(subject).not_to be_multipart
        expect(subject.content_type).to start_with('text/html')
      end
    end

    context 'with a plain-text alternative' do
      let(:send_params) do
        { subject: 'test', message: '<h1>Hello</h1>', text_message: 'Hello' }
      end

      it 'sends multipart/alternative with the plain part first' do
        expect(subject).to be_multipart
        expect(subject.content_type).to start_with('multipart/alternative')
        # Clients render the LAST part they understand, so text before html is
        # what makes an HTML-capable client show the HTML.
        expect(subject.parts.map { |p| p.content_type.split(';').first })
          .to eq(['text/plain', 'text/html'])
      end

      it 'carries both bodies' do
        expect(subject.text_part.body.to_s).to include('Hello')
        expect(subject.html_part.body.to_s).to include('<h1>Hello</h1>')
      end
    end

    context 'with a plain-text alternative but no HTML body' do
      let(:send_params) do
        { subject: 'test', message: nil, text_message: 'Hello' }
      end

      # Reachable when a template renders one body and fails the other: a blank
      # html part would be the LAST part a client understands, so it would win
      # and the recipient would see an empty email.
      it 'sends a single-part plain-text message rather than an empty HTML one' do
        expect(subject).not_to be_multipart
        expect(subject.content_type).to start_with('text/plain')
        expect(subject.body.to_s).to include('Hello')
      end
    end

    context 'with neither body' do
      let(:send_params) { { subject: 'test', attachments: [attachment] } }

      it 'still sends, because the message is really its attachments' do
        expect(subject.attachments.map(&:filename)).to eq(['test.txt'])
      end
    end

    context 'with a plain-text alternative and attachments' do
      let(:send_params) do
        { subject: 'test', message: '<h1>Hello</h1>', text_message: 'Hello', attachments: [attachment] }
      end

      it 'nests the alternative inside multipart/mixed alongside the attachment' do
        expect(subject.content_type).to start_with('multipart/mixed')
        expect(subject.attachments.map(&:filename)).to eq(['test.txt'])

        alternative = subject.parts.find { |p| p.content_type.start_with?('multipart/alternative') }
        expect(alternative).to be_present
        expect(alternative.parts.map { |p| p.content_type.split(';').first })
          .to eq(['text/plain', 'text/html'])
      end
    end
  end
end
