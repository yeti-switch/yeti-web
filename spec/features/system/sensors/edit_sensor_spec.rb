# frozen_string_literal: true

RSpec.describe 'Edit Sensor', js: true do
  subject do
    click_submit 'Update Sensor'
  end

  include_context :login_as_admin
  let!(:sensor) { create(:sensor) }

  context 'with HEPv3 mode' do
    before do
      visit edit_system_sensor_path id: sensor.id
      fill_in 'Name', with: new_name
      select 'HEPv3', from: 'Mode'
      fill_in 'Target ip', with: new_ip
      fill_in 'Target port', with: target_port
    end

    let(:new_ip) { '127.0.0.1' }
    let(:new_name) { 'Sensor edit test name' }
    let(:target_port) { 65_535 }

    it 'should be edit' do
      subject
      expect(page).to have_flash_message('Sensor was successfully updated.', type: :notice)

      expect(page).to have_current_path system_sensor_path(sensor)

      expect(sensor.reload).to have_attributes(
          mode_id: 3,
          target_ip: new_ip,
          name: new_name,
          target_port: target_port
        )
    end
  end
end
