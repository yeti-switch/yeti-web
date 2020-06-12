# frozen_string_literal: true

RSpec.describe 'Create new Customer Traffic', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::CustomerTraffic, 'new'
  include_context :login_as_admin

  let!(:customer) { FactoryBot.create(:customer, name: 'John Doe') }
  before do
    FactoryBot.create(:customer)
    FactoryBot.create(:vendor)
    visit new_customer_traffic_path

    aa_form.select_chosen 'Customer', customer.name
    aa_form.set_date_time 'Date start', '2019-01-01 00:00'
    aa_form.set_date_time 'Date end', '2019-02-01 01:00'
  end

  it 'creates record' do
    subject
    record = Report::CustomerTraffic.last
    expect(record).to be_present
    expect(record).to have_attributes(
      date_start: Time.parse('2019-01-01 00:00:00 UTC'),
      date_end: Time.parse('2019-02-01 01:00:00 UTC'),
      customer_id: customer.id,
      send_to: nil
    )
  end

  include_examples :changes_records_qty_of, Report::CustomerTraffic, by: 1
  include_examples :shows_flash_message, :notice, 'Customer traffic was successfully created.'
end
