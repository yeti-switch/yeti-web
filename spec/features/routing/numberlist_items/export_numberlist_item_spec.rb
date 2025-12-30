# frozen_string_literal: true

RSpec.describe 'Export Numberlist Item', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before { create(:numberlist_item) }

  let!(:item) do
    create(:numberlist_item,
           action_id: Routing::Numberlist::DEFAULT_ACTION_ACCEPT,
           tag_action: Routing::TagAction.take,
           tag_action_value: [tag_ua.id, tag_us.id],
           variables: { 'k' => 'v' })
  end

  before do
    visit routing_numberlist_items_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Key', item.key],
        ['Number min length', item.number_min_length.to_s],
        ['Number max length', item.number_max_length.to_s],
        ['Numberlist name', item.numberlist.name],
        ['Action name', item.action_name],
        ['Src rewrite rule', item.src_rewrite_rule.to_s],
        ['Src rewrite result', item.src_rewrite_result.to_s],
        ['Defer src rewrite', item.defer_src_rewrite.to_s],
        ['Dst rewrite rule', item.dst_rewrite_rule.to_s],
        ['Dst rewrite result', item.dst_rewrite_result.to_s],
        ['Defer dst rewrite', item.defer_dst_rewrite.to_s],
        ['Lua script name', item.lua_script.name],
        ['Tag action name', item.tag_action.name],
        ['Tag action value names', item.tag_action_values.map(&:name).join(', ')],
        ['Variables', item.variables_json.to_s],
        ['Rewrite ss status name', item.rewrite_ss_status_name.to_s],
        ['Created at', item.created_at.to_s],
        ['Updated at', item.updated_at.to_s]
      ]
    )
  end
end
