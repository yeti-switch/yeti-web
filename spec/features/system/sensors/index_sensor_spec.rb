# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Sensors', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_sensors = create_list(:sensor, 2, :filled)
    visit system_sensors_path
    system_sensors.each do |system_sensor|
      expect(page).to have_css('.resource_id_link', text: system_sensor.id)
    end
  end
end
