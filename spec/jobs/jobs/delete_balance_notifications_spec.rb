# frozen_string_literal: true

RSpec.describe Jobs::DeleteBalanceNotifications, '#call', freeze_time: true do
  subject { job.call }

  let(:job) { described_class.new(double) }
  let(:keep_balance_notifications_days) { 5 }
  let(:old_time) { keep_balance_notifications_days.days.ago.round }
  let!(:old_balance_notifications) do
    [
      FactoryBot.create(:balance_notification, :with_account, created_at: old_time),
      FactoryBot.create(:balance_notification, :with_account, created_at: old_time - 1.second),
      FactoryBot.create(:balance_notification, :with_account, created_at: old_time - 1.year)
    ]
  end

  before do
    allow(YetiConfig).to receive(:keep_balance_notifications_days).and_return(keep_balance_notifications_days)

    # fresh balance notifications
    FactoryBot.create_list(:balance_notification, 2, :with_account, created_at: old_time + 1.second)
  end

  it 'deletes old balance notifications' do
    expect { subject }.to change { Log::BalanceNotification.count }.by(-old_balance_notifications.size)

    old_balance_notifications.each do |balance_notification|
      expect(Log::BalanceNotification).not_to be_exists(balance_notification.id)
    end
  end

  context 'when keep_balance_notifications_days is nil' do
    let(:keep_balance_notifications_days) { nil }
    let(:old_time) { 5.years.ago }

    it 'does not delete balance notifications' do
      expect { subject }.not_to change { Log::BalanceNotification.count }
    end
  end

  context 'when keep_balance_notifications_days is empty' do
    let(:keep_balance_notifications_days) { '' }
    let(:old_time) { 5.years.ago }

    it 'does not delete balance notifications' do
      expect { subject }.not_to change { Log::BalanceNotification.count }
    end
  end
end
