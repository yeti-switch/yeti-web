# frozen_string_literal: true

RSpec.describe 'Index Log Balance Notifications' do
  subject do
    visit log_balance_notifications_path
  end

  include_context :login_as_admin

  let!(:balance_notifications) do
    create_list(:balance_notification, 5, :with_account)
  end

  before do
    balance_notifications.last.account.destroy!
    balance_notifications.last.reload
  end

  it 'shows correct rows' do
    subject
    expect(page).to have_table_row(count: balance_notifications.size)
    balance_notifications.each do |log_balance_notification|
      expect(page).to have_table_cell(column: 'ID', exact_text: log_balance_notification.id.to_s)
    end
  end
end
