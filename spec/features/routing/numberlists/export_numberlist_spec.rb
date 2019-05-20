# frozen_string_literal: true

require 'spec_helper'

describe 'Export Numberlist', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before do
    create(:numberlist)
  end

  let!(:item) do
    create(:numberlist,
           tag_action: Routing::TagAction.take,
           tag_action_value: [@tag_ua.id, @tag_us.id])
  end

  before do
    visit numberlists_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name],
        ['Mode name', item.mode.name],
        ['Default action name', item.default_action.name],
        ['Default src rewrite rule', item.default_src_rewrite_rule.to_s],
        ['Default src rewrite result', item.default_src_rewrite_result.to_s],
        ['Default dst rewrite rule', item.default_dst_rewrite_rule.to_s],
        ['Default dst rewrite result', item.default_dst_rewrite_result.to_s],
        ['Lua script name', item.lua_script.name, anything],
        ['Tag action name', item.tag_action.name],
        ['Tag action value names', item.tag_action_values.map(&:name).join(', ')],
        ['Created at', item.created_at.to_s],
        ['Updated at', item.updated_at.to_s]
      ]
    )
  end
end
