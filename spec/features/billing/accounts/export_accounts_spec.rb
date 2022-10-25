# frozen_string_literal: true

RSpec.describe 'Export Accounts', type: :feature do
  include_context :login_as_admin

  before { create(:account) }

  let!(:item) do
    create :account
  end

  before do
    visit accounts_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id',                      item.id.to_s],
        ['Name',                    item.name],
        ['Contractor name',         item.contractor.name],
        ['Balance',                 item.balance.to_s],
        ['Vat',                     item.vat.to_s],
        ['Min balance',             item.min_balance.to_s],
        ['Max balance',             item.max_balance.to_s],
        ['Destination rate limit',  item.destination_rate_limit.to_s],
        ['Max call duration',       item.max_call_duration.to_s],
        ['Origination capacity',    item.origination_capacity.to_s],
        ['Termination capacity',    item.termination_capacity.to_s],
        ['Total capacity',          item.total_capacity.to_s],
        ['Customer invoice period', item.customer_invoice_template.to_s],
        ['Vendor invoice period',   item.vendor_invoice_period.to_s]
      ]
    )
  end
end
