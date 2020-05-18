# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Dialpeer', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Dialpeer, 'new'
  include_context :login_as_admin

  let!(:vendor) { FactoryBot.create(:vendor, name: 'John Doe') }
  let!(:account) { FactoryBot.create(:account, contractor: vendor) }
  let!(:routing_group) { FactoryBot.create(:routing_group) }
  let!(:routeset_discriminator) { FactoryBot.create(:routeset_discriminator) }
  let!(:gateway) { FactoryBot.create(:gateway, contractor: vendor) }
  before do
    FactoryBot.create(:routing_group)
    FactoryBot.create(:routeset_discriminator)
    vendor_2 = FactoryBot.create(:vendor)
    FactoryBot.create(:account, contractor: vendor_2)
    FactoryBot.create(:gateway, contractor: vendor_2)
    FactoryBot.create(:account, contractor: vendor)
    FactoryBot.create(:gateway, contractor: vendor)

    visit new_dialpeer_path

    aa_form.set_text 'Initial rate', '0.1'
    aa_form.set_text 'Next rate', '0.2'
    aa_form.select_chosen 'Vendor', vendor.display_name
    aa_form.select_chosen 'Account', account.display_name
    aa_form.select_chosen 'Routing group', routing_group.display_name
    aa_form.select_chosen 'Routeset discriminator', routeset_discriminator.display_name
    aa_form.select_chosen 'Gateway', gateway.display_name
  end

  it 'creates record' do
    subject
    record = Dialpeer.last
    expect(record).to be_present
    expect(record).to have_attributes(
      vendor_id: vendor.id,
      account_id: account.id,
      routing_group_id: routing_group.id,
      routeset_discriminator_id: routeset_discriminator.id,
      initial_rate: 0.1,
      next_rate: 0.2
    )
  end

  include_examples :changes_records_qty_of, Dialpeer, by: 1
  include_examples :shows_flash_message, :notice, 'Dialpeer was successfully created.'
end
