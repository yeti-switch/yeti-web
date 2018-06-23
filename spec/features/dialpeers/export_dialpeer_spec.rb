RSpec.describe 'Export Dialpeer', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before do
    create(:dialpeer)
  end

  let(:contractor) { gateway.contractor }
  let(:gateway) { create(:gateway) }
  let(:gateway_group) { create(:gateway_group, vendor: contractor) }
  let(:account) { create(:account, contractor: contractor) }

  let!(:item) do
    create(:dialpeer,
           vendor: contractor,
           account: account,
           gateway: gateway,
           gateway_group: gateway_group,
           routing_tag_mode: Routing::RoutingTagMode.find(Routing::RoutingTagMode::CONST::AND),
           routing_tag_ids: [@tag_ua.id, @tag_us.id, nil])
  end

  before do
    visit dialpeers_path(format: :csv)
  end

  subject { CSV.parse(page.body).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s, anything],
        ['Enabled', item.enabled.to_s, anything],
        ['Locked', item.locked.to_s, anything],
        ['Prefix', item.prefix, anything],
        ['Priority', item.priority.to_s, anything],
        ['Force hit rate', item.force_hit_rate.to_s, anything],
        ['Exclusive route', item.exclusive_route.to_s, anything],
        ['Initial interval', item.initial_interval.to_s, anything],
        ['Initial rate', item.initial_rate.to_s, anything],
        ['Next interval', item.next_interval.to_s, anything],
        ['Next rate', item.next_rate.to_s, anything],
        ['Connect fee', item.connect_fee.to_s, anything],
        ['Lcr rate multiplier', item.lcr_rate_multiplier.to_s, anything],
        ['Gateway name', item.gateway.name, anything],
        ['Gateway group name', item.gateway_group.name, anything],
        ['Routing group name', item.routing_group.name, anything],
        ['Vendor name', item.vendor.name, anything],
        ['Account name', item.account.name, anything],
        ['Valid from', item.valid_from.to_s, anything],
        ['Valid till', item.valid_till.to_s, anything],
        ['Acd limit', item.acd_limit.to_s, anything],
        ['Asr limit', item.asr_limit.to_s, anything],
        ['Short calls limit', item.short_calls_limit.to_s, anything],
        ['Capacity', item.capacity.to_s, anything],
        ['Src rewrite rule', item.src_rewrite_rule.to_s, anything],
        ['Src rewrite result', item.src_rewrite_result.to_s, anything],
        ['Dst rewrite rule', item.dst_rewrite_rule.to_s, anything],
        ['Dst rewrite result', item.dst_rewrite_result.to_s, anything],
        ['Reverse billing', item.reverse_billing.to_s, anything],
        ["Routing tag mode name", "AND", "OR"],
        ['Routing tag names', [@tag_ua.name, @tag_us.name, Routing::RoutingTag::ANY_TAG].join(', '), anything]
      ]
    )
  end
end
