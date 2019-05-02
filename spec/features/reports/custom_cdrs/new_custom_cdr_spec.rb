# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Custom Cdr', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::CustomCdr, 'new'
  include_context :login_as_admin

  before do
    visit new_custom_cdr_path

    aa_form.select_chosen 'Group by', 'customer_id'
    aa_form.select_chosen 'Group by', 'rateplan_id'
    aa_form.set_date_time 'Date start', '2019-01-01 00:00'
    aa_form.set_date_time 'Date end', '2019-02-01 01:00'
  end

  it 'creates record' do
    subject
    record = Report::CustomCdr.last
    expect(record).to be_present
    expect(record).to have_attributes(
      date_start: Time.parse('2019-01-01 00:00:00 UTC'),
      date_end: Time.parse('2019-02-01 01:00:00 UTC'),
      group_by: 'customer_id,rateplan_id',
      filter: '',
      customer_id: nil
    )
  end

  include_examples :changes_records_qty_of, Report::CustomCdr, by: 1
  include_examples :shows_flash_message, :notice, 'Custom cdr was successfully created.'
end
