# frozen_string_literal: true

RSpec.describe 'Billing Transactions Index', js: true, bullet: [:n] do
  subject do
    visit transactions_path
  end

  include_context :login_as_admin

  let!(:records) do
    services = create_list(:service, 3)
    [
      *services.map(&:transactions).flatten, # 3 initial transactions
      create(:billing_transaction, service: services.first, description: 'test'),
      create(:billing_transaction, service: services.first)
    ]
  end

  it 'displays correct table' do
    subject
    expect(page).to have_table_row(count: records.count)
    records.each do |record|
      expect(page).to have_table_cell(column: 'ID', exact_text: record.id.to_s)
    end
  end
end
