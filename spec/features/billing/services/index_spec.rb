# frozen_string_literal: true

RSpec.describe 'Billing Services Index', js: true, bullet: [:n] do
  subject do
    visit services_path
  end

  include_context :login_as_admin

  let!(:accounts) { create_list(:account, 4) }
  let!(:service_types) { create_list(:service_type, 4) }
  let!(:records) do
    [
      create(:service),
      create(:service, :renew_daily, account: accounts.first, type: service_types.first),
      create(:service, :renew_monthly, account: accounts.second, type: service_types.second, variables: nil)
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
