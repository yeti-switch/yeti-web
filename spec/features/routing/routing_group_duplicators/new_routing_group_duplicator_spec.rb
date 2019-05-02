# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Routing Group Duplicator', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::RoutingGroupDuplicator, 'new'
  include_context :login_as_admin

  let!(:routing_group) { FactoryGirl.create(:routing_group) }
  before do
    visit new_routing_routing_group_duplicator_path(from: routing_group.id)

    aa_form.set_text 'Name', "#{routing_group.name} dup"
  end

  it 'creates record' do
    subject
    record = RoutingGroup.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: "#{routing_group.name} dup"
    )
  end

  include_examples :changes_records_qty_of, RoutingGroup, by: 1
  include_examples :shows_flash_message, :notice, 'Routing group duplicator was successfully created.'
end
