# frozen_string_literal: true

RSpec.describe 'Create new Interval Cdr', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::IntervalCdr, 'new'
  include_context :login_as_admin

  before do
    visit new_report_interval_cdr_path

    aa_form.select_value 'Interval length', '10 Min'
    aa_form.select_value 'Aggregation function', 'Count'
    aa_form.select_chosen 'Aggregate by', 'destination_fee'
    aa_form.set_date_time 'Date start', '2019-01-01 00:00'
    aa_form.set_date_time 'Date end', '2019-02-01 01:00'
  end

  it 'creates record' do
    subject
    record = Report::IntervalCdr.last
    expect(record).to be_present
    expect(record).to have_attributes(
      date_start: Time.zone.parse('2019-01-01 00:00:00'),
      date_end: Time.zone.parse('2019-02-01 01:00:00'),
      aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
      aggregate_by: 'destination_fee',
      interval_length: 10,
      send_to: nil,
      group_by: '',
      filter: ''
    )
  end

  include_examples :changes_records_qty_of, Report::IntervalCdr, by: 1
  include_examples :shows_flash_message, :notice, 'Interval cdr was successfully created.'
end
