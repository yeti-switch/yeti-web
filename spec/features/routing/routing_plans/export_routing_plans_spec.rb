# frozen_string_literal: true

RSpec.describe 'Export Routing Plans', type: :feature do
  include_context :login_as_admin

  before { create(:routing_plan) }

  let!(:item) do
    create(
      :routing_plan,
      dst_numberlist: create(:numberlist),
      src_numberlist: create(:numberlist)
    )
  end

  before do
    visit routing_routing_plans_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name],
        ['Sorting name', item.sorting_name],
        ['Use lnp', item.use_lnp.to_s],
        ['Rate delta max', item.rate_delta_max.to_s],
        ['Max rerouting attempts', item.max_rerouting_attempts.to_s],
        ['Validate dst number format', item.validate_dst_number_format.to_s],
        ['Validate dst number network', item.validate_dst_number_network.to_s],
        ['Validate src number format', item.validate_src_number_format.to_s],
        ['Validate src number network', item.validate_src_number_network.to_s],
        ['Src numberlist name', item.src_numberlist.name],
        ['Dst numberlist name', item.dst_numberlist.name]
      ]
    )
  end
end
