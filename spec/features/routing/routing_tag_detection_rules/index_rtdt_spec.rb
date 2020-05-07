# frozen_string_literal: true

require 'spec_helper'

describe 'Index Routing Tag Detection Rules', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    routing_tag_detection_rules = create_list(:routing_tag_detection_rule, 2, :filled)
    visit routing_routing_tag_detection_rules_path
    routing_tag_detection_rules.each do |routing_tag_detection_rule|
      expect(page).to have_css('.resource_id_link', text: routing_tag_detection_rule.id)
    end
  end
end
