# frozen_string_literal: true

RSpec.describe 'Customer Auth Statistic', type: :feature, js: true do
  subject do
    visit customer_auth_statistics_path
  end

  include_context :login_as_admin

  let!(:customer_auth_stats) do
    [
      FactoryBot.create(:customer_auth_stats, customer_auth_id: 999),
      FactoryBot.create(:customer_auth_stats),
      FactoryBot.create(:customer_auth_stats)
    ]
  end

  it 'should render correctly' do
    subject

    expect(page).to have_table_row(count: customer_auth_stats.size)
    customer_auth_stats.each do |cas|
      within_table_row(id: cas.id) do
        expect(page).to have_table_cell(column: 'ID', exact_text: cas.id.to_s)
        expect(page).to have_table_cell(column: 'Timestamp', exact_text: cas.timestamp.to_fs(:db))
        expect(page).to have_table_cell(column: 'Calls Count', exact_text: cas.calls_count.to_s)
        expect(page).to have_table_cell(column: 'Customer Duration', exact_text: cas.customer_duration.to_s)
        expect(page).to have_table_cell(column: 'Customer Price', exact_text: cas.customer_price.to_s)
        expect(page).to have_table_cell(column: 'Customer Price No Vat', exact_text: cas.customer_price_no_vat.to_s)
        expect(page).to have_table_cell(column: 'Duration', exact_text: cas.duration.to_s)
        expect(page).to have_table_cell(column: 'Vendor Price', exact_text: cas.vendor_price.to_s)

        customer_auth = cas.customer_auth ? cas.customer_auth.display_name : cas.customer_auth_id.to_s
        expect(page).to have_table_cell(column: 'Customer Auth', exact_text: customer_auth)
      end
    end

    # check correct link to customers_auth page
    customer_auth_stat = customer_auth_stats.last
    within_table_row(id: customer_auth_stat.id) do
      expect(page).to have_link(customer_auth_stat.customer_auth.display_name,
                                href: customers_auth_path(customer_auth_stat.customer_auth))
    end
  end
end
