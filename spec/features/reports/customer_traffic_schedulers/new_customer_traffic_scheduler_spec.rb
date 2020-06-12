# frozen_string_literal: true

RSpec.describe 'Create new Customer Traffic Scheduler', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::CustomerTrafficScheduler, 'new'
  include_context :login_as_admin

  let!(:customer) { FactoryBot.create(:customer, name: 'John Doe') }
  before do
    FactoryBot.create(:customer)
    FactoryBot.create(:vendor)
    visit new_customer_traffic_scheduler_path

    aa_form.select_value 'Period', 'Hourly'
    aa_form.select_chosen 'Customer', customer.name
  end

  it 'creates record' do
    subject
    record = Report::CustomerTrafficScheduler.last
    expect(record).to be_present
    expect(record).to have_attributes(
      customer_id: customer.id,
      period_id: Report::SchedulerPeriod.find_by!(name: 'Hourly').id,
      send_to: []
    )
  end

  include_examples :changes_records_qty_of, Report::CustomerTrafficScheduler, by: 1
  include_examples :shows_flash_message, :notice, 'Customer traffic scheduler was successfully created.'
end
