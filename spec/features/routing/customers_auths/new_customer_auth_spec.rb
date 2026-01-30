# frozen_string_literal: true

RSpec.describe 'New Customer Auth', js: true do
  subject do
    visit new_customers_auth_path
    fill_form!
    submit_form!
  end

  include_context :login_as_admin
  let!(:customer) { FactoryBot.create(:customer) }
  let!(:account) { FactoryBot.create(:account, contractor: customer) }
  let!(:gateway) { FactoryBot.create(:gateway, contractor: customer) }
  let!(:rateplan) { FactoryBot.create(:rateplan) }
  let!(:routing_plan) { FactoryBot.create(:routing_plan) }
  let!(:src_numberlist) { FactoryBot.create(:numberlist) }
  let!(:dst_numberlist) { FactoryBot.create(:numberlist) }

  let(:fill_form!) do
    fill_in 'Name', with: 'Test'
    fill_in_tom_select 'Customer', with: customer.name, ajax: true
    fill_in_tom_select 'Account', with: account.name, ajax: true
    fill_in_tom_select 'DST Numberlist', with: dst_numberlist.display_name, ajax: true
    fill_in_tom_select 'SRC Numberlist', with: src_numberlist.display_name, ajax: true
    fill_in_tom_select 'Gateway', with: gateway.name, ajax: true
    fill_in_tom_select 'Rateplan', with: rateplan.name
    fill_in_tom_select 'Routing plan', with: routing_plan.name
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
                               routing_plan: routing_plan,
                               src_numberlist:,
                               dst_numberlist:
                             )
  end
end
