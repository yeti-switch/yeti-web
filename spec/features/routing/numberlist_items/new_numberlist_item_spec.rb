# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Numberlist Item', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::NumberlistItem, 'new'
  include_context :login_as_admin

  let!(:numberlist) { FactoryBot.create(:numberlist) }
  before do
    visit new_routing_numberlist_item_path

    aa_form.select_chosen 'Numberlist', numberlist.display_name
  end

  it 'creates record' do
    subject
    record = Routing::NumberlistItem.last
    expect(record).to be_present
    expect(record).to have_attributes(
      numberlist_id: numberlist.id,
      key: '',
      action_id: nil,
      src_rewrite_rule: '',
      src_rewrite_result: '',
      dst_rewrite_rule: '',
      dst_rewrite_result: '',
      tag_action_id: nil,
      tag_action_value: [],
      number_min_length: 0,
      number_max_length: 100
    )
  end

  include_examples :changes_records_qty_of, Routing::NumberlistItem, by: 1
  include_examples :shows_flash_message, :notice, 'Numberlist item was successfully created.'
end
