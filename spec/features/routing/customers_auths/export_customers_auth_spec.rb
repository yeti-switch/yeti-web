require 'spec_helper'

describe 'Export Customers Auth', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  # empty record for testing error 'Undefined method for nil-Class'
  before { create(:customers_auth) }

  let!(:item) do
    create(:customers_auth,
           transport_protocol: Equipment::TransportProtocol.take,
           pop: Pop.take,
           dst_numberlist: create(:numberlist),
           src_numberlist: create(:numberlist),
           radius_auth_profile: create(:auth_profile),
           radius_accounting_profile: create(:accounting_profile),
           ip: ['127.0.0.1', '0.0.0.0/0'],
           src_prefix: ['111', '222'],
           dst_prefix: ['333', '444'],
           uri_domain: ['localhost', 'example.com'],
           from_domain: ['from.com', 'from.net'],
           to_domain: ['to.com', 'to.net'],
           x_yeti_auth: ['qwe', 'asd'],
           tag_action: Routing::TagAction.take,
           tag_action_value: [@tag_us.id, @tag_emergency.id])
  end

  before do
    visit customers_auths_path(format: :csv)
  end

  subject do
    CSV.parse(page.body).transpose
  end

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s, anything],
        ['Enabled', item.enabled.to_s, anything],
        ['Reject calls', item.reject_calls.to_s, anything],
        ['Name', item.name, anything],
        ['Transport protocol name', item.transport_protocol.name, anything],
        ['IP', item.ip.join(', '), anything],
        ['Pop name', item.pop.name, anything],
        ['SRC Prefix', item.src_prefix.join(', '), anything],
        ['Src number min length', item.src_number_min_length.to_s, anything],
        ['Src number max length', item.src_number_max_length.to_s, anything],
        ['DST Prefix', item.dst_prefix.join(', '), anything],
        ['Dst number min length', item.dst_number_min_length.to_s, anything],
        ['Dst number max length', item.dst_number_max_length.to_s, anything],
        ['URI Domain', item.uri_domain.join(', '), anything],
        ['From Domain', item.from_domain.join(', '), anything],
        ['To Domain', item.to_domain.join(', '), anything],
        ['X-Yeti-Auth', item.x_yeti_auth.join(', '), anything],
        ['Customer name', item.customer.name, anything],
        ['Account name', item.account.name, anything],
        ['Check account balance', item.check_account_balance.to_s, anything],
        ['Gateway name', item.gateway.name, anything],
        ['Require incoming auth', item.require_incoming_auth.to_s, anything],
        ['Rateplan name', item.rateplan.name, anything],
        ['Routing plan name', item.routing_plan.name, anything],
        ['Dst numberlist name', item.dst_numberlist.name, anything],
        ['Src numberlist name', item.src_numberlist.name, anything],
        ['Dump level name', item.dump_level.name, anything],
        ['Enable audio recording', item.enable_audio_recording.to_s, anything],
        ['Capacity', item.capacity.to_s, anything],
        ['Allow receive rate limit', item.allow_receive_rate_limit.to_s, anything],
        ['Send billing information', item.send_billing_information.to_s, anything],
        ['Diversion policy name', item.diversion_policy.name, anything],
        ['Diversion rewrite rule', item.diversion_rewrite_rule.to_s, anything],
        ['Diversion rewrite result', item.diversion_rewrite_result.to_s, anything],
        ['Src name rewrite rule', item.src_name_rewrite_rule.to_s, anything],
        ['Src name rewrite result', item.src_name_rewrite_result.to_s, anything],
        ['Src rewrite rule', item.src_rewrite_rule.to_s, anything],
        ['Src rewrite result', item.src_rewrite_result.to_s, anything],
        ['Dst rewrite rule', item.dst_rewrite_rule.to_s, anything],
        ['Dst rewrite result', item.dst_rewrite_result.to_s, anything],
        ['Radius auth profile name', item.radius_auth_profile.name, anything],
        ['Src number radius rewrite rule', item.src_number_radius_rewrite_rule.to_s, anything],
        ['Src number radius rewrite result', item.src_number_radius_rewrite_result.to_s, anything],
        ['Dst number radius rewrite rule', item.dst_number_radius_rewrite_rule.to_s, anything],
        ['Dst number radius rewrite result', item.dst_number_radius_rewrite_result.to_s, anything],
        ['Radius accounting profile name', item.radius_accounting_profile.name, anything],
        ['Tag action name', item.tag_action.name, anything],
        ['Tag action value names', item.tag_action_values.map(&:name).join(', '), anything],
      ]
    )
  end

end
