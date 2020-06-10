# frozen_string_literal: true

RSpec.describe 'Export Contractors', type: :feature do
  include_context :login_as_admin

  before { create(:customer) }

  let!(:item) do
    create :vendor,
           smtp_connection: create(:smtp_connection)
  end

  before do
    visit contractors_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id',                   item.id.to_s],
        ['Name',                 item.name],
        ['Enabled',              item.enabled.to_s],
        ['Vendor',               item.vendor.to_s],
        ['Customer',             item.customer.to_s],
        ['Smtp connection name', item.smtp_connection.name]
      ]
    )
  end
end
