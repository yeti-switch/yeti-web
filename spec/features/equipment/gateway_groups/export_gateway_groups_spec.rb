# frozen_string_literal: true

RSpec.describe 'Export Gateway Groups', type: :feature do
  include_context :login_as_admin

  before { create(:gateway_group) }

  let!(:item) do
    create(:gateway_group)
  end

  before do
    visit gateway_groups_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name],
        ['Vendor name', item.vendor.name],
        ['Balancing mode name', item.balancing_mode_name],
        ['Max rerouting attempts', item.max_rerouting_attempts.to_s]
      ]
    )
  end
end
