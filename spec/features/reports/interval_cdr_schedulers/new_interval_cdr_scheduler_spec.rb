# frozen_string_literal: true

RSpec.describe 'Create new Interval Cdr Scheduler', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::IntervalCdrScheduler, 'new'
  include_context :login_as_admin

  before do
    visit new_interval_cdr_scheduler_path

    aa_form.select_value 'Period', 'Hourly'
    aa_form.select_value 'Interval length', '10 Min'
    aa_form.select_value 'Aggregation function', 'Count'
    aa_form.select_chosen 'Aggregate by', 'destination_fee'
  end

  it 'creates record' do
    subject
    record = Report::IntervalCdrScheduler.last
    expect(record).to be_present
    expect(record).to have_attributes(
      aggregator_id: Report::IntervalAggregator.find_by!(name: 'Count').id,
      period_id: Report::SchedulerPeriod.find_by!(name: 'Hourly').id,
      aggregate_by: 'destination_fee',
      interval_length: 10,
      send_to: [],
      group_by: [],
      filter: ''
    )
  end

  include_examples :changes_records_qty_of, Report::IntervalCdrScheduler, by: 1
  include_examples :shows_flash_message, :notice, 'Interval cdr scheduler was successfully created.'
end
