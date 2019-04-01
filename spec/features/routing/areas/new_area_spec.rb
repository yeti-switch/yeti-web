# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Area', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::Area, 'new'
  include_context :login_as_admin

  before do
    visit new_routing_area_path

    aa_form.set_text 'Name', 'test'
  end

  it 'creates record' do
    subject
    record = Routing::Area.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test')
  end

  include_examples :changes_records_qty_of, Routing::Area, by: 1
  include_examples :shows_flash_message, :notice, 'Area was successfully created.'
end
