require 'spec_helper'

describe 'Export RoutingTagDetectionRule', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before { create(:routing_tag_detection_rule) }

  let!(:item) do
    create(:routing_tag_detection_rule,
           routing_tag_ids: [@tag_emergency.id, @tag_us.id],
           src_area: create(:area),
           dst_area: create(:area),
           tag_action: Routing::TagAction.take,
           tag_action_value: [@tag_ua.id, @tag_us.id])
  end

  before do
    visit routing_routing_tag_detection_rules_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Routing tag names', item.routing_tags.map(&:name).join(', ')],
        ['Src area name', item.src_area.name],
        ['Dst area name', item.dst_area.name],
        ['Tag action name', item.tag_action.name],
        ['Tag action value names', item.tag_action_values.map(&:name).join(', ')]
      ]
    )
  end
end
