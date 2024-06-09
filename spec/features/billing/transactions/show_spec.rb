# frozen_string_literal: true

RSpec.describe 'Billing Transactions Show', js: true, bullet: [:n] do
  subject do
    visit transaction_path(record.id)
  end

  include_context :login_as_admin

  let!(:account) { create(:account) }
  let!(:service) { create(:service, account:) }
  let!(:record) { create(:billing_transaction, record_attrs) }
  let(:record_attrs) { { account:, service: } }

  it 'displays correct attributes' do
    subject
    expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
    expect(page).to have_attribute_row('Account', exact_text: record.account.display_name)
    expect(page).to have_attribute_row('Service', exact_text: record.service.display_name)
    expect(page).to have_attribute_row('Amount', exact_text: record.amount.to_s)
  end
end
