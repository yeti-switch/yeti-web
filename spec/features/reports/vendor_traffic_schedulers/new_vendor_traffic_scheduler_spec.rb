# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Vendor Traffic Scheduler', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::VendorTrafficScheduler, 'new'
  include_context :login_as_admin

  let!(:vendor) { FactoryBot.create(:vendor, name: 'John Doe') }
  before do
    FactoryBot.create(:customer)
    FactoryBot.create(:vendor)
    visit new_vendor_traffic_scheduler_path

    aa_form.select_value 'Period', 'Hourly'
    aa_form.select_chosen 'Vendor', vendor.name
  end

  it 'creates record' do
    subject
    record = Report::VendorTrafficScheduler.last
    expect(record).to be_present
    expect(record).to have_attributes(
      vendor_id: vendor.id,
      period_id: Report::SchedulerPeriod.find_by!(name: 'Hourly').id,
      send_to: []
    )
  end

  include_examples :changes_records_qty_of, Report::VendorTrafficScheduler, by: 1
  include_examples :shows_flash_message, :notice, 'Vendor traffic scheduler was successfully created.'
end
