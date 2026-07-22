# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.notification_templates
# Database name: primary
#
#  id      :integer(4)       not null, primary key
#  body    :text             not null
#  event   :string           not null
#  subject :string           not null
#
# Indexes
#
#  notification_templates_event_key  (event) UNIQUE
#
RSpec.describe Billing::NotificationTemplate do
  let(:event) { System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED }
  let(:template) { described_class.find_by!(event: event) }

  describe 'seeded rows' do
    it 'exists for every balance event' do
      expect(described_class.pluck(:event)).to match_array(described_class::CONST::EVENTS)
    end
  end

  describe '#destroy' do
    it 'is refused, because a row must exist for every event' do
      expect(template.destroy).to be false
      expect(described_class.exists?(template.id)).to be true
    end
  end

  describe 'validation' do
    it 'rejects invalid liquid syntax' do
      template.body = '{% if %}broken'
      expect(template).not_to be_valid
      expect(template.errors[:body].first).to match(/liquid syntax error/)
    end

    it 'rejects references to variables that will never be supplied' do
      template.body = '{{ account.secret_column }}'
      expect(template).not_to be_valid
      expect(template.errors[:body].first).to match(/unknown variable/)
    end

    it 'validates the subject too' do
      template.subject = '{{ account.nope }}'
      expect(template).not_to be_valid
      expect(template.errors[:subject].first).to match(/unknown variable/)
    end

    it 'accepts a template using only the documented contract' do
      template.body = '{{ account.name }} {{ account.balance }} {% if threshold.low %}{{ threshold.low }}{% endif %}'
      expect(template).to be_valid
    end
  end

  describe 'seeded content' do
    it 'ships a usable body, since there is no packaged fallback' do
      described_class.find_each do |t|
        expect(t.body).to be_present
        expect(t.subject).to be_present
        expect(t).to be_valid
      end
    end
  end
end
