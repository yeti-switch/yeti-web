# frozen_string_literal: true

RSpec.describe 'Create new Sensor', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for System::Sensor, 'new'
  include_context :login_as_admin

  let(:sensor_mode) { System::SensorMode.find(System::SensorMode::IP_IP) }
  before do
    visit new_system_sensor_path

    aa_form.set_text 'Name', 'test'
    aa_form.select_value 'Mode', sensor_mode.name
    # expect(aa_form.form_node).to have_selector('label', text: 'Source ip', visible: true)
    aa_form.set_text 'Target ip', '192.18.100.7', exact_field: true
    aa_form.set_text 'Source ip', '192.18.100.6'
  end

  it 'creates record' do
    subject
    record = System::Sensor.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      mode_id: sensor_mode.id,
      source_ip: '192.18.100.6',
      target_ip: '192.18.100.7'
    )
  end

  include_examples :changes_records_qty_of, System::Sensor, by: 1
  include_examples :shows_flash_message, :notice, 'Sensor was successfully created.'
end
