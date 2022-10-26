# frozen_string_literal: true

RSpec.describe AccountBalanceThreshold do
  describe '.accounts_required_notification' do
    subject do
      described_class.accounts_required_notification
    end

    let!(:accounts_clear_low) do
      [
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD,
          balance: 100.22,
          balance_low_threshold: 100.21,
          balance_high_threshold: nil
        ),
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD,
          balance: 15,
          balance_low_threshold: 10,
          balance_high_threshold: 50
        )
      ]
    end
    let!(:accounts_clear_high) do
      [
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD,
          balance: 100.21,
          balance_low_threshold: nil,
          balance_high_threshold: 100.22
        ),
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD,
          balance: 5,
          balance_low_threshold: 1,
          balance_high_threshold: 10
        )
      ]
    end
    let!(:accounts_fire_low) do
      [
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
          balance: 100.21,
          balance_low_threshold: 100.22,
          balance_high_threshold: nil
        ),
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
          balance: 10,
          balance_low_threshold: 15,
          balance_high_threshold: 50
        )
      ]
    end
    let!(:accounts_fire_high) do
      [
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
          balance: 100.22,
          balance_low_threshold: nil,
          balance_high_threshold: 100.21
        ),
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
          balance: 55,
          balance_low_threshold: 10,
          balance_high_threshold: 50
        )
      ]
    end
    let!(:accounts_clear_low_fire_high) do
      [
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD,
          balance: 100.22,
          balance_low_threshold: nil,
          balance_high_threshold: 100.21
        ),
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD,
          balance: 55,
          balance_low_threshold: 10,
          balance_high_threshold: 50
        )
      ]
    end
    let!(:accounts_clear_high_fire_low) do
      [
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD,
          balance: 100.21,
          balance_low_threshold: 100.22,
          balance_high_threshold: nil
        ),
        FactoryBot.create(
          :account,
          threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD,
          balance: 10,
          balance_low_threshold: 15,
          balance_high_threshold: 50
        )
      ]
    end

    before do
      # threshold not reached and state=None
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
        balance: 20,
        balance_low_threshold: nil,
        balance_high_threshold: nil
      )
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
        balance: 100.22,
        balance_low_threshold: 100.21,
        balance_high_threshold: nil
      )
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
        balance: 15,
        balance_low_threshold: 10,
        balance_high_threshold: 50
      )

      # low threshold reached and state=low_threshold_reached
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD,
        balance: 100.21,
        balance_low_threshold: 100.22,
        balance_high_threshold: nil
      )
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD,
        balance: 10,
        balance_low_threshold: 15,
        balance_high_threshold: 50
      )

      # high threshold reached and state=high_threshold_reached
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD,
        balance: 100.22,
        balance_low_threshold: nil,
        balance_high_threshold: 100.21
      )
      FactoryBot.create(
        :account,
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD,
        balance: 55,
        balance_low_threshold: 10,
        balance_high_threshold: 50
      )
    end

    it 'returns correct accounts' do
      expect(subject.to_a).to match_array(
                                [
                                  accounts_clear_low,
                                  accounts_clear_high,
                                  accounts_fire_low,
                                  accounts_fire_high,
                                  accounts_clear_low_fire_high,
                                  accounts_clear_high_fire_low
                                ].flatten
                              )
    end
  end

  describe '#check_threshold' do
    subject do
      described_class.new(account).check_threshold
    end

    shared_examples :does_not_change_balance_notification_setting_state do
      it 'does not change balance_notification_setting state' do
        expect { subject }.not_to change { balance_notification_setting.reload.state_id }
      end
    end

    shared_examples :changes_balance_notification_setting_state do |state_id|
      state = AccountBalanceNotificationSetting::CONST::STATES.fetch(state_id)

      it "changes balance_notification_setting state to #{state}" do
        expect { subject }.to change { balance_notification_setting.reload.state_id }.to(state_id)
      end
    end

    shared_examples :does_not_send_notification_event do
      account_events = %i[low_threshold_reached high_threshold_reached low_threshold_cleared high_threshold_cleared]
      it 'does not send notification event' do
        account_events.each do |event|
          expect(NotificationEvent).not_to receive(event)
        end
        subject
      end
    end

    shared_examples :sends_notification_events do |*events|
      account_events = %i[low_threshold_reached high_threshold_reached low_threshold_cleared high_threshold_cleared]
      raise ArgumentError, 'events are empty' if events.empty?
      raise ArgumentError, 'events are invalid' unless (events - account_events).empty?

      it 'does not send notification event' do
        events.each do |event|
          expect(NotificationEvent).to receive(event).once.with(account)
        end
        (account_events - events).each do |event|
          expect(NotificationEvent).not_to receive(event)
        end
        subject
      end
    end

    let!(:account) do
      FactoryBot.create(:account, account_attrs)
    end
    let(:balance_notification_setting) { account.balance_notification_setting }
    let(:account_attrs) do
      {
        threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE,
        balance: 20,
        balance_low_threshold: nil,
        balance_high_threshold: nil
      }
    end

    context 'when low_threshold=nil and high_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: nil,
          balance_high_threshold: nil
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when low_threshold < balance < high_threshold' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 49.99,
          balance_high_threshold: 50.01
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance = low_threshold and high_threshold filled' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 50,
          balance_high_threshold: 51
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance = high_threshold and low_threshold filled' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 49,
          balance_high_threshold: 50
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance > low_threshold and high_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 49,
          balance_high_threshold: nil
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance = low_threshold and high_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 50,
          balance_high_threshold: nil
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance < high_threshold and low_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: nil,
          balance_high_threshold: 51
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance = high_threshold and low_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: nil,
          balance_high_threshold: 50
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
      end
    end

    context 'when balance < low_threshold and high_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 51,
          balance_high_threshold: nil
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :sends_notification_events, :low_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared, :low_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
      end
    end

    context 'when balance < low_threshold and high_threshold filled' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 51,
          balance_high_threshold: 100
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :sends_notification_events, :low_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :sends_notification_events, :high_threshold_cleared, :low_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
      end
    end

    context 'when balance > high_threshold and low_threshold=nil' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: nil,
          balance_high_threshold: 49
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :sends_notification_events, :high_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared, :high_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end
    end

    context 'when balance > high_threshold and low_threshold filled' do
      let(:account_attrs) do
        {
          balance: 50,
          balance_low_threshold: 10,
          balance_high_threshold: 49
        }
      end

      context 'when state=none' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
        end

        include_examples :sends_notification_events, :high_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
      end

      context 'when state=low_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
        end

        include_examples :sends_notification_events, :low_threshold_cleared, :high_threshold_reached
        include_examples :changes_balance_notification_setting_state, AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
      end

      context 'when state=high_threshold' do
        let(:account_attrs) do
          super().merge threshold_state_id: AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
        end

        include_examples :does_not_send_notification_event
        include_examples :does_not_change_balance_notification_setting_state
      end
    end
  end
end
