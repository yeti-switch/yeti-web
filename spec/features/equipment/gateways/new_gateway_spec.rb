# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Gateway', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  include_context :login_as_admin
  active_admin_form_for Gateway, 'new'

  let!(:contractor) { FactoryGirl.create(:customer) }
  let!(:codec_group) { FactoryGirl.create(:codec_group) }

  before do
    FactoryGirl.create(:customer)
    FactoryGirl.create(:vendor)
    FactoryGirl.create(:codec_group)

    visit new_gateway_path

    aa_form.set_text 'Name', 'gw123'
    aa_form.select_chosen 'Contractor', contractor.display_name
    aa_form.switch_tab 'Media'
    aa_form.select_chosen 'Codec group', codec_group.display_name
  end

  context 'with termination' do
    before do
      aa_form.switch_tab 'Signaling'
      aa_form.set_text 'Host', '192.168.112.12'
    end

    it 'creates record' do
      subject
      record = Gateway.last
      expect(record).to be_present
      expect(record).to have_attributes(
        contractor_id: contractor.id,
        name: 'gw123',
        host: '192.168.112.12',
        allow_termination: true,
        codec_group_id: codec_group.id
      )
    end

    include_examples :changes_records_qty_of, Gateway, by: 1
    include_examples :shows_flash_message, :notice, 'Gateway was successfully created.'
  end

  context 'without termination' do
    before do
      aa_form.switch_tab 'General'
      aa_form.set_checkbox 'Allow termination', false
    end

    it 'creates record' do
      subject
      record = Gateway.last
      expect(record).to be_present
      expect(record).to have_attributes(
        contractor_id: contractor.id,
        name: 'gw123',
        host: '',
        allow_termination: false,
        codec_group_id: codec_group.id
      )
    end

    include_examples :changes_records_qty_of, Gateway, by: 1
    include_examples :shows_flash_message, :notice, 'Gateway was successfully created.'
  end
end
