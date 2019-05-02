# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Area Prefix', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::AreaPrefix, 'new'
  include_context :login_as_admin

  let!(:area) { FactoryGirl.create(:area) }
  before do
    FactoryGirl.create(:area)
    visit new_routing_area_prefix_path

    aa_form.select_value 'Area', area.name
  end

  it 'creates record' do
    subject
    record = Routing::AreaPrefix.last
    expect(record).to be_present
    expect(record).to have_attributes(area_id: area.id)
  end

  include_examples :changes_records_qty_of, Routing::AreaPrefix, by: 1
  include_examples :shows_flash_message, :notice, 'Area prefix was successfully created.'
end
