# frozen_string_literal: true

RSpec.describe 'Index package counters', type: :feature, js: true do
  subject do
    visit package_counters_path
    filter_records!
  end

  include_context :login_as_admin
  let(:filter_records!) { nil }
  let!(:counters) do
    [
      create(:billing_package_counter),
      create(:billing_package_counter, exclude: true),
      create(:billing_package_counter, exclude: false)
    ]
  end

  it 'displays correct table' do
    subject
    expect(page).to have_table_row(count: counters.count)
    counters.each do |c|
      within_table_row(id: c.id) do
        expect(page).to have_table_cell(column: 'ID', exact_text: c.id.to_s)
        expect(page).to have_table_cell(column: 'Account', exact_text: c.account.display_name)
        expect(page).to have_table_cell(column: 'Service', exact_text: c.service.display_name)
        expect(page).to have_table_cell(column: 'Prefix', exact_text: c.prefix)
        expect(page).to have_table_cell(column: 'Duration', exact_text: c.duration.to_s)
      end
    end
  end

  context 'with filter by Account' do
    let!(:account) { FactoryBot.create(:account) }
    let!(:filtered_counters) { create_list(:billing_package_counter, 2, account:) }
    let(:filter_records!) do
      within_filters do
        fill_in_chosen 'Account', with: account.display_name, exact: true, ajax: true
      end
      click_on 'Filter'
    end

    before do
      another_account = FactoryBot.create(:account, :filled)
      create(:billing_package_counter, account: another_account)
    end

    it 'displays filtered records' do
      subject

      expect(page).to have_table_row(count: filtered_counters.size)
      filtered_counters.each do |c|
        within_table_row(id: c.id) do
          expect(page).to have_table_cell(column: 'ID', exact_text: c.id.to_s)
          expect(page).to have_table_cell(column: 'Account', exact_text: account.display_name)
        end
      end

      within_filters do
        expect(page).to have_field_chosen('Account', with: account.display_name)
      end
    end
  end
end
