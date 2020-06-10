# frozen_string_literal: true

RSpec.describe 'Create new Payment', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @account = create(:account)
    visit new_payment_path
  end

  include_context :fill_form, 'new_payment' do
    let(:attributes) do
      {
        account_id: lambda {
          chosen_pick('#payment_account_id+div', text: @account.name)
        },
        amount: 100_500,
        notes: 'Some notes'
      }
    end

    it 'creates new payment succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Payment was successfully created.')

      expect(Payment.last).to have_attributes(
        account_id: @account.id,
        amount: attributes[:amount],
        notes: attributes[:notes]
      )
    end
  end
end
