# frozen_string_literal: true

RSpec.describe 'Export Destination', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before do
    create(:destination)
  end

  let!(:item) do
    create :destination,
           routing_tag_mode: Routing::RoutingTagMode.find(Routing::RoutingTagMode::CONST::AND),
           routing_tag_ids: [tag_ua.id, tag_us.id, nil]
  end

  before do
    visit destinations_path(format: :csv)
  end

  subject { CSV.parse(page.body).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s, anything],
        ['Enabled', item.enabled.to_s, anything],
        ['Prefix', item.prefix.to_s, anything],
        ['Dst number min length', item.dst_number_min_length.to_s, anything],
        ['Dst number max length', item.dst_number_max_length.to_s, anything],
        ['Rate group name', item.rate_group.name, anything],
        ['Reject calls', item.reject_calls.to_s, anything],
        ['Rate policy name', item.rate_policy_name, anything],
        ['Initial interval', item.initial_interval.to_s, anything],
        ['Next interval', item.next_interval.to_s, anything],
        ['Use dp intervals', item.use_dp_intervals.to_s, anything],
        ['Initial rate', item.initial_rate.to_s, anything],
        ['Next rate', item.next_rate.to_s, anything],
        ['Connect fee', item.connect_fee.to_s, anything],
        ['Dp margin fixed', item.dp_margin_fixed.to_s, anything],
        ['Dp margin percent', item.dp_margin_percent.to_s, anything],
        ['Profit control mode name', item.profit_control_mode_name, anything],
        ['Valid from', item.valid_from.to_s, anything],
        ['Valid till', item.valid_till.to_s, anything],
        ['Asr limit', item.asr_limit.to_s, anything],
        ['Acd limit', item.acd_limit.to_s, anything],
        ['Short calls limit', item.short_calls_limit.to_s, anything],
        ['Reverse billing', item.reverse_billing.to_s, anything],
        ['Routing tag mode name', 'AND', 'OR'],
        ['Routing tag names', [tag_ua.name, tag_us.name, Routing::RoutingTag::ANY_TAG].join(', '), anything]
      ]
    )
  end
end
