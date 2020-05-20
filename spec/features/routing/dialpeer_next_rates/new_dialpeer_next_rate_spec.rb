# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Dialpeer Next Rate', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for DialpeerNextRate, 'new'
  include_context :login_as_admin

  let!(:dialpeer) { FactoryBot.create(:dialpeer) }
  before do
    FactoryBot.create(:dialpeer)
    visit new_dialpeer_dialpeer_next_rate_path(dialpeer.id)

    aa_form.set_date_time 'Apply time', '2019-01-01 01:00'
    aa_form.set_text 'Initial interval', '60'
    aa_form.set_text 'Next interval', '120'
    aa_form.set_text 'Initial rate', '0.1'
    aa_form.set_text 'Next rate', '0.2'
    aa_form.set_text 'Connect fee', '0.3'
  end

  it 'creates record' do
    subject
    record = DialpeerNextRate.last
    expect(record).to be_present
    expect(record).to have_attributes(
      dialpeer_id: dialpeer.id,
      initial_interval: 60,
      next_interval: 120,
      initial_rate: 0.1,
      next_rate: 0.2,
      connect_fee: 0.3,
      apply_time: Time.parse('2019-01-01 01:00:00 UTC')
    )
  end

  include_examples :changes_records_qty_of, DialpeerNextRate, by: 1
  include_examples :shows_flash_message, :notice, 'Dialpeer next rate was successfully created.'
end
