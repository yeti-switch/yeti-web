# frozen_string_literal: true

RSpec.describe NotificationEvent do
  shared_examples :sends_account_threshold_event_emails do
    include_examples :sends_email_to_contacts

    context 'when event_subscription has send_to=nil' do
      let(:expected_contacts) { contacts }

      before do
        event_subscription.update! send_to: nil
      end

      include_examples :sends_email_to_contacts
    end

    context 'when event_subscription has send_to empty' do
      let(:expected_contacts) { contacts }

      before do
        event_subscription.update! send_to: []
      end

      include_examples :sends_email_to_contacts
    end

    context 'when account has balance_notification_setting.send_to=nil' do
      let(:account_attrs) do
        super().merge send_balance_notifications_to: nil
      end
      let(:expected_contacts) { subscription_contacts }

      include_examples :sends_email_to_contacts
    end

    context 'when account has balance_notification_setting.send_to empty' do
      let(:account_attrs) do
        super().merge send_balance_notifications_to: []
      end
      let(:expected_contacts) { subscription_contacts }

      include_examples :sends_email_to_contacts
    end

    context 'when both event_subscription and account has no contacts' do
      let(:account_attrs) do
        super().merge send_balance_notifications_to: []
      end

      before do
        event_subscription.update! send_to: []
      end

      include_examples :does_not_send_email
    end
  end

  shared_examples :send_destination_quality_alarm_emails do
    include_examples :sends_email_to_contacts

    context 'when event_subscription has send_to=nil' do
      let(:expected_contacts) { contacts }

      before do
        event_subscription.update! send_to: nil
      end

      include_examples :sends_email_to_contacts
    end

    context 'when event_subscription has send_to empty' do
      let(:expected_contacts) { contacts }

      before do
        event_subscription.update! send_to: []
      end

      include_examples :sends_email_to_contacts
    end

    context 'when rateplan has send_quality_alarms_to=nil' do
      let(:rateplan_attrs) do
        super().merge send_quality_alarms_to: nil
      end
      let(:expected_contacts) { subscription_contacts }

      include_examples :sends_email_to_contacts
    end

    context 'when rateplan has send_quality_alarms_to empty' do
      let(:rateplan_attrs) do
        super().merge send_quality_alarms_to: []
      end
      let(:expected_contacts) { subscription_contacts }

      include_examples :sends_email_to_contacts
    end

    context 'when both event_subscription and rateplan has no contacts' do
      let(:rateplan_attrs) do
        super().merge send_quality_alarms_to: []
      end

      before do
        event_subscription.update! send_to: []
      end

      include_examples :does_not_send_email
    end
  end

  shared_examples :send_events_to_event_subscription_contacts do
    include_examples :sends_email_to_contacts

    context 'when event_subscription has send_to=nil' do
      before do
        event_subscription.update! send_to: nil
      end

      include_examples :does_not_send_email
    end

    context 'when event_subscription has send_to empty' do
      before do
        event_subscription.update! send_to: []
      end

      include_examples :does_not_send_email
    end
  end

  describe '.low_threshold_reached' do
    subject do
      described_class.low_threshold_reached(account)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)

      another_contractor = FactoryBot.create(:customer)
      another_contact = FactoryBot.create(:contact, contractor: another_contractor)
      FactoryBot.create(:account, contractor: another_contractor, send_balance_notifications_to: [another_contact.id])
    end

    let!(:contractor) do
      FactoryBot.create(:customer)
    end
    let!(:contacts) do
      FactoryBot.create_list(:contact, 3, contractor: contractor)
    end
    let(:account) do
      FactoryBot.create(:account, account_attrs)
    end
    let(:account_attrs) do
      { send_balance_notifications_to: contacts.map(&:id) }
    end
    let(:expected_contacts) { subscription_contacts + contacts }
    let(:expected_subject) { "Account with id #{account.id} low balance" }
    let(:expected_message) do
      data = account.attributes.merge(
        balance_low_threshold: account.balance_notification_setting.low_threshold,
        balance_high_threshold: account.balance_notification_setting.high_threshold,
        send_balance_notifications_to: account.balance_notification_setting.send_to
      )
      data.to_json
    end

    include_examples :sends_account_threshold_event_emails
  end

  describe '.high_threshold_reached' do
    subject do
      described_class.high_threshold_reached(account)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)

      another_contractor = FactoryBot.create(:customer)
      another_contact = FactoryBot.create(:contact, contractor: another_contractor)
      FactoryBot.create(:account, contractor: another_contractor, send_balance_notifications_to: [another_contact.id])
    end

    let!(:contractor) do
      FactoryBot.create(:customer)
    end
    let!(:contacts) do
      FactoryBot.create_list(:contact, 3, contractor: contractor)
    end
    let(:account) do
      FactoryBot.create(:account, account_attrs)
    end
    let(:account_attrs) do
      { send_balance_notifications_to: contacts.map(&:id) }
    end
    let(:expected_contacts) { subscription_contacts + contacts }
    let(:expected_subject) { "Account with id #{account.id} high balance" }
    let(:expected_message) do
      data = account.attributes.merge(
        balance_low_threshold: account.balance_notification_setting.low_threshold,
        balance_high_threshold: account.balance_notification_setting.high_threshold,
        send_balance_notifications_to: account.balance_notification_setting.send_to
      )
      data.to_json
    end

    include_examples :sends_account_threshold_event_emails
  end

  describe '.low_threshold_cleared' do
    subject do
      described_class.low_threshold_cleared(account)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)

      another_contractor = FactoryBot.create(:customer)
      another_contact = FactoryBot.create(:contact, contractor: another_contractor)
      FactoryBot.create(:account, contractor: another_contractor, send_balance_notifications_to: [another_contact.id])
    end

    let!(:contractor) do
      FactoryBot.create(:customer)
    end
    let!(:contacts) do
      FactoryBot.create_list(:contact, 3, contractor: contractor)
    end
    let(:account) do
      FactoryBot.create(:account, account_attrs)
    end
    let(:account_attrs) do
      { send_balance_notifications_to: contacts.map(&:id) }
    end
    let(:expected_contacts) { subscription_contacts + contacts }
    let(:expected_subject) { "Account with id #{account.id} low balance cleared" }
    let(:expected_message) do
      data = account.attributes.merge(
        balance_low_threshold: account.balance_notification_setting.low_threshold,
        balance_high_threshold: account.balance_notification_setting.high_threshold,
        send_balance_notifications_to: account.balance_notification_setting.send_to
      )
      data.to_json
    end

    include_examples :sends_account_threshold_event_emails
  end

  describe '.high_threshold_cleared' do
    subject do
      described_class.high_threshold_cleared(account)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)

      another_contractor = FactoryBot.create(:customer)
      another_contact = FactoryBot.create(:contact, contractor: another_contractor)
      FactoryBot.create(:account, contractor: another_contractor, send_balance_notifications_to: [another_contact.id])
    end

    let!(:contractor) do
      FactoryBot.create(:customer)
    end
    let!(:contacts) do
      FactoryBot.create_list(:contact, 3, contractor: contractor)
    end
    let(:account) do
      FactoryBot.create(:account, account_attrs)
    end
    let(:account_attrs) do
      { send_balance_notifications_to: contacts.map(&:id) }
    end
    let(:expected_contacts) { subscription_contacts + contacts }
    let(:expected_subject) { "Account with id #{account.id} high balance cleared" }
    let(:expected_message) do
      data = account.attributes.merge(
        balance_low_threshold: account.balance_notification_setting.low_threshold,
        balance_high_threshold: account.balance_notification_setting.high_threshold,
        send_balance_notifications_to: account.balance_notification_setting.send_to
      )
      data.to_json
    end

    include_examples :sends_account_threshold_event_emails
  end

  describe '.dialpeer_locked' do
    subject do
      described_class.dialpeer_locked(dialpeer, quality_stat)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_DIALPEER_LOCKED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)
    end

    let!(:dialpeer) do
      FactoryBot.create(:dialpeer, acd_limit: 0.7, asr_limit: 0.99)
    end
    let(:quality_stat) { double(acd: 0.69, asr: 0.1) } # see Stats::TerminationQualityStat.dp_measurement
    let(:expected_contacts) { subscription_contacts }
    let(:expected_subject) do
      "Dialpeer with id #{dialpeer.id} locked by quality"
    end
    let(:expected_message) do
      [
        "ACD Limit: #{dialpeer.acd_limit}, ACD actual value: #{quality_stat.acd}",
        "ASR Limit: #{dialpeer.asr_limit}, ASR actual value: #{quality_stat.asr}"
      ].join("\n")
    end

    before do
      FactoryBot.create(:contact)
    end

    include_examples :send_events_to_event_subscription_contacts
  end

  describe '.dialpeer_unlocked' do
    subject do
      described_class.dialpeer_unlocked(dialpeer)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_DIALPEER_UNLOCKED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)
    end

    let!(:dialpeer) do
      FactoryBot.create(:dialpeer)
    end
    let(:expected_contacts) { subscription_contacts }
    let(:expected_subject) do
      "Dialpeer with id #{dialpeer.id} unlocked"
    end
    let(:expected_message) do
      expected_subject
    end

    before do
      FactoryBot.create(:contact)
    end

    include_examples :send_events_to_event_subscription_contacts
  end

  describe '.gateway_locked' do
    subject do
      described_class.gateway_locked(gateway, quality_stat)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_GATEWAY_LOCKED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)
    end

    let!(:gateway) do
      FactoryBot.create(:gateway, acd_limit: 0.7, asr_limit: 0.99)
    end
    let(:quality_stat) { double(acd: 0.69, asr: 0.1) } # see Stats::TerminationQualityStat.gw_measurement
    let(:expected_contacts) { subscription_contacts }
    let(:expected_subject) do
      "Gateway with id #{gateway.id} locked by quality"
    end
    let(:expected_message) do
      [
        "ACD Limit: #{gateway.acd_limit}, ACD actual value: #{quality_stat.acd}",
        "ASR Limit: #{gateway.asr_limit}, ASR actual value: #{quality_stat.asr}"
      ].join("\n")
    end

    before do
      FactoryBot.create(:contact)
    end

    include_examples :send_events_to_event_subscription_contacts
  end

  describe '.gateway_unlocked' do
    subject do
      described_class.gateway_unlocked(gateway)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_GATEWAY_UNLOCKED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)
    end

    let!(:gateway) do
      FactoryBot.create(:gateway)
    end
    let(:expected_contacts) { subscription_contacts }
    let(:expected_subject) do
      "Gateway with id #{gateway.id} unlocked"
    end
    let(:expected_message) do
      expected_subject
    end

    before do
      FactoryBot.create(:contact)
    end

    include_examples :send_events_to_event_subscription_contacts
  end

  describe '.destination_quality_alarm_fired' do
    subject do
      described_class.destination_quality_alarm_fired(destination, quality_stat)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_DESTINATION_QUALITY_ALARM_FIRED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)
    end

    let!(:contacts) do
      FactoryBot.create_list(:contact, 3)
    end
    let!(:rate_group) do
      FactoryBot.create(:rate_group)
    end
    let!(:rateplan) do
      FactoryBot.create(:rateplan, rateplan_attrs)
    end
    let(:rateplan_attrs) do
      { rate_groups: [rate_group], send_quality_alarms_to: contacts.map(&:id) }
    end
    let!(:destination) do
      FactoryBot.create(:destination, rate_group: rate_group, acd_limit: 0.7, asr_limit: 0.99)
    end
    let(:quality_stat) { double(acd: 0.69, asr: 0.1) } # see Stats::TerminationQualityStat.dst_measurement
    let(:expected_contacts) { contacts + subscription_contacts }
    let(:expected_subject) do
      "Destination with id #{destination.id} Quality alarm fired"
    end
    let(:expected_message) do
      [
        "ACD Limit: #{destination.acd_limit}, ACD actual value: #{quality_stat.acd}",
        "ASR Limit: #{destination.asr_limit}, ASR actual value: #{quality_stat.asr}"
      ].join("\n")
    end

    before do
      another_contact = FactoryBot.create(:contact)
      another_rate_group = FactoryBot.create(:rate_group)
      FactoryBot.create(
        :rateplan,
        rate_groups: [another_rate_group],
        send_quality_alarms_to: [another_contact.id]
      )
      FactoryBot.create(:destination, rate_group: another_rate_group)
    end

    include_examples :send_destination_quality_alarm_emails
  end

  describe '.destination_quality_alarm_cleared' do
    subject do
      described_class.destination_quality_alarm_cleared(destination)
    end

    let(:event_subscription) do
      System::EventSubscription.find_by!(
        event: System::EventSubscription::CONST::EVENT_DESTINATION_QUALITY_ALARM_CLEARED
      )
    end
    let!(:subscription_contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      event_subscription.update! send_to: subscription_contacts.map(&:id)
    end

    let!(:contacts) do
      FactoryBot.create_list(:contact, 3)
    end
    let!(:rate_group) do
      FactoryBot.create(:rate_group)
    end
    let!(:rateplan) do
      FactoryBot.create(:rateplan, rateplan_attrs)
    end
    let(:rateplan_attrs) do
      { rate_groups: [rate_group], send_quality_alarms_to: contacts.map(&:id) }
    end
    let!(:destination) do
      FactoryBot.create(:destination, rate_group: rate_group)
    end
    let(:expected_contacts) { contacts + subscription_contacts }
    let(:expected_subject) do
      "Destination with id #{destination.id} Quality alarm cleared"
    end
    let(:expected_message) do
      expected_subject
    end

    before do
      another_contact = FactoryBot.create(:contact)
      another_rate_group = FactoryBot.create(:rate_group)
      FactoryBot.create(
        :rateplan,
        rate_groups: [another_rate_group],
        send_quality_alarms_to: [another_contact.id]
      )
      FactoryBot.create(:destination, rate_group: another_rate_group)
    end

    include_examples :send_destination_quality_alarm_emails
  end
end
