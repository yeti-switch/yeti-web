# frozen_string_literal: true

RSpec.describe 'Create new Routing Tag Detection Rule', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::RoutingTagDetectionRule, 'new'
  include_context :login_as_admin

  before do
    visit new_routing_routing_tag_detection_rule_path
  end

  it 'creates record' do
    subject
    record = Routing::RoutingTagDetectionRule.last
    expect(record).to be_present
    expect(record).to have_attributes(
      dst_area_id: nil,
      src_area_id: nil,
      tag_action_id: nil,
      tag_action_value: [],
      routing_tag_ids: [],
      routing_tag_mode_id: Routing::RoutingTagMode::CONST::OR,
      src_prefix: '',
      dst_prefix: ''
    )
  end

  include_examples :changes_records_qty_of, Routing::RoutingTagDetectionRule, by: 1
  include_examples :shows_flash_message, :notice, 'Routing tag detection rule was successfully created.'

  context 'with src_prefix and dst_prefix' do
    before do
      aa_form.set_text 'Src prefix', '123'
      aa_form.set_text 'Dst prefix', '456'
    end

    it 'creates record' do
      subject
      record = Routing::RoutingTagDetectionRule.last
      expect(record).to be_present
      expect(record).to have_attributes(
        dst_area_id: nil,
        src_area_id: nil,
        tag_action_id: nil,
        tag_action_value: [],
        routing_tag_ids: [],
        routing_tag_mode_id: Routing::RoutingTagMode::CONST::OR,
        src_prefix: '123',
        dst_prefix: '456'
      )
    end

    include_examples :changes_records_qty_of, Routing::RoutingTagDetectionRule, by: 1
    include_examples :shows_flash_message, :notice, 'Routing tag detection rule was successfully created.'
  end
end
