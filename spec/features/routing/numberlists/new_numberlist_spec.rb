# frozen_string_literal: true

RSpec.describe 'Create new Numberlist', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::Numberlist, 'new'
  include_context :login_as_admin

  before do
    visit new_numberlist_path

    aa_form.set_text 'Name', 'test'
  end

  it 'creates record' do
    subject
    record = Routing::Numberlist.last
    expect(record).to be_present
    expect(record).to have_attributes(
      name: 'test',
      mode_id: Routing::Numberlist::MODE_STRICT,
      default_action_id: Routing::Numberlist::DEFAULT_ACTION_REJECT,
      default_src_rewrite_rule: '',
      default_src_rewrite_result: '',
      default_dst_rewrite_rule: '',
      default_dst_rewrite_result: '',
      tag_action_id: nil,
      tag_action_value: []
    )
  end

  include_examples :changes_records_qty_of, Routing::Numberlist, by: 1
  include_examples :shows_flash_message, :notice, 'Numberlist was successfully created.'
end
