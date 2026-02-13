# frozen_string_literal: true

RSpec.describe 'Create new Custom Cdr Scheduler', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Report::CustomCdrScheduler, 'new'
  include_context :login_as_admin

  before do
    visit new_custom_cdr_scheduler_path

    aa_form.select_value 'Period', 'Hourly'
    aa_form.fill_in_tom_select 'Group by', with: 'customer_id'
    aa_form.fill_in_tom_select 'Group by', with: 'rateplan_id'
  end

  it 'creates record' do
    subject
    record = Report::CustomCdrScheduler.last
    expect(record).to be_present
    expect(record).to have_attributes(
      period_id: Report::SchedulerPeriod.find_by!(name: 'Hourly').id,
      group_by: %w[customer_id rateplan_id],
      filter: '',
      send_to: [],
      customer_id: nil
    )
  end

  include_examples :changes_records_qty_of, Report::CustomCdrScheduler, by: 1
  include_examples :shows_flash_message, :notice, 'Custom cdr scheduler was successfully created.'
end
