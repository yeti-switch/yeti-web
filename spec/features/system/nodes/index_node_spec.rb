# frozen_string_literal: true

require 'spec_helper'

describe 'Index Nodes', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    nodes = create_list(:node, 2, :filled)
    visit nodes_path
    nodes.each do |node|
      expect(page).to have_css('.resource_id_link', text: node.id)
    end
  end
end
