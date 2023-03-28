# frozen_string_literal: true

RSpec.describe 'Index Payments', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    payments = FactoryBot.create_list(:payment, 2)
    visit payments_path
    payments.each do |payment|
      expect(page).to have_css('.resource_id_link', text: payment.id)
    end
  end

  describe 'account filter', js: true do
    let!(:account1) { FactoryBot.create(:account, :filled) }
    let!(:account2) { FactoryBot.create(:account, :filled) }

    subject do
      visit payments_path
      within_filters do
        fill_in_chosen 'Account', with: account1.display_name, exact: true, ajax: true
      end
      click_on 'Filter'
    end

    it 'should be filtered by account' do
      subject

      within_filters do
        expect(page).to have_field_chosen('Account', with: account1.display_name)
      end
      expect(page).to have_table_row(count: account1.payments.size)
    end
  end
end
