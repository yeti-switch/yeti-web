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
          fill_in_chosen('Account', with: @account.display_name, ajax: true)
        },
        amount: 100_500,
        notes: 'Some notes',
        private_notes: 'Some private notes'
      }
    end

    it 'creates new payment succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Payment was successfully created.')

      expect(Payment.last).to have_attributes(
        account_id: @account.id,
        amount: attributes[:amount],
        notes: attributes[:notes],
        private_notes: attributes[:private_notes]
      )
    end

    context 'with validation error' do
      let(:attributes) { super().except(:amount) }

      it 'account should be still' do
        click_on_submit

        expect(page).to have_semantic_errors(count: 1)
        expect(page).to have_semantic_error('Amount is not a number')
        expect(page).to have_field_chosen('Account', with: @account.display_name)
      end
    end
  end
end
