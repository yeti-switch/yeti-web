# frozen_string_literal: true

RSpec.describe BalanceNotificationMail do
  let(:event) { System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED }
  let(:account) do
    FactoryBot.create(:account, balance: 12.5, balance_low_threshold: 100, balance_high_threshold: 5000)
  end

  describe '#subject' do
    subject { described_class.new(account, event).subject }

    it 'renders a human readable subject from the template' do
      expect(subject).to eq("Low balance warning: #{account.name} (12.50 #{account.currency_name})")
    end
  end

  describe '#body' do
    subject { described_class.new(account, event).body }

    it 'renders the balance and the crossed threshold' do
      expect(subject).to include('12.50')
      expect(subject).to include('100.00')
      expect(subject).to include(account.name)
    end

    # Regression: the body used to be account.attributes.to_json, which shipped
    # every column of billing.accounts to every contact.
    it 'does not leak account columns' do
      leakable = account.attributes.keys - %w[id name balance]
      expect(leakable).not_to be_empty
      leakable.each { |column| expect(subject).not_to include(column) }
    end

    it 'does not leak the other notification recipients' do
      contact = FactoryBot.create(:contact, contractor: account.contractor)
      account.balance_notification_setting.update!(send_to: [contact.id])

      expect(subject).not_to include(contact.email)
    end

    context 'when the threshold is not set' do
      let(:account) { FactoryBot.create(:account, balance: 12.5, balance_low_threshold: nil) }

      it 'omits the threshold row rather than rendering a bare currency' do
        expect(subject).not_to include('>Low threshold<')
      end
    end

    it 'renders the stored template, not a packaged default' do
      Billing::NotificationTemplate.find_by!(event: event).update!(body: 'CUSTOM {{ account.name }}')

      expect(subject).to eq("CUSTOM #{account.name}")
    end
  end

  describe '#template' do
    subject { described_class.new(account, event).template }

    it 'is the seeded row for the event' do
      expect(subject.event).to eq(event)
    end

    context 'when the seeded row is missing' do
      before { Billing::NotificationTemplate.where(event: event).delete_all }

      it 'raises rather than falling back, because the row is part of the install' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'liquid sandbox' do
    subject do
      Liquid::Template
        .parse(source, error_mode: :strict)
        .render!(described_class.sample_assigns.deep_stringify_keys)
    end

    context 'with a ruby method call' do
      let(:source) { '[{{ account.class }}][{{ account.id.object_id }}]' }

      it 'resolves nothing, because assigns are plain data' do
        expect(subject).to eq('[][]')
      end
    end

    context 'with embedded ERB' do
      let(:source) { '<%= 1 + 1 %>' }

      it 'passes it through inert instead of evaluating it' do
        expect(subject).to eq('<%= 1 + 1 %>')
      end
    end
  end

  describe '.new' do
    it 'rejects events it has no template for' do
      expect { described_class.new(account, 'GatewayLocked') }.to raise_error(ArgumentError, /invalid event/)
    end
  end
end
