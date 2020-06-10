# frozen_string_literal: true

RSpec.describe 'Create new Rateplan Duplicator', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::RateplanDuplicator, 'new'
  include_context :login_as_admin

  let!(:rateplan) { FactoryBot.create(:rateplan) }
  before do
    visit new_routing_rateplan_duplicator_path(from: rateplan.id)

    aa_form.set_text 'Name', "#{rateplan.name} dup"
  end

  it 'creates record' do
    subject
    record = Rateplan.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: "#{rateplan.name} dup",
      profit_control_mode_id: rateplan.profit_control_mode_id,
      send_quality_alarms_to: []
    )
  end

  include_examples :changes_records_qty_of, Rateplan, by: 1
  include_examples :shows_flash_message, :notice, 'Rateplan duplicator was successfully created.'
end
