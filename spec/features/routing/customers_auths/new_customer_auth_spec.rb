# frozen_string_literal: true

RSpec.describe 'New Customer Auth', js: true do
  subject do
    visit new_customers_auth_path
    fill_form!
    submit_form!
  end

  include_context :login_as_admin
  let!(:customer) { create(:customer) }
  let!(:account) { create(:account, contractor: customer) }
  let!(:gateway) { create(:gateway, contractor: customer) }
  let!(:rateplan) { create(:rateplan) }
  let!(:routing_plan) { create(:routing_plan) }

  let(:fill_form!) do
    fill_in 'Name', with: 'Test'
    fill_in_chosen 'Customer', with: customer.name, ajax: true
    fill_in_chosen 'Account', with: account.name, ajax: true
    fill_in_chosen 'Gateway', with: gateway.name, ajax: true
    fill_in_chosen 'Rateplan', with: rateplan.name
    fill_in_chosen 'Routing plan', with: routing_plan.name
  end
  let(:submit_form!) do
    click_submit('Create Customers auth')
  end

  it 'creates customer auth successfully' do
    subject
    expect(page).to have_flash_message('Customers auth was successfully created.', type: :notice)

    customer_auth = CustomersAuth.last!
    expect(page).to have_current_path customers_auth_path(customer_auth.id)

    expect(customer_auth).to have_attributes(
                               name: 'Test',
                               customer: customer,
                               account: account,
                               gateway: gateway,
                               rateplan: rateplan,
                               routing_plan: routing_plan
                             )
  end
end
