# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Vendor Traffic', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::VendorTraffic, 'new'
  include_context :login_as_admin

  let!(:vendor) { FactoryGirl.create(:vendor, name: 'John Doe') }
  before do
    FactoryGirl.create(:customer)
    FactoryGirl.create(:vendor)
    visit new_vendor_traffic_path

    aa_form.select_chosen 'Vendor', vendor.name
    aa_form.set_date_time 'Date start', '2019-01-01 00:00'
    aa_form.set_date_time 'Date end', '2019-02-01 01:00'
  end

  it 'creates record' do
    subject
    record = Report::VendorTraffic.last
    expect(record).to be_present
    expect(record).to have_attributes(
      date_start: Time.parse('2019-01-01 00:00:00 UTC'),
      date_end: Time.parse('2019-02-01 01:00:00 UTC'),
      vendor_id: vendor.id,
      send_to: nil
    )
  end

  include_examples :changes_records_qty_of, Report::VendorTraffic, by: 1
  include_examples :shows_flash_message, :notice, 'Vendor traffic was successfully created.'
end
