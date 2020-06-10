# frozen_string_literal: true

RSpec.describe 'Create new Routing Tag', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::RoutingTag, 'new'
  include_context :login_as_admin

  before do
    visit new_routing_routing_tag_path

    aa_form.set_text 'Name', 'test'
  end

  it 'creates record' do
    subject
    record = Routing::RoutingTag.last
    expect(record).to be_present
    expect(record).to have_attributes(name: 'test')
  end

  include_examples :changes_records_qty_of, Routing::RoutingTag, by: 1
  include_examples :shows_flash_message, :notice, 'Routing tag was successfully created.'
end
