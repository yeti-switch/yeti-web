require 'spec_helper'

describe 'Create new Account', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @customer = create(:customer)
    @tz = create(:timezone)
    visit new_account_path
  end

  include_context :fill_form, 'new_account' do
    let(:attributes) do
      {
          name: "Account",
          contractor_id: -> {
            chosen_pick('#account_contractor_id+div', text: @customer.name)
          },
          min_balance: -100,
          max_balance: 100,
          balance_low_threshold: -90,
          balance_high_threshold: 90,
          origination_capacity: 100,
          termination_capacity: 50,
          timezone_id: -> {
            chosen_pick('#account_timezone_id+div', text: @tz.name)
          }
      }
    end

    it 'creates new account succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Account was successfully created.')

      expect(Account.last).to have_attributes(
                                     name: attributes[:name],
                                     contractor_id: @customer.id,
                                     max_balance: attributes[:max_balance],
                                     min_balance: attributes[:min_balance],
                                     balance_low_threshold: attributes[:balance_low_threshold],
                                     balance_high_threshold: attributes[:balance_high_threshold],
                                     origination_capacity: attributes[:origination_capacity],
                                     termination_capacity: attributes[:termination_capacity],
                                     timezone_id: @tz.id
                                 )
    end
  end

end
