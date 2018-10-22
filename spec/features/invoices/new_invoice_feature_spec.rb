require 'spec_helper'

describe 'Create new Invoice', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @account = create(:account)
    @contractor = @account.contractor

    visit new_invoice_path
  end

  include_context :fill_form, 'new_billing_invoice' do
    let(:attributes) do
      {
        vendor_invoice: true,
        contractor_id: -> {
          chosen_pick('#billing_invoice_contractor_id+div', text: @contractor.name)
        },
        account_id: -> {
          chosen_pick('#billing_invoice_account_id+div', text: @account.name)
        },
        start_date: 1.day.ago.utc,
        end_date: 1.hour.ago.utc
      }
    end

    it 'creates new invoice succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Invoice was successfully created.')

      expect(Billing::Invoice.last).to have_attributes(
        vendor_invoice: attributes[:vendor_invoice],
        contractor_id: @contractor.id,
        account_id: @account.id,
        start_date: be_within(1.second).of(attributes[:start_date]),
        end_date: be_within(1.second).of(attributes[:end_date])
      )
    end
  end

end
